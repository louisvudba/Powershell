Param(
    [Parameter(mandatory=$false)][string]$TargetServer,
    [Parameter(mandatory=$true)][string]$MasterKeyPw,
    [Parameter(mandatory=$true)][string]$PrivateKeyPw
)

Import-Module -Name PoshRSJob

$RootPath = "G:\DBA"
$ServerPath = "$RootPath\Config\dbservers.csv"
$ServerList = @()
if ($TargetServer) {
    $ServerList += ([PSCustomObject]@{
            ServerName = $TargetServer
        })
}
else {$ServerList = Import-Csv $ServerPath -Delimiter ","}

$Params = ($RootPath,$MasterKeyPw,$PrivateKeyPw)
$ServerList | Start-RSJob -Throttle $(($ServerList | Measure-Object).Count) -ArgumentList $Params -ScriptBlock {
    Param($RootPath,$MasterKeyPw,$PrivateKeyPw)
    $Session = New-PSSession $_.ServerName

    Invoke-Command -Session $Session -Command { 
        # Create Database Folder & Permission        
        $path = "C:\Cert"
        If (!(test-path $path)) { New-Item -ItemType Directory -Force -Path $path | Out-Null}

        $acl = Get-Acl $path
        $username  = New-Object System.Security.Principal.Ntaccount("NT SERVICE\MSSQLSERVER")
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,"FullControl",  
        [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit", 
        [system.security.accesscontrol.PropagationFlags]"None",
        "Allow")
        $acl.AddAccessRule($AccessRule)
        $acl | Set-Acl $path
    }

    Copy-Item -Path "$RootPath\Source\BackupCert\KVBackupCertificate.cer" -Destination "C:\Cert\KVBackupCertificate.cer" -ToSession $Session
    Copy-Item -Path "$RootPath\Source\BackupCert\KVBackupPK.key" -Destination "C:\Cert\KVBackupPK.key" -ToSession $Session
   
    Invoke-Command -Session $Session -ArgumentList $MasterKeyPw,$PrivateKeyPw -Command {
        Param($MasterKeyPw,$PrivateKeyPw)
        $Query = "
            USE [master]
            GO
            IF NOT EXISTS (SELECT 1/0 FROM sys.symmetric_keys WHERE name LIKE '%DatabaseMasterKey%')
            BEGIN
                CREATE MASTER KEY ENCRYPTION BY PASSWORD = '$MasterKeyPw' -- MasterKeyPassword, doesn't need to be the same with master key on source database
            END
            GO
            
            IF EXISTS (SELECT 1/0 FROM sys.certificates WHERE name = 'BackupCertification')
                DROP CERTIFICATE BackupCertification
            
            /* Create Certification from source certificate to target database */
            IF NOT EXISTS (SELECT 1/0 FROM sys.certificates WHERE name = 'KVBackupCertificate')
                CREATE CERTIFICATE KVBackupCertificate
                FROM FILE = 'C:\Cert\KVBackupCertificate.cer'
                WITH PRIVATE KEY
                (
                    FILE = 'C:\Cert\KVBackupPK.key',
                    DECRYPTION BY PASSWORD = '$PrivateKeyPw' -- Private Key Password
                )
            GO
        "
        Invoke-Sqlcmd -Query $Query

        Remove-Item C:\Cert -Force -Recurse
    }
	
    Write-Host ("{0}" -f $TargetServer)

} | Wait-RSJob | Receive-RSJob

Get-RSJob | Remove-RSJob