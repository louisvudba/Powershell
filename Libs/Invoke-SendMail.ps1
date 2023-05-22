[CmdletBinding()]
param (
    [PSCustomObject]$MailSetting, 
    [string]$Subject,
    [string]$Body,
    [string]$SecretKeyPath,
    [string]$PrivateKeyPath
)

<#
{
    "smtp_server": "email-smtp.ap-southeast-1.amazonaws.com",
    "smtp_port": 587,
    "smtp_ssl": true,
    "from": "",
    "to": "",
    "encoding": "UTF8",
    "body_as_html": true,
    "aws_access_key": "",
    "aws_secret_key": ""
}
#>

$AWS_ACCESS_KEY = $MailSetting.aws_access_key
$AWS_SECRET_KEY = $MailSetting.aws_secret_key
#$AWS_SECRET_KEY = Get-Content -Path $SecretKeyPath | ConvertTo-SecureString -Key $PrivateKey
$AWS_CREDENTIAL = New-Object System.Management.Automation.PSCredential($AWS_ACCESS_KEY, $AWS_SECRET_KEY)
$MessageParameters = @{
    From = $MailSetting.from
    To = $MailSetting.to.Split(";")
    Subject = $Subject
    BodyAsHtml = $MailSetting.body_as_html
    Body = $Body
    Encoding = $MailSetting.encoding
    SMTPServer = $MailSetting.smtp_server
    Port = $MailSetting.smtp_port
    UseSsl = $MailSetting.smtp_ssl
    Credential = $AWS_CREDENTIAL
}
$Response = @()

$tmp = "" | Select-Object Error, Detail
try {
    $tmp.Error = 0
    $tmp.Detail = $null
    Send-MailMessage @MessageParameters -EA Stop;        
}
catch { 
    $tmp.Error = 1
    $tmp.Detail = $_.Exception.Message
}
$Response += $tmp
    
Write-Output $Response