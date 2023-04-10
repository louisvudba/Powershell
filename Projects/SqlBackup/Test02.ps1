Try {
    Import-Module E:\Repositories\Github\DevOps\Projects\Powershell\Modules/BackupDatabase -ErrorAction Stop
}
Catch {
    $_.Exception.Message
    Write-Verbose "BackupDatabase module not installed!"
    Break
}

$Config = Get-Content "$(Split-Path $MyInvocation.MyCommand.Path)\config_current.json" | ConvertFrom-Json

$backupConfig = $Config.backup_config
$historyConfig = $Config.history_config
$mailConfig = $Config.mail_config
$ftpConfig = $Config.ftp_config
$Type = "F"
$ReplaceInName = $false
$FileCount = 1 # count of files
$isCredential = $False
$backupConfig.databases | ForEach-Object {
    $params = @{
        Type = $Type
        SqlInstance = $backupConfig.sql_instance
        SqlBackupDir = $backupConfig.sql_backup_dir
        DbName = $_
        CompressBackup = $True
        Checksum = $True
        Encryption = $True
        EncryptionAlgorithm = $backupConfig.cert_algorithm
        EncryptionCertificate = $backupConfig.cert_name
        ReplaceInName = $ReplaceInName
        FileCount = $FileCount
        Verify = $True
    }
    if ($isCredential) {
        $Response = Invoke-BackupSQLDatabase @params -SqlCredential $Credential
    }
    else {
        $Response = Invoke-BackupSQLDatabase @params
    }
    $Response
}