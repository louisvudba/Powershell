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
    # Check if filebeat service exists
    If ($IsUpdate -eq $False) {        
        Copy-Item -Path "$RootPath\Source\filebeat\filebeat.zip" -Destination "C:\filebeat.zip" -ToSession $Session
        Invoke-Command -Session $Session -Command {
            $service = Get-Service -Name filebeat -ErrorAction SilentlyContinue
            If ($service -eq $null) {
                Expand-Archive "C:\filebeat.zip" -DestinationPath C:\            
                & "C:\filebeat\install-service-filebeat.ps1" | Out-Null           
            }
            Remove-Item "C:\filebeat.zip"
        }
    }

    # Copy config 
    Copy-Item -Path "$RootPath\Source\filebeat\filebeat_$DC.yml" -Destination "C:\filebeat\filebeat.yml" -ToSession $Session   
    Invoke-Command -Session $Session -Command {
        $service = Get-Service -Name filebeat -ErrorAction SilentlyContinue
        If ($service) {
            If ($service.Status -ne "Running") { Start-Service filebeat -Verbose }
            Else {
                Stop-Service filebeat -Force
                do {
                    $service = Get-Service -Name filebeat -ErrorAction SilentlyContinue
                    Start-sleep -seconds 5
                } until ($service.status -eq 'stopped')
                Start-Service filebeat -Verbose
            }
        }
    }
	
    Write-Host ("{0}" -f $TargetServer)

} | Wait-RSJob | Receive-RSJob

Get-RSJob | Remove-RSJob