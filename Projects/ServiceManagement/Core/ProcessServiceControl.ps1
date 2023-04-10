[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]    
    [System.Int32]
    $ServerNo
    ,
    [Parameter(Mandatory = $true)]    
    [ValidateRange(1,2)]
    [System.Int32]
    # 1: Service, 2: Web
    $Type
    ,
    [Parameter(Mandatory = $false)]    
    [System.Int32]
    $ServiceNo = -1
    ,
    [Parameter(Mandatory = $false)]    
    [System.Int32]
    $SiteNo = -1
    ,
    [Parameter(Mandatory = $true)]    
    [System.String]
    $Action
)

$rootPath = (Split-Path $MyInvocation.MyCommand.Path)
Import-Module $rootPath/Modules/ServiceControl



function Invoke-ExecuteScript {
    Param([int]$ServerNo, [int]$Type, [int]$ServiceNo, [int]$SiteNo, [string]$Action)

    function Open-ServicesScript {
        Param([int]$srv, [int]$sv, [string]$act)

        $rootPath = (Split-Path $MyInvocation.MyCommand.Path)
        $jsonData = (Get-Content -Raw -Path $rootPath\Config.json | ConvertFrom-Json)

        if ($srv -eq 0) {       
            if ($sv -eq 0) {
                ForEach ($serv in $jsonData) {
                    ForEach ($item in $serv.services) {
                        Invoke-ServiceControl -ServerName $serv.name -Type 1 -ServiceName $item.name -Action $act
                    }
                }
            }
            else {
                ForEach ($serv in $jsonData) {
                    ForEach ($item in $serv.services) {
                        if ($sv -eq $item.id) {
                            Invoke-ServiceControl -ServerName $serv.name -Type 1 -ServiceName $item.name -Action $act
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
                            Invoke-ServiceControl -ServerName $serv.name -Type 1 -ServiceName $item.name -Action $act
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
                                Invoke-ServiceControl -ServerName $serv.name -Type 1 -ServiceName $item.name -Action $act
                                break
                            }                        
                        }                        
                    }
                }
            } 
        }    
    }

    function Open-IISScript {
        Param([int]$srv, [int]$w, [string]$act)
        
        $rootPath = $PSScriptRoot
        $jsonData = (Get-Content -Raw -Path $rootPath\Config.json | ConvertFrom-Json)
        
        if ($srv -eq 0) { 
            if ($w -eq 0) {
                ForEach ($serv in $jsonData) {
                    ForEach ($item in $serv.iis) {					
                        Invoke-ServiceControl -ServerName $serv.name -Type 2 -SiteName $item.name -AppPoolName $item.pool -Action $act
                    }
                }
            }
            else {
                ForEach ($serv in $jsonData) {
                    ForEach ($item in $serv.iis) {
                        if ($w -eq $item.id) {
                            Invoke-ServiceControl -ServerName $serv.name -Type 2 -SiteName $item.name -AppPoolName $item.pool -Action $act
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
                            Invoke-ServiceControl -ServerName $serv.name -Type 2 -SiteName $item.name -AppPoolName $item.pool -Action $act
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
                                Invoke-ServiceControl -ServerName $serv.name -Type 2 -SiteName $item.name -AppPoolName $item.pool -Action $act
                                break
                            }
                        }
                    }
                }
            }
        }    
    }

    switch ($Type) {
        1 { Open-ServicesScript $ServerNo $ServiceNo $Action }
        2 { Open-IISScript $ServerNo $SiteNo $Action }
        Default { Write-Host "Do nothing" }
    }   
}


Invoke-ExecuteScript -ServerNo $ServerNo -Type $Type -ServiceNo $ServiceNo -SiteNo $SiteNo -Action $Action