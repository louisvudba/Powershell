function Move-FTP {    
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
		$Warning.Error = -1
		$Warning.Detail = $_.Exception.Message
	}	
	$Warning	
}
function Get-FileSize{
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
		$Warning.Error = -2
		$Warning.Detail = $_.Exception.Message
	}
	$Warning
}

function Move-ToSharedFolder {
	Param
    (   
        [Parameter()]     
        [string]$LocalFile
        ,
        [Parameter()]     
        [string]$RemoteFile		
	)
	$Warning = "" | Select-Object Error, Detail
	try {		
		Copy-Item -Path $LocalFile -Destination $RemoteFile -Force
		$Warning.Error = 0		
	}
	catch {
		$Warning.Error = -1
		$Warning.Detail = $_.Exception.Message
	}	
	$Warning	
}