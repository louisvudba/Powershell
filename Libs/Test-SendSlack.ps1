[CmdletBinding()] 
Param
(   
    [Parameter()]
    [string]$WebhookUri       
    ,
    [Parameter()]
    [string]$Title	
    ,
    [Parameter()]
    [string]$Content	
)

$body = ConvertTo-Json @{
    pretext = $Title
    text = $Content
    color = "#24bd3e"
}
$params = @{
    Uri         =   $WebhookUri
    Method      =   "Post"
    Body        =   $body
    ContentType =   "application/json"
}

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
Invoke-WebRequest @params | Out-Null