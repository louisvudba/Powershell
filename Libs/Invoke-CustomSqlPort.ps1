[CmdletBinding()] 
Param
(   
    [String] [Parameter(Mandatory = $true)]
    $ServerName,
    [String] [Parameter(Mandatory = $true)]
    $TcpPort
)

$session = New-PSSession $ServerName

try {
    Invoke-Command -Session $session -Command { 
        Import-Module SQLPS -DisableNameChecking -Force
        
        $Wmi = New-Object ('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer') $env:COMPUTERNAME
        $uri = "ManagedComputer[@Name='$env:COMPUTERNAME']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"

        $Tcp = $wmi.GetSmoObject($uri)
        $Tcp.IsEnabled = $true
        $wmi.GetSmoObject($uri + "/IPAddress[@Name='IPAll']").IPAddressProperties[1].Value= $using:TcpPort
        $Tcp.Alter()				

        Restart-Service MSSQLSERVER -Force
    }
}
catch {
    Write-Error "Error: $_"
}

$session | Remove-PSSession
