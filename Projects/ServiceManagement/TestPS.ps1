$SiteName = "ServiceMonitor"
$AppPoolName = "ServiceMonitor"
$ServerName = "LAMVT1FINTECH"
$WebAppPool = Invoke-Command -ComputerName $ServerName -ScriptBlock {
    Import-Module WebAdministration   

    $ResultSet = @{
                    WebState         = (Get-WebsiteState $using:SiteName).Value
                    AppPoolState     = (Get-WebAppPoolState $using:AppPoolName).Value
                }
    Write-Output ($ResultSet | ConvertTo-Json | ConvertFrom-Json)
}

$WebAppPool.PSComputerName