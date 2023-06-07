Param(
    [Parameter(mandatory=$true)][string]$TargetServer,
    [Parameter(mandatory=$true)][string]$Ports # Overwrite current dynamic port rules
)

Import-Module -Name PoshRSJob

$RootPath = "G:\DBA"
$ServerList = @([PSCustomObject]@{
    ServerName = $TargetServer
    Ports = $Ports
})

$Params = ($RootPath)
$ServerList | Start-RSJob -Throttle $(($ServerList | Measure-Object).Count) -ArgumentList $Params -ScriptBlock {
    Param($RootPath)
    $Session = New-PSSession $_.ServerName   
    Invoke-Command -Session $Session -ArgumentList $_.Ports -Command { 
        Param($Ports)
        Import-Module SQLPS -DisableNameChecking -Force
        
        $Wmi = New-Object ('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer') $env:COMPUTERNAME
        $uri = "ManagedComputer[@Name='$env:COMPUTERNAME']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"

        $Tcp = $wmi.GetSmoObject($uri)
        $Tcp.IsEnabled = $true
        $wmi.GetSmoObject($uri + "/IPAddress[@Name='IPAll']").IPAddressProperties[1].Value= $Ports
        $Tcp.Alter()

        Restart-Service MSSQLSERVER -Force
    }

} | Wait-RSJob | Receive-RSJob

Get-RSJob | Remove-RSJob