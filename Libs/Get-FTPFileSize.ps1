[CmdletBinding()]
Param
(   
    [Parameter()]     
    [string]$RemoteFile
    ,
    [Parameter()]     
    [System.Net.NetworkCredential]$FtpCredential
)

$Warning = "" | Select-Object Error, Detail

try {
    $Request =[System.Net.WebRequest]::Create($RemoteFile)
    $Request.Credentials = $FtpCredential
    $Request.Method =[System.Net.WebRequestMethods+Ftp]::GetFileSize 
    $Request.UseBinary = $true
    $Request.UsePassive = $true

    $Response = $Request.GetResponse()
    $Status = $Response.ContentLength
    $Response.Close()
            
    $Warning.Error = 0
    $Warning.Detail = $Status
}
catch {
    $Warning.Error = 2
    $Warning.Detail = $_.Exception.Message
}

Write-Output $Warning