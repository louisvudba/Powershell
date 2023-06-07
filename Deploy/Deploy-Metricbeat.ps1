Param(
    [Parameter(mandatory=$false)][string]$TargetServer,
    [Parameter(mandatory=$false)][switch]$IsUpdate = $false
)

Import-Module -Name PoshRSJob

$RootPath = "G:\DBA"
$ServerPath = "$RootPath\Config\dbservers.csv"
$ServerList = @()
if ($TargetServer) {
    $ServerList += ([PSCustomObject]@{
            ServerName = $TargetServer
            DBName = $DatabaseName
        })
}
else {$ServerList = Import-Csv $ServerPath -Delimiter ","}

$Params = ($RootPath,$IsUpdate)
$ServerList | Start-RSJob -Throttle $(($ServerList | Measure-Object).Count) -ArgumentList $Params -ScriptBlock {
    Param($RootPath,$IsUpdate)
    $TargetServer = $_.ServerName   
    $Session = New-PSSession $TargetServer
    If ($TargetServer -like "10-12*") { $DC = "DC1" } else { $DC = "DC2" }
    # Check if metricbeat service exists
    If ($IsUpdate -eq $False) {        
        Copy-Item -Path "$RootPath\Source\Metricbeat\metricbeat.zip" -Destination "C:\metricbeat.zip" -ToSession $Session
        Invoke-Command -Session $Session -Command {
            $service = Get-Service -Name metricbeat -ErrorAction SilentlyContinue
            If ($service -eq $null) {
                Expand-Archive "C:\metricbeat.zip" -DestinationPath C:\            
                & "C:\metricbeat\install-service-metricbeat.ps1" | Out-Null           
            }
            Remove-Item "C:\metricbeat.zip"
        }
    }

    # Copy config 
    Copy-Item -Path "$RootPath\Source\Metricbeat\metricbeat_$DC.yml" -Destination "C:\metricbeat\metricbeat.yml" -ToSession $Session
    Copy-Item -Path "$RootPath\Source\Metricbeat\sql.yml" -Destination "C:\metricbeat\modules.d\sql.yml" -ToSession $Session
    Invoke-Command -Session $Session -Command {
        $service = Get-Service -Name metricbeat -ErrorAction SilentlyContinue
        If ($service) {
            If ($service.Status -ne "Running") { Start-Service metricbeat -Verbose }
            Else {
                Stop-Service metricbeat -Force
                do {
                    $service = Get-Service -Name metricbeat -ErrorAction SilentlyContinue
                    Start-sleep -seconds 5
                } until ($service.status -eq 'stopped')
                Start-Service metricbeat -Verbose
            }
        }
    }
	
    Write-Host ("{0}" -f $TargetServer)

} | Wait-RSJob | Receive-RSJob

Get-RSJob | Remove-RSJob