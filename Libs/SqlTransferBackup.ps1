# ======================================== ENTRY MAIN POINT ======================================== #
Param(
	[Parameter()]
	[string]$Database	
)

# ======================================== GLOBAL SETTINGS ======================================== #
$settings = Get-Content 'C:\DBA\Config\GlobalSetting.json' | ConvertFrom-Json
$rootPath = $settings.root_path
$privateKey = Get-Content -Path ($rootPath, $settings.credential_path, $settings.private_key_path -Join "\")
$backupSetting = Get-Content -Path ($rootPath, $settings.config_path, $settings.backup_conf -Join "\") | ConvertFrom-Json
$fileTransferSetting = Get-Content -Path ($rootPath, $settings.config_path, $settings.file_transfer_conf -Join "\") | ConvertFrom-Json

# ======================================== LIBS ======================================== #
try {
    . ("{0}\Core\FileTransfer.ps1" -F $rootPath)
    . ("{0}\Core\SendMail.ps1" -F $rootPath)
    . ("{0}\Core\SendSlack.ps1" -F $rootPath)
}
catch {
    Write-Host "Error while loading supporting PowerShell Scripts" 
    Break
}
# ======================================== DATABASE ======================================== #
$instance = $ENV:COMPUTERNAME

$dbCredential = New-Object System.Management.Automation.PSCredential($backupSetting.db_user, `
                (Get-Content -Path ($rootPath, $settings.credential_path, $settings.db_key_path -Join "\") | ConvertTo-SecureString -Key $privateKey))

$query = "SELECT TOP (1) * FROM [EventMonitoring].[dbo].[BackupHistory] WHERE ftp_status IN (1,0,-99) AND status = 0"
$backupDb = Invoke-DbaQuery -SqlInstance $instance -SqlCredential $dbCredential -Query $query -EA Stop

$dbParams = @{
	SqlInstance = $instance
	Database = $backupSetting.backup_history_db
	SqlCredential = $dbCredential	
	CommandType = 'StoredProcedure'
}
#$slackMessage = @()
# ======================================= PROCESS ======================================== #
# Test Backup files 
$physicalFilePath =  ($backupDb.backup_file_path, $backupDb.backup_file_name -Join "\")
if (Test-Path -Path $physicalFilePath -PathType Leaf) {    
    
    $transferSetting = $fileTransferSetting.nfs_setting        
    $sqlParams = $null
    $sqlParams = @{
        id = $backupDb.id		
        ftp_status = 1
        ftp_file_path = '\\{0}\{1}\{2}\{3}\{4}' -F $transferSetting.nfs_server, $transferSetting.nfs_client, $transferSetting.nfs_product, $backupDb.database_name, $backupDb.backup_file_name
    }
	#Write-Host $physicalFilePath
    Invoke-DbaQuery @dbParams -Query $backupSetting.backup_history_update_proc -SqlParameters $sqlParams -ErrorAction Stop | Out-Null	
    
    $remotePath = '\\{0}\{1}\{2}\{3}' -F $transferSetting.nfs_server, $transferSetting.nfs_client, $transferSetting.nfs_product, $backupDb.database_name	
	#Write-Host $remotePath
    If (!(Test-Path -Path $remotePath)){
        New-Item -ItemType Directory -Force -Path $remotePath
    }
	$succeedUpload = $False
    $transferParams = @{
        SourcePath = $backupDb.backup_file_path
        LocalFile = $backupDb.backup_file_name
        RemotePath = $remotePath
    }    

	$uploadResult = Invoke-Transfer-Robocopy @transferParams		
    $retries = if ($backupDb.ftp_retry -eq [System.DBNull]::Value) { 1 } else { $backupDb.ftp_retry + 1 }
	
	#write-host $uploadResult.Error
    if ($uploadResult.Error -eq 0) { 
        $ftpStatus = 2
        $errMsg = $null		
		try {
			$succeedUpload = $True
			Remove-Item $physicalFilePath | Out-Null                    
			Write-Host "$($physicalFilePath) deleted"
		}
		catch {
			$succeedUpload = $False
			Write-Error "$physicalFilePath - Delete file error - $($_.Exception.Message)"
		}
    }
    else {
		$succeedUpload = $False
        $ftpStatus = -99
        $errMsg = if ($uploadResult.Error -ne 1) { "Robocopy exit code: {0}" -F $uploadResult.Error } else { $uploadResult.Detail }
    } 
  
    <#
    $transferSetting = $fileTransferSetting.sftp_setting			
    $sqlParams = $null
    $sqlParams = @{
        id = $backupDb.id		
        ftp_status = 1
        ftp_file_path = 'sftp://{0}{1}{2}' -F $transferSetting.server, $transferSetting.remote_path, $backupDb.backup_file_name
    }
    Invoke-DbaQuery @dbParams -Query $backupSetting.backup_history_update_proc -SqlParameters $sqlParams -ErrorAction Stop | Out-Null
    
    $succeedUpload = $False
    $retries = 0		
    $sftpParams = @{
        Server = $transferSetting.server
        LocalFile = $physicalFilePath
        RemotePath = $transferSetting.remote_path
        UserName = $transferSetting.user
        SecuredPassword = (Get-Content -Path ($rootPath, $settings.credential_path, $settings.sftp_key_path -Join "\") | ConvertTo-SecureString -Key $privateKey)
        FingerPrint = $transferSetting.fingerprint
    }
    while (-not $succeedUpload) {
        $retries += 1
        $uploadResult = Invoke-TransferViaSFTP-WinSCP @sftpParams				
        if ($uploadResult.Error -eq 0) {				
            $remoteFileSize = Get-FileSize-WinSCP @sftpParams -FileName $backupDb.backup_file_name
            if (($remoteFileSize.Error -eq 0) -and ($remoteFileSize.Detail = (Get-Item $physicalFilePath).Length)) {			
                try {
                    $succeedUpload = $True
                    Remove-Item $physicalFilePath | Out-Null                    
                    Write-Host "$($physicalFilePath) deleted"
                }
                catch {
                    $succeedUpload = $False
                    Write-Warning "$($physicalFilePath) - Delete file error - $($_.Exception.Message)"
                }
            }
            else {			
                $succeedUpload = $False
                Write-Warning "Upload file error - $($physicalFilePath)"
            }
        }
    }
    #>
    <#
    $transferSetting = $fileTransferSetting.ftp_setting
    $ftpFilePath = 'ftp://{0}/{1}/{2}/{3}' -F $transferSetting.server, $transferSetting.remote_path, $backupDb.database_name, $backupDb.backup_file_name
    $transferCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($transferSetting.user), `
        (Get-Content -Path ($rootPath, $settings.credential_path, $settings.ftp_key_path -Join "\") | ConvertTo-SecureString -Key $privateKey)
   
    $sqlParams = $null
    $sqlParams = @{
        id = $backupDb.id		
        ftp_status = 1
        ftp_file_path = $ftpFilePath
    }
    Invoke-DbaQuery @dbParams -Query $backupSetting.backup_history_update_proc -SqlParameters $sqlParams -ErrorAction Stop | Out-Null
    
    $succeedUpload = $False
    $retries = 0		
    $ftpParams = @{
        LocalFile = $physicalFilePath
        RemoteFile = $ftpFilePath
        FtpCredential = $transferCredential
    }
	Write-Host $backupDb.backup_file_name
	$response = Invoke-CheckDirectoryExists-FTP -FolderPath ('ftp://{0}/{1}/{2}' -F $transferSetting.server, $transferSetting.remote_path, $backupDb.database_name) `
        -FtpCredential $transferCredential
	
	if ($response.Error -eq 0) {	
		while (-not $succeedUpload -and $retries -lt 100) {
			$retries += 1
			$uploadResult = Invoke-TransferViaFTP-Stream @ftpParams
			if ($uploadResult.Error -eq 0) {				
				$remoteFileSize = Get-FileSize-FTP -RemoteFile $ftpFilePath -FtpCredential $transferCredential
				if (($remoteFileSize.Error -eq 0) -and ($remoteFileSize.Detail = (Get-Item $physicalFilePath).Length)) {			
					try {
						$succeedUpload = $True
						Remove-Item $physicalFilePath | Out-Null                    
						Write-Host "$($physicalFilePath) deleted"
					}
					catch {
						$succeedUpload = $False
						Write-Warning "$($physicalFilePath) - Delete file error - $($_.Exception.Message)"
					}
				}
				else {			
					$succeedUpload = $False
					Write-Warning "Upload file error - $($physicalFilePath)"
				}
			}
		}
        if ($uploadResult.Error -eq 0) { 
            $ftpStatus = 2
            $errMsg = $null
        }
        else {
            $ftpStatus = -99
            $errMsg = $uploadResult.Detail
        }
	}
    else {
        $ftpStatus = -99
        $errMsg = $response.Detail
    }
   #>
    $sqlParams = $null
    $sqlParams = @{
        id = $backupDb.id		
        ftp_status = $ftpStatus
        error_message = $errMsg
        verify_file_size = $succeedUpload #if ($ftpStatus -eq 2) { $True } else { $False }
        ftp_retry = $retries
    }
    Invoke-DbaQuery @dbParams -Query $backupSetting.backup_history_update_proc -SqlParameters $sqlParams -ErrorAction Stop | Out-Null
}

else {
    $sqlParams = $null
    $sqlParams = @{
        id = $backupDb.id		
        ftp_status = -1
        error_message = "Physical file is not existed"
        verify_file_size = $false
        ftp_retry = 0
    }
    Invoke-DbaQuery @dbParams -Query $backupSetting.backup_history_update_proc -SqlParameters $sqlParams -ErrorAction Stop | Out-Null
}