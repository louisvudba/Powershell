[CmdletBinding()] 
Param
(          
    [Parameter()]
    [string]$FolderPath
    ,
    [Parameter()]
    [System.Net.NetworkCredential]$FtpCredential
)

$Warning = "" | Select-Object Error, Detail

try {
    $request = [System.Net.WebRequest]::Create($FolderPath)            
    $request.Credentials = $FtpCredential
    $request.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory
    $response = $request.GetResponse();
            
    $Warning.Error = 0
    $Warning.Detail = $response
}
catch {
    try {

        #if there was an error returned, check if folder already existed on server
        $request = [System.Net.WebRequest]::Create($FolderPath)
        $request.Credentials = $FtpCredential
        $request.Method = [System.Net.WebRequestMethods+FTP]::PrintWorkingDirectory
        $response = $request.GetResponse()

        $Warning.Error = 0
        $Warning.Detail = $response
    }
    catch [Net.WebException] {				
        $Warning.Error = 1
        $Warning.Detail = $_.Exception.Message
    }            
}

Write-Output $Warning