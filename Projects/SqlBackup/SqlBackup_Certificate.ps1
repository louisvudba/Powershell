# ======================================== ENTRY MAIN POINT ======================================== #
Param(
    [Parameter(Mandatory, HelpMessage = "Backup Type: F - Full, D - Differential, L - Log")]
    [ValidateSet("Full","Diff", "Log")]
	[string]$Type
	,
	[Parameter()]
	[string]$Database	
)

# ======================================== GLOBAL SETTINGS ======================================== #
$settings = Get-Content 'E:\Repositories\Citigo\cluster-citigo-dba\Powershell\Config\GlobalSetting.json' | ConvertFrom-Json
$rootPath = $settings.root_path
$privateKey = Get-Content -Path ($rootPath, $settings.credential_path, $settings.private_key_path -Join "\")
$backupSetting = Get-Content -Path ($rootPath, $settings.config_path, $settings.backup_conf -Join "\") | ConvertFrom-Json
$mailSetting = Get-Content -Path ($rootPath, $settings.config_path, $settings.mail_conf -Join "\") | ConvertFrom-Json

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
$fileCount = $backupSetting.backup_multifiles

$dbCredential = New-Object System.Management.Automation.PSCredential($backupSetting.db_user, `
                (Get-Content -Path ($rootPath, $settings.credential_path, $settings.db_key_path -Join "\") | ConvertTo-SecureString -Key $privateKey))

if ($null -eq $Database -or $Database -eq '') {
	$backupDatabases = Invoke-DbaQuery -SqlInstance $instance -SqlCredential $dbCredential -Query $backupSetting.database_query -EA Stop
}
else {
	$query = "SELECT Name, Recovery_Model_Desc, State_Desc FROM sys.databases WHERE name = '{0}'" -F $Database
	$backupDatabases = Invoke-DbaQuery -SqlInstance $instance -SqlCredential $dbCredential -Query $query -EA Stop
}

$dbParams = @{
	SqlInstance = $instance
	Database = $backupSetting.backup_history_db
	SqlCredential = $dbCredential	
	CommandType = 'StoredProcedure'
}

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | out-null
$instance_setting = New-Object ('Microsoft.SqlServer.Management.Smo.Server') "LOCALHOST" 
$backupPath = $instance_setting.Settings.BackupDirectory
if ($Type -eq 'Log') { $filePath = "{0}.trn" -F $backupSetting.backup_file_format }
else { $filePath = "{0}.bak" -F $backupSetting.backup_file_format}

$tz = Get-Timezone
$slackMessage = @()

# ======================================= PROCESS ======================================== #
#$processStart = (Get-Date)
$backupDatabases | ForEach-Object {	
	if ($Type -eq 'Log' -and $_.Recovery_Model_Desc -eq 'SIMPLE') {		
		#$slackTitle = '[ALERT] *{0}* - DATABASE - {1} Backup' -F $ENV:COMPUTERNAME, $Type
		#$slackContent = 'Database *{0}* recovery model is *SIMPLE*' -F $_.Name
		#$params = @{
		#	WebhookUri  = $settings.slack_webhook_dr
		#	Title       = $slackTitle
		#	Content     = $slackContent
		#}
		#Send-SlackWebhook @params
		$slackMessage += 'Database *{0}* recovery model is *SIMPLE*' -F $_.Name
	}
	elseif ($_.State_Desc -eq 'OFFLINE') {
		$slackMessage += 'Database *{0}* is *OFFLINE*' -F $_.Name
	}
	else {
		$database = $_.Name
		$startTime = (Get-Date)	
		$response = "" | Select-Object Instance, Database, Error, Detail	
		$response.Instance = $instance
		$response.Database = $database
		$params = @{
			SqlInstance      = $instance
			Database         = $database
			Path  			 = $backupPath
			TimeStampFormat	 = $backupSetting.backup_format #"yyyyMMdd_HHmmss"
			FilePath 		 = $filePath
			ReplaceInName	 = $True
			Type             = $Type
			CompressBackup   = $True
			IgnoreFileChecks = $True
			Checksum         = $True
			Verify           = $True
			FileCount        = $fileCount
			SqlCredential    = $dbCredential
			Verbose			 = $False
		}
		$encryption = @{
			EncryptionAlgorithm = $backupSetting.backup_algorithm
			EncryptionCertificate = $backupSetting.backup_cert_name
		}	
		
		$result = Backup-DbaDatabase @params @encryption -WarningVariable WarnVar
		$response.Error = 0	
		$response.Detail = $result
		if (![string]::IsNullOrWhiteSpace($WarnVar)) {		
			$response.Error = 1
			$response.Detail = $WarnVar
		}
		$endTime = (Get-Date)
		'{0} - Duration: {1:mm} min {1:ss} sec' -F $database, ($endTime - $startTime)
		
		if ($response.Error -ne 0) {
			# Send error via Email
			$params = @{
				MailSetting     = $mailSetting
				Subject         = '[ERROR] DATABASE BACKUP'
				Body            = '<h1>Database backup error</h1>- Database: {0}<br /> - Message: {1}<br />' -F $database, $response.Detail[0]
				SecretKeyPath   = '{0}\{1}\{2}' -F $rootPath, $settings.credential_path, $settings.mail_key_path
				PrivateKeyPath  = '{0}\{1}\{2}' -F $rootPath, $settings.credential_path, $settings.private_key_path
			}
			Test-SendMail @params -EA Stop
			$errorMessage = [String]$response.Detail[0]
			# Logging to backup history (failed)			
			$sqlParams = $null
			$sqlParams = @{
				database_name = $database
				backup_type = $Type
				backup_start_date = ([System.TimeZoneInfo]::ConvertTime($startTime, $tz)).AddHours(-$tz.BaseUtcOffset.TotalHours)
				status = $response.Error
				error_message = $errorMessage
			}		
			Invoke-DbaQuery @dbParams -Query $backupSetting.backup_history_insert_proc -SqlParameters $sqlParams -EA Stop | Out-Null	
			$endTime = (Get-Date)
			$slackMessage += 'Database *{0}* error: {1}' -F $database, $errorMessage
		}
		else {
			# Generate MD5 Hash			
			#$HashFile = (Get-FileHash $Response.Detail.BackupPath -Algorithm MD5).Hash
			# Logging to backup history (sucessful)		
			$sqlParams = $null
			$sqlParams = @{
				database_name = $database
				backup_type = $Type
				backup_file_name = $response.Detail.BackupFile
				backup_file_path = $response.Detail.BackupFolder
				backup_file_hash = $HashFile
				backup_start_date = ([System.TimeZoneInfo]::ConvertTime($response.Detail.Start, $tz)).AddHours(-$tz.BaseUtcOffset.TotalHours)
				backup_end_date = ([System.TimeZoneInfo]::ConvertTime($response.Detail.End, $tz)).AddHours(-$tz.BaseUtcOffset.TotalHours)
				status = 0
				error_message = $null
			}
			Invoke-DbaQuery @dbParams -Query $backupSetting.backup_history_insert_proc -SqlParameters $sqlParams -ErrorAction Stop
			
			$endTime = (Get-Date)
			#$slackMessage += 'Database *{0}* completed in *{1:hh} hour {1:mm} min {1:ss} sec*' -F $database, ($endTime - $startTime)
		}		
	}
}
# ======================================= SEND SLACK NOTIFICATIONS ======================================== #
if (($slackMessage | Measure-Object).Count -ne 0) {
	$slackTitle = '[BACKUP-{0}] {1}' -F $Type.ToUpper(), $ENV:COMPUTERNAME
	$slackContent = ""
	$slackMessage | ForEach-Object {
		$slackContent += $_
		$slackContent += " `n"
	}
	$params = @{
		WebhookUri  = $settings.slack_webhook_dc2
		Title       = $slackTitle
		Content     = $slackContent
		color		= "#bd2424"
	}
	Send-SlackWebhook @params
	# #bd2424 - Red, #24bd3e - Green
}