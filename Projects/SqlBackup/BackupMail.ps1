# Get Data
$instance = ""
$database = ""
$user = ""
$pass = ""

$password = ConvertTo-SecureString $pass -AsPlainText -Force
$sqlCred = New-Object System.Management.Automation.PSCredential ($user, $password)

$query = Get-Content "G:\DBA\getLatestHistory.sql" | Out-String

$dataset = Invoke-DbaQuery -Query $query -SqlCredential $sqlCred -SqlInstance $instance -Database $database -ErrorAction Stop

# Email
$Config = Get-Content "$(Split-Path $MyInvocation.MyCommand.Path)\config_current.json" | ConvertFrom-Json
$mailConfig = $Config.mail_config

$password = ConvertTo-SecureString $mailConfig.pass -AsPlainText -Force
$mailCred = New-Object System.Management.Automation.PSCredential ($mailConfig.user, $password)

$emailSubject = "[BACKUP] DB Backup Checklist"
$emailBody = "DB Backup Checklist<br/><br/>"
$emailBody += "<table><th><td>Database</td><td>FTP File Path</td><td>Latest Check Point</td></th>"
$dataset | ForEach-Object {
    $emailBody += "<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>" -F $_.database_name, $_.ftp_file_path,$_.latest_check_point
}
$emailBody += "</table>"
$sendMailParams = @{
    From = $mailConfig.from
    To = $mailConfig.to.Split(";")
    Subject = $emailSubject
    BodyAsHtml = $True
    Body = $emailBody
    Encoding = "UTF8"
    SMTPServer = $mailConfig.server
    Port = $mailConfig.port
    UseSsl = $True
    Credential = $mailCred
}
Send-MailMessage @sendMailParams  -EA Stop;