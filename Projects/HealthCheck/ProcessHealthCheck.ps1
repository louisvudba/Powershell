[CmdletBinding()]
Param(    
    [Parameter(Mandatory = $False, ValueFromPipeline = $True)]    
    [array]
    $Object    
)
$rootPath = (Split-Path $MyInvocation.MyCommand.Path)
$config = Get-Content $rootPath\config.json | ConvertFrom-Json

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
        $guid = New-Guid
        Write-Host "Guid: $guid"
        
        $ErrorActionPreference = "SilentlyContinue"
        
        $errorCount = 0
        $listId = @()
        $initScript = [scriptblock]::Create("Import-Module $($config.RootModulePath)/HealthCheck")

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
        $dtStart = [datetime]::UtcNow
        
        $dataSet = $list.data | Where-Object { $Object -contains $_.id -AND $_.specialCase -eq 1 -AND $_.enable -eq 1 } `
        | Select-Object Id, Url, groupTag, Status, NlbClusterId, @{Name = 'IpAddress'; Expression = { ($_.Url.Split("/")[2]).Split(":")[0] } }`
            , @{Name = 'Port'; Expression = { ($_.Url.Split("/")[2]).Split(":")[1] } }
        
        Write-Host "# Init: $([datetime]::UtcNow - $dtStart)"
    }
    Process {        
        if (($dataSet | Measure-Object).Count -gt 0) {               
            $scriptBlock = [scriptblock] `
            {
                param($data, $ref)
                $temp = "" | Select-Object Id, Url, IpAddress, Port, Tag, Status, Notes, CurrStatus, NlbClusterId
             
                $response = Invoke-HealthCheck -Url $data.Url -IpAddress $data.IpAddress -Port $data.Port -Tag $data.groupTag -Verbose:$ref

                $temp.Id = $data.Id
                $temp.CurrStatus = $data.Status	
                $temp.Url = $data.Url				
                $temp.IpAddress = $data.IpAddress
                $temp.Port = $data.Port   
                $temp.Tag = $data.groupTag
                $temp.NlbClusterId = $data.NlbClusterId				
                $temp.Status = $response.Status
                $temp.Notes = $response.Notes
								
                $temp
            }
            
            $jobs = $dataSet | ForEach-Object {
                $params = ($_, $VerbosePreference)
                Start-ThreadJob -ThrottleLimit $(($dataSet | Measure-Object).Count) -ArgumentList $params -ScriptBlock $scriptBlock `
                    -InitializationScript $initScript
            }
            Write-Verbose "Waiting for $(($jobs | Measure-Object).Count) jobs to complete..."
            
            $report = Receive-Job -Job $jobs -Wait -AutoRemoveJob
            Write-Verbose "RESULT..."
            $report | Format-Table | Out-String -Stream | Where-Object { $_ -ne "" } | Write-Verbose

            Write-Host "# Test: $([datetime]::UtcNow - $dtStart)"
        }
    }
    End {
        if (($dataSet | Measure-Object).Count -gt 0) {
            Write-Host "Total time elapsed: $([datetime]::UtcNow - $dtStart)"
            $uri = "{0}/api/UpdateHealthCheckSpecialCase?serviceId={1}&jGuid={2}&status=START&url=N" -f $config.RootUrl, $_.Id, $guid
            Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json" | Out-Null  
            
            $report | ForEach-Object {
                try {
                    
                    $uri = "{0}/api/UpdateHealthCheckSpecialCase?serviceId={1}&jGuid={2}&status={3}&url={4}" `
                        -f $config.RootUrl, $_.Id, $guid, $(if ($_.Status) { "OK" } else { "ERROR" }), `
                    $(if ($_.CheckType -eq "API") { $_.Object } else { $_.Object + ":" + $_.Port })
                
                    Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json" | Out-Null
                    Write-Verbose $_.Id

                    if ($_.Status -AND $_.CurrStatus -eq 0) { $listId += $_.Id }
                }
                catch {
                    Write-Verbose $Error[0]        
                }
                if ($_.Status -eq $False) { $errorCount += 1 }
            }
            $uri = "{0}/api/UpdateHealthCheckSpecialCase?serviceId={1}&jGuid={2}&status=END&url=N" -f $config.RootUrl, $_.Id, $guid
            Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json" | Out-Null 

            if ($errorCount -gt 0) {
                try {
                    $uri = "{0}/api/SendAlert?jGuid={1}" -f $config.RootUrl, $guid
                    Write-Host $uri
                    Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json"
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
    [cmdletbinding()]
    param()
    Begin {
        # Init        
        $guid = New-Guid
        Write-Host "Guid: $guid"

        $db = Connect-DbaInstance -SqlInstance $config.SqlInstance
        
        $ErrorActionPreference = "SilentlyContinue"
        $errorCount = 0
        $listId = @()
        $initScript = [scriptblock]::Create("Import-Module $($config.RootModulePath)/HealthCheck")

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

        $query = "SELECT s.Id, s.Url, g.Tag, s.Status, s.NlbClusterId
                FROM dbo.[Services] s 
                    LEFT JOIN dbo.Groups g ON s.GroupId = g.Id                     
                WHERE s.Enable = 1 AND s.SpecialCase = 0"
        $dataSet = Invoke-DbaQuery -Query $query -SqlInstance $db -Database $config.Database -ErrorAction Stop `
        | Select-Object Id, Url, Tag, Status, NlbClusterId, @{Name = 'IpAddress'; Expression = { ($_.Url.Split("/")[2]).Split(":")[0] } }`
            , @{Name = 'Port'; Expression = { ($_.Url.Split("/")[2]).Split(":")[1] } }

        $dataSet | Write-Verbose
        $dtStart = [datetime]::UtcNow
        Write-Verbose "START: $($dtStart)"

        $query = "INSERT dbo.ServicesLog (JournalGuid, ServiceId, ServiceUrl, ServiceStatus) VALUES ('$guid', 0, '', 'START')"
        Invoke-DbaQuery -Query $query -SqlInstance $db -Database $config.Database -ErrorAction Stop 

        Write-Host "# Init: $([datetime]::UtcNow - $dtStart)"
        $query = ""
        $ClusterServiceMapping = @()
    }
    Process {              
        if (($dataSet | Measure-Object).Count -gt 0) {                
            $scriptBlock = [scriptblock] `
            {  
                param($data, $ref)
                $temp = "" | Select-Object Id, Url, IpAddress, Port, Tag, Status, Notes, CurrStatus, NlbClusterId
             
                $response = Invoke-HealthCheck -Url $data.Url -IpAddress $data.IpAddress -Port $data.Port -Tag $data.Tag -Verbose:$ref

                $temp.Id = $data.Id
                $temp.CurrStatus = $data.Status	
                $temp.Url = $data.Url				
                $temp.IpAddress = $data.IpAddress
                $temp.Port = $data.Port   
                $temp.Tag = $data.Tag
                $temp.NlbClusterId = $data.NlbClusterId				
                $temp.Status = $response.Status
                $temp.Notes = $response.Notes
								
                $temp
            }
            
            $jobs = $dataSet | ForEach-Object {
                $params = ($_, $VerbosePreference)
                Start-ThreadJob -ThrottleLimit $(($dataSet | Measure-Object).Count) -ArgumentList $params -ScriptBlock $scriptBlock `
                    -InitializationScript $initScript
            }
			
            Write-Verbose "Waiting for $(($jobs | Measure-Object).Count) jobs to complete..."
            $report = Receive-Job -Job $jobs -Wait -AutoRemoveJob
            Write-Verbose "RESULT..." 
            $report | Format-Table | Out-String -Stream | Where-Object { $_ -ne "" } | Write-Verbose
			
            Write-Host "# Test: $([datetime]::UtcNow - $dtStart)"
            try {				
                $report | ForEach-Object {
                    $item = $_ | ConvertTo-Json -Depth 2 | ConvertFrom-Json
			
                    $query += "INSERT dbo.ServicesLog (JournalGuid, ServiceId, ServiceUrl, ServiceStatus) 
                            VALUES ('$Guid', $($item.Id), '$(if ($item.CheckType -eq "API") { $item.Object } else { $item.Object + ":" + $item.Port })', '$(if ($item.Status) { "OK"} else { "ERROR" })')
                    "                    
                    
                    $query += "UPDATE dbo.Services SET Status = $(if ($item.Status) { 1 } else { 0 }), UpdatedTime = SYSDATETIMEOFFSET() WHERE Id = $($item.Id)
                    "                    

                    if ($item.status -eq $False) { 
                        $errorCount += 1
                        if (!$ClusterServiceMapping.Contains($item.NlbClusterId)) { $ClusterServiceMapping += $item.NlbClusterId }
                    }
                    elseif ($item.CurrStatus -eq 0) { $listId += $item.Id }                     
                }
            }
            catch {
                $_.exception.message
            }
            finally {
               
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
                $uri = "{0}/api/SendAlert?jGuid={1}" -f $config.RootUrl, $guid
                Invoke-WebRequest -Method POST -Uri $uri -ContentType "application/json"
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
		
		
        Update-NLBClusterNodeState $ClusterServiceMapping
    }    
}

function Update-NLBClusterNodeState {
    [CmdletBinding()]
    param (
        [Parameter(   
            Mandatory = $False,   
            ParameterSetName = '')]   
        [Array]$NlbClusterIdSet
    )
    
    begin {
        # Checking module
        $initScript = [scriptblock]::Create("Import-Module $($config.RootModulePath)/NetworkLB")
        Write-Host $NlbClusterIdSet
        $db = Connect-DbaInstance -SqlInstance $config.SqlInstance
        $query = "SELECT * FROM dbo.NlbCluster";
        $ClusterSet = Invoke-DbaQuery -Query $query -SqlInstance $db -Database $config.Database -ErrorAction Stop
        $NlbClusterIdSet
        if (!$ClusterSet) {
            Write-Verbose "No cluster data"
            Break
        }
        Write-Verbose $ClusterSet
        $Report = @()
    }
    
    process {
        # Start Cluster node when all services are UP
		
        Write-Verbose "# Start Cluster node when all services are UP"
        $scriptBlock = [scriptblock] `
        {  
            param($data, $ref)			
            Invoke-NetworkLoadBalancing -HostName $data.HostName -NodeName $data.NodeName -Start -Verbose:$ref
        }
        
        $jobs = $ClusterSet | Select-Object Id, ClusterName, HostName, NodeName | Where-Object { !$NlbClusterIdSet.Contains($_.Id) } | ForEach-Object {
            $params = ($_, $VerbosePreference)
            Start-ThreadJob -ThrottleLimit $(($ClusterSet | Measure-Object).Count) -ArgumentList $params -ScriptBlock $scriptBlock `
                -InitializationScript $initScript
        }

        Write-Verbose "> Waiting for $(($jobs | Measure-Object).Count) jobs to complete..."
		
        $Response = Receive-Job -Job $jobs -Wait -AutoRemoveJob
        Write-Verbose "> RESULT..." 
        $Response | Format-Table | Out-String -Stream | Where-Object { $_ -ne "" } | Write-Verbose
        $Report += $Response
		
        # Stop Cluster node when all services are UP
        $Response = ""
        Write-Verbose "# Stop Cluster node when all services are UP"      
        $scriptBlock = [scriptblock] `
        {  
            param($data, $ref)			
            Invoke-NetworkLoadBalancing -HostName $data.HostName -NodeName $data.NodeName -Stop -Verbose:$ref | Out-Null
        }
        $jobs = $ClusterSet | Select-Object Id, ClusterName, HostName, NodeName | Where-Object { $NlbClusterIdSet.Contains($_.Id) } | ForEach-Object {
            $params = ($_, $VerbosePreference)
            Start-ThreadJob -ThrottleLimit $(($ClusterSet | Measure-Object).Count) -ArgumentList $params -ScriptBlock $scriptBlock `
                -InitializationScript $initScript
        }

        #Write-Verbose "> Waiting for $(($jobs | Measure-Object).Count) jobs to complete..."
        
        #$Response = Receive-Job -Job $jobs -Wait -AutoRemoveJob
        Write-Verbose "> RESULT..." 
        #$Response | Format-Table | Out-String -Stream | Where-Object { $_ -ne "" } | Write-Verbose
        #$Report += $Response
    }
    
    end {
        #$Report
    }
}

if ($Object) {    
    Invoke-ProcessSpecialCase -Object $Object
}
else {
    Invoke-ProcessCommonCaseAsync
}