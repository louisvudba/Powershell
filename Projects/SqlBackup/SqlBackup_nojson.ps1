# ======================================== ENTRY POINT MAIN ======================================== #
Param(
    [Parameter(Mandatory, HelpMessage = "Backup Type: F - Full, D - Differential, L - Log")]
    [ValidateSet("Full","Diff", "Log")]
	[string]$Type
	,
	[Parameter()]
	[string]$Database	
)
# ======================================== INITIALIZE ======================================== #
$RootPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$PrivateKeyPath = "{0}\Credentials\PrivateKey.txt" -F $RootPath
$PrivateKey = Get-Content -Path $PrivateKeyPath 
# ======================================== DATABASE CONFIG ======================================== #
$Instance = $ENV:COMPUTERNAME
$BackupPath = "G:\\Backup"
$BackupCert = ""
$BackupAlgorithm = "AES256"
$FileCount = 1 # Backup split multi files

$DBUser = "replicator"
$DBPasswordHashPath = "{0}\Credentials\PasswordHash_DB.txt" -F $RootPath
$DBPassword = Get-Content -Path $DBPasswordHashPath | ConvertTo-SecureString -Key $PrivateKey
$DBCredential = New-Object System.Management.Automation.PSCredential($DBUser, $DBPassword)

$Query_GetDatabase = ""
# For test - $Query_GetDatabase = "SELECT Name FROM sys.databases WHERE name IN ('Monitoring', 'TestDB')"

if ($null -eq $Database -or $Database -eq '') {
	$BackupDatabases = Invoke-DbaQuery -SqlInstance $Instance -SqlCredential $DBCredential -Query $Query_GetDatabase -EA Stop
}
else { 
	$BackupDatabases = '' | Select-Object Name
	$BackupDatabases.Name = $Database
}

$HistoryQueryParams = @{
	SqlInstance = $Instance
	Database = "Monitoring"
	SqlCredential = $DBCredential	
	CommandType = "StoredProcedure"
}
$HistoryInsertProc = "sp_BackupHistory_Insert"
$HistoryUpdateProc = "sp_BackupHistory_Update"
# ======================================== MAIL CONFIG ======================================== #
$SMTP_SERVER = ""
$SMTP_PORT = 587
$SMTP_SSL = $True # If using SSL

$FROM = ""
$TO = "" # List of Email split by ';'
$Encoding = "UTF8"
$BodyAsHtml = $True # Send body with html

$AWS_ACCESS_KEY = ""
$MailKeyHashPath = "{0}\Credentials\PasswordHash_MAIL.txt" -F $RootPath
$AWS_SECRET_KEY = Get-Content -Path $MailKeyHashPath | ConvertTo-SecureString -Key $PrivateKey
$AWS_CREDENTIAL = New-Object System.Management.Automation.PSCredential($AWS_ACCESS_KEY, $AWS_SECRET_KEY)
# ======================================== FTP CONFIG ======================================== #
$FTP_SERVER = ""

$FtpUser = ""
$FtpKeyHashPath = "{0}\Credentials\PasswordHash_FTP.txt" -F $RootPath
$FtpPassword = Get-Content -Path $FtpKeyHashPath | ConvertTo-SecureString -Key $PrivateKey
$FTPCredential = New-Object System.Management.Automation.PSCredential($FtpUser, $FtpPassword)
# ======================================== MODULE ======================================== #
. ("{0}\Libs\Ftp.ps1" -F $RootPath)
# ======================================== PROCESS ======================================== #
$BackupDatabases | ForEach-Object {	
	$Database = $_.Name
	$StartTime = (Get-Date)	
	$Response = "" | Select-Object Instance, Database, Error, Detail	
	$Response.Instance = $Instance
	$Response.Database = $Database
	$Params = @{
		SqlInstance      = $Instance
		Database         = $Database
		Path  			 = $BackupPath
		TimeStampFormat	 = "yyyyMMdd_HHmmss"
		Type             = $Type
		CompressBackup   = $True
		IgnoreFileChecks = $True
		Checksum         = $Checksum
		Verify           = $Verify
		FileCount        = $FileCount
		SqlCredential    = $DBCredential
	}
	$Encryption = @{
		EncryptionAlgorithm = $BackupAlgorithm
		EncryptionCertificate = $BackupCert
	}	
	try {
		$Result = Backup-DbaDatabase @Params @Encryption
		
		$Response.Error = 0
		$Response.Detail = $Result  		
	}
	catch {
		$Response.Error = 1
		$Response.Detail = $Error[0].Exception.Message
		Write-Warning $Error[0].Exception.Message
	}	
	$EndTime = (Get-Date)
	'{0} - Duration: {1:mm} min {1:ss} sec' -f $Database, ($EndTime-$StartTime)
	
	if ($Response.Error -ne 0) {
		# Send error via Email
		$Subject = "[ERROR] Database Backup"
		$Body = "<h1>Database backup error<h1/>- Database: {0}<br /> - Message: {1}<br />" -F $Database, $Response.Detail
        $sendMailParams = @{
            From = $FROM
            To = $TO.Split(";")
            Subject = $Subject
            BodyAsHtml = $BodyAsHtml
            Body = $Body
            Encoding = $Encoding
            SMTPServer = $SMTP_SERVER
            Port = $SMTP_PORT
            UseSsl = $SMTP_SSL
            Credential = $AWS_CREDENTIAL
        }
		try {		
			Send-MailMessage @sendMailParams -EA Stop
		}
		catch {
			Write-Warning $Error[0].Exception.Message
		}

		# Logging to backup history (failed)
		$QueryParameters = @{
			database_name = $Database
			backup_type = $Type		
			backup_start_date = $StartTime
			backup_end_date = $Null
			status = $Response.Error
			error_message = $Response.Detail			
		}
		Invoke-DbaQuery @HistoryQueryParams -Query $HistoryInsertProc -SqlParameters $QueryParameters -EA Stop | Out-Null		
	}
	else {			
		# Get Timezone
		$tz = Get-Timezone		
		# Generate MD5 Hash			
		$HashFile = (Get-FileHash $Response.Detail.BackupPath -Algorithm MD5).Hash
		# Logging to backup history (sucessful)		
		$QueryParameters = @{
			database_name = $Database
			backup_type = $Type
			backup_file_name = $Response.Detail.BackupFile
			backup_file_path = $Response.Detail.BackupFolder
			backup_file_hash = $HashFile
			backup_start_date = ([System.TimeZoneInfo]::ConvertTime($Response.Detail.Start, $tz)).AddHours(-$tz.BaseUtcOffset.TotalHours)
			backup_end_date = ([System.TimeZoneInfo]::ConvertTime($Response.Detail.End, $tz)).AddHours(-$tz.BaseUtcOffset.TotalHours)
			status = 0
			error_message = $null		
		}
		$BackupHistory = Invoke-DbaQuery @HistoryQueryParams -Query $HistoryInsertProc -SqlParameters $QueryParameters -ErrorAction Stop

		# Logging start uploading		
		$RemoteFile = "ftp://{0}/{1}" -F $FTP_SERVER, $Response.Detail.BackupFile

		$QueryParameters = $null
		$QueryParameters = @{
			id = $BackupHistory.id		
			ftp_status = 1
			ftp_file_path = "ftp://{0}@{1}/{2}" -F $FtpUser, $FTP_SERVER, $Response.Detail.BackupFile
		}
		Invoke-DbaQuery @HistoryQueryParams -Query $HistoryUpdateProc -SqlParameters $QueryParameters -ErrorAction Stop | Out-Null

		# try ftp
		$UploadResult = Move-FTP -LocalFile $Response.Detail.BackupPath -RemoteFile $RemoteFile -FtpCredential $FTPCredential
			
		$QueryParameters = $null
		$QueryParameters = @{
			id = $BackupHistory.id		
			ftp_status = if ($UploadResult.Error -eq 0) { 2 } else { $UploadResult.Error }
			error_message = if ($UploadResult.Error -eq 0) { $null } else { $UploadResult.Detail }
		}
		Invoke-DbaQuery @HistoryQueryParams -Query $HistoryUpdateProc -SqlParameters $QueryParameters -ErrorAction Stop | Out-Null

		if ($UploadResult.Error -eq 0) {
			$RemoteFileSize = Get-FileSize -RemoteFile $RemoteFile -FtpCredential $FTPCredential
			if (($RemoteFileSize.Error -eq 0) -and ($RemoteFileSize.Detail = (Get-Item $Response.Detail.BackupPath).Length)) {			
				try {
					$verify_file_size = $True
					Remove-Item $Response.Detail.BackupPath | Out-Null
					Write-Host "$($Response.Detail.BackupPath) deleted"
				}
				catch {
					$verify_file_size = $False
					Write-Warning "$($Response.Detail.BackupPath) - Delete file error - $($Error[0].Exception.Message)"
				}
			}
			else {			
				$verify_file_size = $False
				Write-Warning "Upload file error - $($Response.Detail.BackupPath)"
			}

			$QueryParameters = $null
			$QueryParameters = @{
				id = $BackupHistory.id		
				ftp_status = 2
				verify_file_size = $verify_file_size
			}
			Invoke-DbaQuery @HistoryQueryParams -Query $HistoryUpdateProc -SqlParameters $QueryParameters -ErrorAction Stop | Out-Null
		}
	}
}