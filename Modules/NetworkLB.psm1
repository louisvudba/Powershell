function Invoke-NetworkLoadBalancing {
    <#
    .SYNOPSIS
    Network Load Balancing Cluster
    
    .DESCRIPTION
    Allow Start/Stop NLB Cluster node on demand
    
    .PARAMETER HostName
    Name of one cluster node
    
    .PARAMETER NodeName
    Parameter description
    
    .PARAMETER Start
    Start a node
    
    .PARAMETER Stop
    Stop a node
    
    .PARAMETER Delay
    Delay time in second
    
    .EXAMPLE
    Invoke-NetworkLoadBalancing -HostName "node01.internal" -NodeName "node01" -Start    

    Start cluster node "node01" in "node01.internal" cluster
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param (
        [Parameter(   
            Mandatory = $true,   
            ParameterSetName = '')]   
        [string]$HostName
        ,
        [Parameter(   
            Mandatory = $true,   
            ParameterSetName = '')]   
        [string]$NodeName
        ,
        [Parameter(   
            Mandatory = $false,   
            ParameterSetName = '')]   
        [switch]$Start
        ,
        [Parameter(   
            Mandatory = $false,   
            ParameterSetName = '')]   
        [switch]$Stop
        ,
        [Parameter(   
            Mandatory = $false,   
            ParameterSetName = '')]   
        [int]$Delay = 5 
    )

    begin {
        # Checking module
        Try {
            Import-Module NetworkLoadBalancingClusters -ErrorAction Stop
        }
        Catch {
            $_.Exception.Message
            Write-Verbose "NetworkLoadBalancingClusters module not installed!"
            Break
        }
		
        If (!$Start -AND !$Stop) { $Start = $True }
        
        $ErrorActionPreference = "SilentlyContinue"
        $Response = "" | Select-Object HostName, NodeName, Action, Status, Note 

        $Cluster = Get-NlbCluster -HostName $HostName
        if (!$Cluster) {
            Write-Verbose ("HostName {0} doesn't exist" -f $HostName)   
            Break         
        }
        $Nodes = $Cluster | Get-NlbClusterNode
        if (!$Nodes) {
            Write-Verbose ("Cluster {0} doesn't have any nodes" -f $Cluster.ClusterName)   
            Break         
        }
        $ActiveNodeCount = ($Nodes | Where-Object { $_.State -match "converged" } | Measure-Object).Count
        if ($ActiveNodeCount -le 1 -AND $Stop) {
            Write-Verbose ("Cluster {0} has only {1} node converged" -f $Cluster.ClusterName, $ActiveNodeCount)
            Break
        }
    }
    
    process {
        # Cluster infomation
        Write-Verbose "=========================================================================="
        Write-Verbose ("# NLB Cluster : {0}" -f $Cluster.HostName)
        Write-Verbose ("# IpAddress : {0}" -f $Cluster.IpAddress)
        $ProcessNode = $Nodes | Sort-Object -Property HostID | ForEach-Object {
            Write-Verbose ("# Node {0}: {1} - {2}" -f $_.HostPriority, $_.Name, $_.State)
            if ($_.Name -eq $NodeName) { $CheckedNode = $_ }
            if ($_.State -match "converged") { $ActiveNodeCount += 1 }
            $CheckedNode
        }
        Write-Verbose "=========================================================================="
        if (!$ProcessNode) {
            Write-Verbose ("> {0} doesn't exist" -f $NodeName)
        }       
        else {
            $Response.HostName = $Cluster.ClusterName
            $Response.NodeName = $ProcessNode.Name
            $Response.Action = if ($Start) { "START" } else { "STOP" }
            Switch -WildCard ($ProcessNode.State) {
                "*converged*" {                    
                    if ($Start) {
                        Write-Verbose ("> Starting node {0} ...." -f $ProcessNode.Name)
                        Write-Verbose ("> Node {0} is already started" -f $ProcessNode.Name)
                        $Response.Status = 1
                        $Response.Note = "Node is already started"
                    }
                    elseif ($Stop) {
                        Write-Verbose ("> Stopping node {0} ...." -f $ProcessNode.Name)
                        try {						
                            $ProcessNode | Stop-NlbClusterNode -Drain | Out-Null
                            Start-Sleep -s $Delay
                            $Node = $Cluster | Get-NlbClusterNode -NodeName $NodeName
                            Write-Verbose ("> New {0}'s state: {1}" -f $ProcessNode.Name, $Node.State)
                            Write-Verbose "> DONE."
                            $Response.Status = 1
                            $Response.Note = "SUCCESS"
                        }
                        catch {                        
                            Write-Verbose ("> Error {0}" -f $Global.Error)
                            $Response.Status = -1
                            $Response.Note = $Global.Error
                        }
                    }
                    Break
                }
                "*stopped*" {                    
                    if ($Stop) {
                        Write-Verbose ("> Stopping node {0} ...." -f $ProcessNode.Name)
                        Write-Verbose ("> Node {0} is already stopped" -f $ProcessNode.Name)
                        $Response.Status = 1
                        $Response.Note = "Node is already stopped"
                    }
                    elseif ($Start) {
                        Write-Verbose ("> Starting node {0} ...." -f $ProcessNode.Name)
                        try {
                            $ProcessNode | Start-NlbClusterNode | Out-Null
                            Start-Sleep -s $Delay
                            $Node = $Cluster | Get-NlbClusterNode -NodeName $NodeName
                            Write-Verbose ("> New {0}'s state: {1}" -f $ProcessNode.Name, $Node.State)
                            Write-Verbose "> DONE."
                            $Response.Status = 1
                            $Response.Note = "SUCCESS"
                        }
                        catch {                        
                            Write-Verbose ("> Error {0}" -f $Global.Error)
                            $Response.Status = -1
                            $Response.Note = $Global.Error
                        }
                    }
                    Break
                }
                Default {
                    $Response.Status = 0
                    $Response.Node = ""
                    Write-Verbose ("> Nothing to to")
                    Break
                }
            }
        }
    }
    end {
        $Response
    }
}