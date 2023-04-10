[CmdletBinding()]
Param(    
    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]    
    [array]
    $Object
)
$rootPath = (Split-Path $MyInvocation.MyCommand.Path)
. $rootPath/Libs.ps1

function Invoke-ProcessSpecialCase {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True)]    
        [array]
        $Object # ServiceId list
    )
    
    Begin {
        $config = Get-Content $rootPath\config.json | ConvertFrom-Json
        $guid = New-Guid
        Write-Host "Guid: $guid"
        
        $ErrorActionPreference = "SilentlyContinue"
        
        $errorCount = 0
        $listId = @()
        $initScript = [scriptblock]::Create(". $PSScriptRoot/Libs.ps1")

        # Check if MonitorSite is pause or not
        $apiUrl = "$($config.RootUrl)/api_alert/Get?id=1"
        try {
            $AlertStatus = Invoke-WebRequest -Method GET -Uri $apiUrl -ContentType "application/json" | ConvertFrom-Json 
        }
        catch {        
            Write-Verbose $Error[0]
            Write-Host "Couldn't check alert Status"
            Exit
        }
        if ($AlertStatus.pause_status -eq "OFF") {
            Write-Host "Alert status is OFF"
            Exit
        }

        $apiUrl = "$($config.RootUrl)/api_service/GetList"        
        try {
            $list = Invoke-WebRequest -Method GET -Uri $apiUrl -ContentType "application/json" | ConvertFrom-Json 
        }
        catch {        
            Write-Verbose $Error[0]
        }
        
        $dataSet = $list.data | Where-Object { $Object -contains $_.id -AND $_.specialCase -eq 1 -AND $_.enable -eq 1 } `
                    | Select-Object Id, Url, groupTag, Status, @{Name = 'IpAddress'; Expression = { ($_.Url.Split("/")[2]).Split(":")[0] } }`
                                            , @{Name='Port';Expression={($_.Url.Split("/")[2]).Split(":")[1]}}
        $dtStart = [datetime]::UtcNow
    }
    Process {        
        if (($dataSet | Measure-Object).Count -gt 0)
        {               
            $scriptBlock = [scriptblock] `
            {                    
                param($data, $config, $guid)
                $temp = "" | Select-Object Id, Object, Port, CheckType, Status, Notes, CurrStatus
                try {   
                    $response = switch ($data.groupTag) {
                        "API" {
                            Test-HealthCheck -Object $data.url -GroupTag $data.groupTag
                            break
                        }
                        default {                    
                            Test-HealthCheck -Object $data.IpAddress -Port $data.Port -GroupTag $data.groupTag
                            break
                        }
                    }                    
                    
                    $temp.Id = $data.Id
                    $temp.CurrStatus = $data.Status
                    $temp.Object = $response[0].Object
                    $temp.Port = $response[0].Port    
                    $temp.CheckType = $data.groupTag
                    $temp.Status = $response[0].Status
                    $temp.Notes = $response[0].Notes   
                }
                catch {
                    Write-Verbose "$($Error[0]) = $($data.Url)"                    
                }
                $temp
            }
            
            $jobs = $dataSet | ForEach-Object {
                $params = ($_, $config, $guid)
                Start-ThreadJob -ThrottleLimit $(($dataSet | Measure-Object).Count) -ArgumentList $params -ScriptBlock $scriptBlock `
                    -InitializationScript $initScript
            }
            Write-Verbose "Waiting for $(($jobs | Measure-Object).Count) jobs to complete..."
            
            $report = Receive-Job -Job $jobs -Wait -AutoRemoveJob
            Write-Verbose "RESULT..."
            $report | Select-Object | Format-Table  | Out-String | Write-Verbose
        }
    }
    End {
        if (($dataSet | Measure-Object).Count -gt 0) 
        {
            Write-Host "Total time elapsed: $([datetime]::UtcNow - $dtStart)"
            $uri = "{0}/api/UpdateHealthCheckSpecialCase?serviceId={1}&jGuid={2}&status=START&url=N" -f $config.RootUrl,$_.Id,$guid
            Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json" | Out-Null  
            
            $report | ForEach-Object {
                try {
                    
                    $uri = "{0}/api/UpdateHealthCheckSpecialCase?serviceId={1}&jGuid={2}&status={3}&url={4}" `
                            -f $config.RootUrl,$_.Id,$guid,$(if ($_.Status) { "OK" } else { "ERROR" }),`
                            $(if ($_.CheckType -eq "API") { $_.Object } else { $_.Object + ":" + $_.Port })
                
                    Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json" | Out-Null
                    Write-Verbose $_.Id

                    if ($_.Status -AND $_.CurrStatus -eq 0) { $listId += $_.Id }
                }
                catch {
                    Write-Verbose $Error[0]        
                }
                if ($_.Status -eq $False) { $errorCount += 1}
            }
            $uri = "{0}/api/UpdateHealthCheckSpecialCase?serviceId={1}&jGuid={2}&status=END&url=N" -f $config.RootUrl,$_.Id,$guid
            Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json" | Out-Null 

            if ($errorCount -gt 0) {
                try {
                    $uri = "{0}/api/SendAlert?jGuid={1}" -f $config.RootUrl,$guid
                    Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json" | Out-Null
                }
                catch {
                    Write-Verbose $Error[0]   
                }    
            }
            if (($listId | Measure-Object).Count -gt 0) {            
                $uri = "{0}/api/SendStatusChangedAlert?jGuid={1}&listId={2}" -f $config.RootUrl, $guid, $($listId -join ",")
                try {                
                    Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json" | Out-Null
                }
                catch {
                    Write-Verbose $Error[0]   
                }    
            }
        }
    }
}

function Invoke-ProcessCommonCaseAsync { 
    Begin
    {
        # Init
        $config = Get-Content $rootPath\config.json | ConvertFrom-Json
        $guid = New-Guid
        Write-Host "Guid: $guid"

        $db = Connect-DbaInstance -SqlInstance $config.SqlInstance
        
        $ErrorActionPreference = "SilentlyContinue"
        $errorCount = 0
        $listId = @()
        $initScript = [scriptblock]::Create(". $PSScriptRoot/Libs.ps1")

        # Check if MonitorSite is pause or not        
        try {
            $query = "SELECT * FROM dbo.AlertConfig WHERE Id = 1"
            $dataSet = Invoke-DbaQuery -Query $query -SqlInstance $db -Database $config.Database -ErrorAction Stop `
            | Select-Object Id, PauseStatus            
        }
        catch {                    
            Write-Verbose $Error[0]
            Write-Host "Couldn't check alert status"
            Exit
        }
        if (($dataSet | Measure-Object).Count -gt 0) {
            if ($dataSet[0].PauseStatus -eq 1) {
                Write-Host "Couldn't check alert status"
                Exit
            }
        }
        else {
            Write-Host "Couldn't check alert status"
            Exit
        }


        $query = "SELECT s.Id, s.Url, g.Tag, s.Status
                FROM dbo.[Services] s 
                    LEFT JOIN dbo.Groups g ON s.GroupId = g.Id                     
                WHERE s.Enable = 1 AND s.SpecialCase = 0"
        $dataSet = Invoke-DbaQuery -Query $query -SqlInstance $db -Database $config.Database -ErrorAction Stop `
                    | Select-Object Id, Url, Tag, Status, @{Name = 'IpAddress'; Expression = { ($_.Url.Split("/")[2]).Split(":")[0] } }`
                                            , @{Name='Port';Expression={($_.Url.Split("/")[2]).Split(":")[1]}}

        $dataSet | Format-Table | Write-Verbose
        $dtStart = [datetime]::UtcNow
        Write-Verbose "START: $($dtStart)"

        $query = "INSERT dbo.ServicesLog (JournalGuid, ServiceId, ServiceUrl, ServiceStatus) VALUES ('$guid', 0, '', 'START')"
        Invoke-DbaQuery -Query $query -SqlInstance $db -Database $config.Database -ErrorAction Stop 

        Write-Host "# Init: $([datetime]::UtcNow - $dtStart)"
        $query = ""
    }
    Process
    {              
        if (($dataSet | Measure-Object).Count -gt 0) 
        {    
            $scriptBlock = [scriptblock] `
            {    
                param($data, $config, $guid)
                $temp = "" | Select-Object Id, Object, Port, CheckType, Status, Notes, CurrStatus
                try {
                    $response = switch ($data.Tag) {
                        "API" {
                            Test-HealthCheck -Object $data.Url -GroupTag $data.Tag
                            break
                        }
                        default {                    
                            Test-HealthCheck -Object $data.IpAddress -Port $data.Port -GroupTag $data.Tag
                            break
                        }
                    } 
                    
                    $temp.Id = $data.Id
                    $temp.CurrStatus = $data.Status
                    $temp.Object = $response[0].Object
                    $temp.Port = $response[0].Port    
                    $temp.CheckType = $data.Tag
                    $temp.Status = $response[0].Status
                    $temp.Notes = $response[0].Notes   
                }
                catch {
                    Write-Verbose "$($Error[0]) = $($data.Url)"                    
                }                
                $temp
            }
            
            $jobs = $dataSet | ForEach-Object { 
                $params = ($_, $config, $guid)
                Start-ThreadJob -ThrottleLimit $(($dataSet | Measure-Object).Count) -ArgumentList $params -ScriptBlock $scriptBlock `
                    -InitializationScript $initScript
            }

            Write-Verbose "Waiting for $(($jobs | Measure-Object).Count) jobs to complete..."
            
            $report = Receive-Job -Job $jobs -Wait -AutoRemoveJob
            Write-Verbose "RESULT..." 
            $report | Select-Object | Format-Table  | Out-String | Write-Verbose
            Write-Host "# Test: $([datetime]::UtcNow - $dtStart)"
            try {
                #$scope = New-Object -TypeName System.Transactions.TransactionScope
                
                $report | ForEach-Object {
                    $item = $_ | ConvertTo-Json -Depth 2 | ConvertFrom-Json

                    $query += "INSERT dbo.ServicesLog (JournalGuid, ServiceId, ServiceUrl, ServiceStatus) 
                            VALUES ('$Guid', $($item.Id), '$(if ($item.CheckType -eq "API") { $item.Object } else { $item.Object + ":" + $item.Port })', '$(if ($item.Status) { "OK"} else { "ERROR" })')
                    "                    
                    
                    $query += "UPDATE dbo.Services SET Status = $(if ($item.Status) { 1 } else { 0 }), UpdatedTime = SYSDATETIMEOFFSET() WHERE Id = $($item.Id)
                    "                    

                    if ($item.status -eq $False) { $errorCount += 1 }
                    elseif ($item.CurrStatus -eq 0) { $listId += $item.Id }                     
                }
            }
            catch {
                $_.exception.message
            }
            finally {
                #$scope.Complete();
                #$scope.Dispose() 
            }
            Invoke-DbaQuery -Query $query -SqlInstance $db -Database $config.Database -ErrorAction Stop
            Write-Host "# Update data: $([datetime]::UtcNow - $dtStart)"          
        }  
    }
    End {           
        $query = "INSERT dbo.ServicesLog (JournalGuid, ServiceId, ServiceUrl, ServiceStatus) VALUES ('$guid', 0, '', 'END')"
        Invoke-DbaQuery -Query $query -SqlInstance $db -Database $config.Database -ErrorAction Stop        
        Write-Host "Total time elapsed: $([datetime]::UtcNow - $dtStart)"
        if ($errorCount -gt 0) {
            try {                
                $uri = "{0}/api/SendAlert?jGuid={1}" -f $config.RootUrl,$guid
                Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json" | Out-Null
            }
            catch {
                Write-Verbose $Error[0]   
            }    
        }
        if (($listId | Measure-Object).Count -gt 0){            
            $uri = "{0}/api/SendStatusChangedAlert?jGuid={1}&listId={2}" -f $config.RootUrl, $guid, $($listId -join ",")
            try{                
                Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json" | Out-Null
            }
            catch {
                Write-Verbose $Error[0]   
            }    
        }
    }    
}

if ($Object) {    
    Invoke-ProcessSpecialCase -Object $Object
}
else {
    Invoke-ProcessCommonCaseAsync
}