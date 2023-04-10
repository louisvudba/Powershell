$SMTP_SERVER = ""
$SMTP_PORT = ""
$SMTP_SSL = $True # If using SSL

$USERNAME = ""
$PASSWORD = ""

$HASH_PASSWORD = ConvertTo-SecureString $PASSWORD -AsPlainText -Force
$SMTP_CREDENTIAL = New-Object System.Management.Automation.PSCredential ($USERNAME, $HASH_PASSWORD)

$FROM = ""
$TO = "" # List of Email split by ';'
$Subject = ""
$Body = ""
$Encoding = "UTF8"
$BodyAsHtml = $True # Send body with html


$SendMailParams = @{
    From = $FROM
    To = $TO.Split(";")
    Subject = $Subject
    BodyAsHtml = $BodyAsHtml
    Body = $Body
    Encoding = $Encoding
    SMTPServer = $SMTP_SERVER
    Port = $SMTP_PORT
    UseSsl = $SMTP_SSL
    Credential = $SMTP_CREDENTIAL
}

Send-MailMessage @sendMailParams -EA Stop;