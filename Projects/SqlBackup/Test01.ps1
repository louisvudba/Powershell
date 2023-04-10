Try {
    Import-Module E:\Repositories\Github\DevOps\Powershell\Modules/BackupDatabase -ErrorAction Stop
}
Catch {
    $_.Exception.Message
    Write-Verbose "dbatools module not installed!"
    Break
}

$Config = Get-Content "$(Split-Path $MyInvocation.MyCommand.Path)\Config.json" | ConvertFrom-Json

$DBList = [string[]](
    "DBATools", "ReplicationDB"
)

$startTime = (Get-Date)
$Response = $DBList | Invoke-BackupSQLDatabase -Type F -SqlInstance 'CLUSTER-LAMVT\SQL2019' -SqlBackupDir 'E:\Database Backup\2019' -Checksum -CompressBackup `
            -Encryption -EncryptionAlgorithm 'AES256' -EncryptionCertificate 'BackupCert'
$endTime = (Get-Date)
'Duration: {0:mm} min {0:ss} sec' -f ($endTime-$startTime)

$HashList = @()
$Response | ForEach-Object {
    $HashList += Get-FileHash $_.BackupPath -Algorithm MD5
    $_
} 

$HashList

# $startTime = $endTime
# $Response = $DBList | Invoke-BackupSQLDatabase -Type F -SqlInstance 'CLUSTER-LAMVT\SQL2019' -SqlBackupDir 'E:\Database Backup\2019' -Checksum
# $endTime = (Get-Date)
# 'Duration: {0:mm} min {0:ss} sec' -f ($endTime-$startTime)

# $startTime = $endTime
# $Response | Foreach-Object {
#     $Source = $_.BackupPath
#     $Target = $_.BackupPath -replace ".bak", ".7z"
#     $CompressPw = "lamvt"

#     Compress-Backup7z -FilesToZip $Source -ZipOutputFilePath $Target -Pass $CompressPw -HideWindow -DeleteAfterArchive
# }
# $endTime = (Get-Date)
# 'Duration: {0:mm} min {0:ss} sec' -f ($endTime-$startTime)

{ABC} | Select -First 1