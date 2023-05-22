[CmdletBinding()]
Param
(   
    [Parameter()]
    [string]$Server
    ,
    [Parameter()]
    [string]$LocalFile
    ,
    [Parameter()]
    [string]$FileName
    ,
    [Parameter()]
    [string]$RemotePath
    ,
    [Parameter()]
    [string]$UserName
    ,
    [Parameter()]
    [System.Security.SecureString]$SecuredPassword
    ,
    [Parameter()]
    [string]$FingerPrint
)

# Load WinSCP .NET assembly
#$assemblyPath = if ($env:WINSCP_PATH) { $env:WINSCP_PATH } else { $PSScriptRoot }
#Add-Type -Path (Join-Path $assemblyPath "WinSCPnet.dll")
Add-Type -Path "${env:ProgramFiles(x86)}\WinSCP\WinSCPnet.dll"

$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Sftp
    HostName = $Server
    UserName = $UserName
    SecurePassword = $SecuredPassword
    SshHostKeyFingerprint = $FingerPrint
}
$FilePath = "{0}{1}" -F $RemotePath, $FileName
$Warning = "" | Select-Object Error, Detail

try
{
    $session = New-Object WinSCP.Session
    # Connect
    $session.Open($sessionOptions)

    $FileInfo = $session.GetFileInfo($FilePath)
    
    $Warning.Error = 0
    $Warning.Detail = $FileInfo.Length
}
catch {
    $Warning.Error = 1
    $Warning.Detail = $_.Exception.Message
}
finally
{
    # Disconnect, clean up
    $session.Dispose()
}
    
Write-Output $Warning