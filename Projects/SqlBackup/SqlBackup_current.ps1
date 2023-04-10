# ENTRY POINT MAIN()
Param(
    [Parameter(Mandatory, HelpMessage = "Backup Type: F - Full, D - Differential, L - Log")]
    [ValidateSet("F", "D", "L")]
    [string]$Type
)

Try {
    Import-Module G:\DBA\Modules/BackupDatabase -ErrorAction Stop
}
Catch {
    $_.Exception.Message
    Write-Verbose "BackupDatabase module not installed!"
    Break
}
Try {
    Import-Module G:\DBA\Modules/FtpLibs -ErrorAction Stop
}
Catch {
    $_.Exception.Message
    Write-Verbose "FtpLibs module not installed!"
    Break
}

$Config = Get-Content "$(Split-Path $MyInvocation.MyCommand.Path)\config_current.json" | ConvertFrom-Json

$backupConfig = $Config.backup_config
$historyConfig = $Config.history_config
$mailConfig = $Config.mail_config
$ftpConfig = $Config.ftp_config


# Backup split multi files
$ReplaceInName = $false
$FileCount = 1 # count of files

# Create Credential
$isCredential = $False
try {
    $SecurePassword = ConvertTo-SecureString $backupConfig.sql_password -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($backupConfig.sql_login, $SecurePassword)
    $isCredential =$true
}
catch {
    $isCredential = $false
    Write-Verbose -Message "Using Windows authentication"
}

# Backup Database
$backupConfig.databases | ForEach-Object {	
	$startTime = (Get-Date)
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
	$endTime = (Get-Date)
	'Duration: {0:mm} min {0:ss} sec' -f ($endTime-$startTime)

	# Init SQL Var
	$password = ConvertTo-SecureString $historyConfig.sql_password -AsPlainText -Force
	$sqlCred = New-Object System.Management.Automation.PSCredential ($historyConfig.sql_login, $password)

	$params = @{
		SqlInstance = $historyConfig.sql_instance
		Database = $historyConfig.database
		SqlCredential = $sqlCred
		Query = "sp_BackupHistory_Insert"   
		CommandType = "StoredProcedure"
	}
	
	# Check Error
	if ($Response.Error -ne 0) {
        $password = ConvertTo-SecureString $mailConfig.pass -AsPlainText -Force
        $mailCred = New-Object System.Management.Automation.PSCredential ($mailConfig.user, $password)

        $sendMailParams = @{
            From = $mailConfig.from
            To = $mailConfig.to.Split(";")
            Subject = $mailConfig.subject
            BodyAsHtml = $True
            Body = $mailConfig.body -Replace "1", $_ -Replace "2", $Response.Detail
            Encoding = "UTF8"
            SMTPServer = $mailConfig.server
            Port = $mailConfig.port
            UseSsl = $True
            Credential = $mailCred
        }
		Send-MailMessage @sendMailParams -EA Stop;
		
		$QueryParameters = @{
			database_name = $_
			backup_type = $Type		
			backup_start_date = $startTime
			backup_end_date = $endTime			
			status = $Response.Error
			error_message = $Response.Detail			
		}
		Invoke-DbaQuery @params -SqlParameters $QueryParameters -ErrorAction Stop | Out-Null
		break
	}
	$HashFile = (Get-FileHash $Response.Detail.BackupPath -Algorithm MD5).Hash
	# Logging to backup history (sucessful)
	$QueryParameters = @{
		database_name = $_
		backup_type = $Type
		backup_file_name = $Response.Detail.BackupFile
		backup_file_path = $Response.Detail.BackupFolder
		backup_file_hash = $HashFile
		backup_start_date = $Response.Detail.Start
		backup_end_date = $Response.Detail.End
		status = 0
		error_message = $null		
	}
	$backupHistory = Invoke-DbaQuery @params -SqlParameters $QueryParameters -ErrorAction Stop

	# Logging start uploading
	$params.Query = "sp_BackupHistory_Update"
	$RemoteFile = "ftp://{0}:{1}@{2}/{3}" -F $ftpConfig.user, $ftpConfig.pass, $ftpConfig.server, $Response.Detail.BackupFile

	$QueryParameters = $null
	$QueryParameters = @{
		id = $backupHistory.id		
		ftp_status = 1
		ftp_file_path = $RemoteFile	
	}
	Invoke-DbaQuery @params -SqlParameters $QueryParameters -ErrorAction Stop | Out-Null

	# try ftp
	$uploadResult = Move-FTP -LocalFile $Response.Detail.BackupPath -RemoteFile $RemoteFile
		
	$QueryParameters = $null
	$QueryParameters = @{
		id = $backupHistory.id		
		ftp_status = if ($uploadResult.Error -eq 0) { 2 } else { $uploadResult.Error }
		error_message = if ($uploadResult.Error -eq 0) { $null } else { $uploadResult.Detail }
	}
	Invoke-DbaQuery @params -SqlParameters $QueryParameters -ErrorAction Stop | Out-Null

	if ($uploadResult.Error -eq 0) {
		$verifyResult = Get-FileSize -RemoteFile $RemoteFile
		if (($verifyResult.Error -eq 0) -and ($verifyResult.Detail = (Get-Item $Response.Detail.BackupPath).Length)) {			
			try {
				$verify_file_size = $True
				Remove-Item $Response.Detail.BackupPath | Out-Null
			}
			catch {
				Write-Verbose "Delete file error"
				$verify_file_size = $False				
			}
		}
		else {			
			$verify_file_size = $False
		}

		$QueryParameters = $null
		$QueryParameters = @{
			id = $backupHistory.id		
			ftp_status = 2
			verify_file_size = $verify_file_size
		}
		Invoke-DbaQuery @params -SqlParameters $QueryParameters -ErrorAction Stop | Out-Null
	}
}