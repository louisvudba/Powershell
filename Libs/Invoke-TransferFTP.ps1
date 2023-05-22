[CmdletBinding()] 
Param
(   
    [Parameter()]
    [string]$LocalFile
    ,
    [Parameter()]
    [string]$RemoteFile
    ,
    [Parameter()]
    [System.Net.NetworkCredential]$FtpCredential
)

$Warning = "" | Select-Object Error, Detail

try {			
    $webclient = New-Object System.Net.WebClient
    $uri = New-Object System.Uri($RemoteFile)
        
    $webclient.Credentials = $FtpCredential
    $webclient.UploadFile($uri, $LocalFile)
            
    $Warning.Error = 0
    $Warning.Detail = $null
}
catch {
    $Warning.Error = 1
    $Warning.Detail = $_.Exception.Message
    Write-Error ($_.Exception.Message)
}

Write-Output $Warning