$rootPath = (Split-Path $MyInvocation.MyCommand.Path)

function Update-ServiceStatus {
    Param([string]$server,[string]$service,[string]$a)
    #Initialize variables:
    $WaitForIt = ""
    $Verb = ""
    $Result = "FAILED"
    $svc = (get-service -computername $server -name $service)

    Write-Host ""
    Write-Host "===================================================="
    Write-Host "SERVER: $server"
    Write-Host "SERVICE: $service"
    Write-host "STATUS: $($svc.status)"

    Switch ($svc.status) {
        'Stopped' {
            if ($a -eq "START") {
                Write-host "STARTING ..."
                $Verb = "start"
                $WaitForIt = 'Running'
                $svc.Start()
            }
        }
        'Running' {
            if ($a -eq "STOP") {
                Write-host "STOPPING ..."
                $Verb = "stop"
                $WaitForIt = 'Stopped'
                $svc.Stop()
            }
        }
        Default {
            Write-host "$service is $($svc.status).  Taking no action."}
    }
    if ($WaitForIt -ne "") {
        Try {  # For some reason, we cannot use -ErrorAction after the next statement:
            $svc.WaitForStatus($WaitForIt,'00:02:00')
        } Catch {
            Write-host "After waiting for 2 minutes, $sv failed to $Verb."
        }
        $svc = (get-service -computername $server -name $service)
        if ($svc.status -eq $WaitForIt) {$Result = 'SUCCESS'}
        Write-host "$Result"
    }
    Write-Host "===================================================="
    Write-Host ""
}
function Update-IISWebsiteStatus {        
    Param([string]$server,[string]$site,[string]$a)

    $WaitForIt = ""
    $iis = Invoke-Command -ComputerName $server -ScriptBlock {
        Import-Module WebAdministration
        Get-WebsiteState $using:site
    }

    Write-Host ""
    Write-Host "===================================================="
    Write-Host "SERVER: $server"
    Write-Host "SITE: $site"
    Write-host "STATUS: $($iis.value)"

    Switch ($iis.value) {
        'Stopped' {
            if ($a -eq "START") {
                Write-host "STARTING ..."
                $WaitForIt = "Started"               
                Invoke-Command -ComputerName $server -ScriptBlock {
                    Import-Module WebAdministration
                    Start-WebSite $using:site
                }
            }
        }
        'Started' {
            if ($a -eq "STOP") {
                Write-host "STOPPING ..."
                $WaitForIt = "Stopped"
                Invoke-Command -ComputerName $server -ScriptBlock {
                    Import-Module WebAdministration
                    Stop-WebSite $using:site
                }
            }
        }
        Default {
            Write-host "$site is $($iis.value).  Taking no action."}
    }
    $iis = Invoke-Command -ComputerName $server -ScriptBlock {
        Import-Module WebAdministration
        Get-WebsiteState $using:site
    }

    if ($WaitForIt -ne "") {
        start-sleep -s 5

        $iis = Invoke-Command -ComputerName $server -ScriptBlock {
            Import-Module WebAdministration
            Get-WebsiteState $using:site
        }
        
        if ($iis.value -eq $WaitForIt) { $Result = 'SUCCESS' }
        else { $Result = 'FAILED' }
        Write-host "$Result"
    }
    Write-Host "===================================================="
    Write-Host ""    
}

function Open-Script-Services {
    Param([int]$srv, [int]$sv, [string]$a)

    $jsonPath = "$rootPath\List.json";
    $initServiceScript = "$rootPath\InitServices.ps1";

    $jsonData = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json

    if ($srv -eq 0) {       
        if ($sv -eq 0) {
            ForEach ($serv in $jsonData) {
                ForEach ($item in $serv.services) {
                    & ($initServiceScript) $serv.name $item.name $a
                }
            }
        }
        else {
            ForEach ($serv in $jsonData) {
                ForEach ($item in $serv.services) {
                    if ($sv -eq $item.id) {
                        & ($initServiceScript) $serv.name $item.name $a
                        break
                    }
                }
            }
        }                
    }
    else {        
        if ($sv -eq 0) {
            ForEach ($serv in $jsonData) {
                if ($srv -eq $serv.id) {
                    ForEach ($item in $serv.services) {
                        & ($initServiceScript) $serv.name $item.name $a
                    }
                    break
                }
            }
        }
        else {
            ForEach ($serv in $jsonData) {				
                if ($srv -eq $serv.id) {
                    ForEach ($item in $serv.services) {
                        if ($sv -eq $item.id) {
                            & ($initServiceScript) $serv.name $item.name $a
                            break
                        }                        
                    }                        
                }
            }
        } 
    }    
}

function Open-Script-IIS {
    Param([int]$srv, [int]$w, [string]$a)
	
    $jsonPath = "$rootPath\List.json";    
    $initIISScript = "$rootPath\InitIIS.ps1";

    $jsonData = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json
    
    if ($srv -eq 0) { 
        if ($w -eq 0) {
            ForEach ($serv in $jsonData) {
                ForEach ($item in $serv.iis) {					
                    & ($initIISScript) $serv.name $item.name $a
                }
            }
        }
        else {
            ForEach ($serv in $jsonData) {
                ForEach ($item in $serv.iis) {
                    if ($w -eq $item.id) {
                        & ($initIISScript) $serv.name $item.name $a
                        break
                    }
                }
            }
        }
    }
    else { 		
        if ($w -eq 0) {
            ForEach ($serv in $jsonData) {
                if ($srv -eq $serv.id) {
                    ForEach ($item in $serv.iis) {
                        & ($initIISScript) $serv.name $item.name $a
                    }
                    break
                }
            }
        }
        else {
            ForEach ($serv in $jsonData) {				
                if ($srv -eq $serv.id) {				
                    ForEach ($item in $serv.iis) {						
                        if ($w -eq $item.id) {
                            & ($initIISScript) $serv.name $item.name $a
                            break
                        }
                    }
                }
            }
        }
    }    
}