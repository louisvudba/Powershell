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
    $request = [System.Net.FtpWebRequest]::Create($RemoteFile)
    $request.Credentials = $FtpCredential
    $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $request.UsePassive = $True

    $fileStream = [System.IO.File]::OpenRead($LocalFile)
    $ftpStream = $request.GetRequestStream()

    $fileStream.CopyTo($ftpStream)

    $ftpStream.Dispose()
    $fileStream.Dispose()
            
    $Warning.Error = 0
    $Warning.Detail = $null
}
catch {
    $Warning.Error = 1
    $Warning.Detail = $_.Exception.Message			
}

Write-out $Warning