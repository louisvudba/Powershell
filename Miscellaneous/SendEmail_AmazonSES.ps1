$SMTP_SERVER = ""
$SMTP_PORT = ""
$SMTP_SSL = $True # If using SSL

$AWS_ACCESS_KEY = "" # "AAAAAAAAAAAAAAAAAAAA"
$AWS_SECRET_KEY  = "" # "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

$HASH_PASSWORD = ConvertTo-SecureString $AWS_SECRET_KEY -AsPlainText -Force
$SMTP_CREDENTIAL = New-Object System.Management.Automation.PSCredential ($AWS_ACCESS_KEY, $AWS_SECRET_KEY)

$FROM = ""
$TO = "" # List of Email split by ';'
$Subject = ""
$Body = ""
$Encoding = "UTF-8"
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