[CmdletBinding()] 
Param
(   
    [String] [Parameter(Mandatory = $true)]
    $ServerName,
    [String] [Parameter(Mandatory = $true)]
    $FwPort
)

$session = New-PSSession $ServerName
try {
    Invoke-Command -Session $session -Command {				
        ($using:FwPort).Split(",") | ForEach-Object {
            $FwPort = $_
            New-NetFirewallRule -DisplayName ("SQL {0}" -F $FwPort) -Direction Inbound -Protocol TCP -LocalPort $FwPort -Action Allow | Out-Null
        }
    }
}
catch {
    Write-Error "Error: $_"
}
$session | Remove-PSSession
