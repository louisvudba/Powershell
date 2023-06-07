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
        $Ports.Split(",") | ForEach-Object {  
            $FwPort = $_ 
            $FwRuleName = "SQL {0}" -F $FwPort
            If ($(Get-NetFirewallRule -DisplayName $FwRuleName | Get-NetPortFilter | Where-Object { $_.LocalPort -eq $FwPort }) -eq $null) {
                New-NetFirewallRule -DisplayName $FwRuleName -Direction Inbound -Protocol TCP -LocalPort $FwPort -Action Allow | Out-Null
            }            
        }
    }

} | Wait-RSJob | Receive-RSJob

Get-RSJob | Remove-RSJob