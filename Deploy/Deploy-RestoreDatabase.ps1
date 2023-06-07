Param(
    [Parameter(mandatory=$false)][string]$TargetServer,
    [Parameter(mandatory=$false)][string]$DatabaseName    
)

Import-Module -Name PoshRSJob

$RootPath = "G:\DBA"
$ServerPath = "$RootPath\Config\dbservers.csv"
$ServerList = @()
if ($TargetServer) {
    $ServerList += ([PSCustomObject]@{
            ServerName = $TargetServer
            DBName = $DatabaseName
        })
}
else {$ServerList = Import-Csv $ServerPath -Delimiter ","}

$ServerList | Start-RSJob -Throttle $(($ServerList | Measure-Object).Count) -ScriptBlock {
    $Session = New-PSSession $_.ServerName
    Invoke-Command -Session $Session -ArgumentList $_.ServerName, $_.DatabaseName -Command {
        Param($ServerName, $DatabaseName)

        Import-Module -Name dbatools

        $DataFileDir = "F:\Database"
        $FileStreamDir = "F:\Database"
        $DataLogDir = "G:\Database"
        $BackupPath = "H:\Backup"

        #Init Folder        
        If (!(test-path $DataFileDir)) { New-Item -ItemType Directory -Force -Path $DataFileDir | Out-Null }
        If (!(test-path $DataLogDir)) { New-Item -ItemType Directory -Force -Path $DataLogDir | Out-Null }
        
        $username  = New-Object System.Security.Principal.Ntaccount("NT SERVICE\MSSQLSERVER")
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,"FullControl",  
        [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit", 
        [system.security.accesscontrol.PropagationFlags]"None",
        "Allow")

        $acl = Get-Acl $DataFileDir
        $acl.AddAccessRule($AccessRule)
        $acl | Set-Acl $DataFileDir

        $acl = Get-Acl $DataLogDir
        $acl.AddAccessRule($AccessRule)
        $acl | Set-Acl $DataLogDir
    
        # Restore Database

        Get-ChildItem -Path $BackupPath -File | Where-Object { $_.Name -like "$DatabaseName*" | Restore-DbaDatabase -SqlInstance $ServerName `
            -DestinationDataDirectory $DataFileDir `
            -DestinationFileStreamDirectory $FileStreamDir `
            -DestinationLogDirectory $DataLogDir `
            -NoRecovery

        Restore-DbaDatabase -SqlInstance $ServerName –DatabaseName $DatabaseName –Recover
    }

} | Wait-RSJob | Receive-RSJob

Get-RSJob | Remove-RSJob