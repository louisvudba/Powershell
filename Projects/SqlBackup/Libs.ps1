$Config = Get-Content "$(Split-Path $MyInvocation.MyCommand.Path)\Config.json" | ConvertFrom-Json
#. "$rootPath\Config.ps1"
# FUNCTION
function Initialize-BackupProcess {
    [CmdletBinding()]
    Param
    (        
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "Backup Type: F - Full, D - Differential, L - Log", ValueFromPipeline = $true)]     
        [string]$Type
    )

    if (!$Config.ValidateBackupType.Contains($Type)) {
        Write-Host "Error Input"
        Break
    }
    
    # Check FCI current node
    $isPrimary = Get-ClusterCurrentStatus $env:COMPUTERNAME
    Write-Host "Current node $env:COMPUTERNAME status: $isPrimary"
    if ($isPrimary -ne 1) {        
        break
    }
    # Get all databases' name exclude system databases    
    $DbArr = Get-DbaDatabase -SqlInstance $Config.SqlInstance -ExcludeSystem | Where-Object { !$Config.SqlDbExclude.Contains($_.Name) } | Select-Object Name
  
    # Do backup
    # Where DB not in $SqlDbExclude
    foreach ($item in $DbArr) {
        $BackupType = Get-BackupType $Type
        $FileName = Get-BackupFileName $item.Name $Type
        $DBName = $item.Name
        try {   
            Backup-Database $item.Name $FileName $BackupType              
        }
        catch {
            Write-Information "==> Backup DB $DBName ERROR!"
        }        
    }
}

function Backup-Database {
    [CmdletBinding()]
    Param
    (        
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "Database Name", ValueFromPipeline = $true)]        
        [string]$DbName,
        [Parameter(Position = 2, Mandatory = $True, HelpMessage = "Backup File Name", ValueFromPipeline = $true)]        
        [string]$FileName,
        [Parameter(Position = 3, Mandatory = $True, HelpMessage = "Backup Type: Full, Diff, Log", ValueFromPipeline = $true)]
        [ValidateSet("Full", "Diff", "Log")]
        [string]$BackupType
    )

    try {
        $BackupPath = "{0}\{1}" -f $Config.SqlBackupDir, $DbName		

        if (!(Test-Path $BackupPath -PathType Container)) {  
            New-Item -ItemType Directory -Force -Path $BackupPath
            Write-Verbose "Folder path has been created successfully at: " $BackupPath    
        }
        else { 
            Write-Verbose "The given folder path $BackupPath already exists"; 
        }
    }
    catch {
        Write-Verbose $Error[0]
    }

    $params = @{
        SqlInstance      = $Config.SqlInstance
        Database         = $DbName
        BackupDirectory  = $BackupPath
        BackupFileName   = $FileName
        Type             = $BackupType
        ReplaceInName    = $true
        CompressBackup   = $true
        IgnoreFileChecks = $true
    }
    
    Backup-DbaDatabase @params | Out-Null
}

function Get-BackupFileName {
    Param(
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "Database Name", ValueFromPipeline = $true)]
        [string]$DbName, 
        [Parameter(Position = 2, Mandatory = $True, HelpMessage = "Backup Type: F - Full, D - Differential, L - Log", ValueFromPipeline = $true)]
        [ArgumentCompleter( {
                $possibleValues = $ValidateBackupType
                return $possibleValues | ForEach-Object { $_ }
            })]
        [string]$Type
    )
    $timeStamp = '{0:yyyyMMddHHmmss}' -f (Get-Date)
    $fileType = Get-BackupType $Type
    $fileExtension = Get-FileExtension $Type
    $BackupFileName = $DbName + "_" + $fileType + "_" + $timeStamp + "." + $fileExtension
    return $BackupFileName
}

function Get-FileExtension {
    Param(
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "Backup Type: F - Full, D - Differential, L - Log", ValueFromPipeline = $true)]
        [ArgumentCompleter( {
                $possibleValues = $ValidateBackupType
                return $possibleValues | ForEach-Object { $_ }
            })]
        [string]$Type
    )
    switch ($Type) {
        "F" { $e = "bak" }
        "D" { $e = "bak" }
        "L" { $e = "trn" }
        Default { $e = "bak" }
    }
    return $e
}

function Get-BackupType {
    Param(
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "Backup Type: F - Full, D - Differential, L - Log", ValueFromPipeline = $true)]
        [ArgumentCompleter( {
                $possibleValues = $ValidateBackupType
                return $possibleValues | ForEach-Object { $_ }
            })]
        [string]$Type
    )
    switch ($Type) {
        "F" { $t = "Full" }
        "D" { $t = "Diff" }
        "L" { $t = "Log" }
        Default { $t = "Full" }
    }
    return $t
}

function Get-ClusterCurrentStatus {
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "ServerName", ValueFromPipeline = $True)]
        [ArgumentCompleter( {
                $possibleValues = $ValidateClusterNode
                return $possibleValues | ForEach-Object { $_ }
            })]
        $ServerName
    )

    # Checking module
    Try {
        Import-Module FailoverClusters -ErrorAction Stop
    }
    Catch {
        $_.Exception.Message
        Write-Output "Failover cluster module not installed!"
        Break
    }

    Write-Host "Processing $server" -ForegroundColor Green
    
    Try {
        # Checking if server exist           
        $HostName = [System.Net.Dns]::GetHostAddresses($ServerName)    
    }
    Catch {
        Write-Warning "Server does not exist"
    }

    If ($hostname.ipaddresstostring) {
        # Check if cluster service is running
        Try { 
            If (!(Get-Service -ComputerName $ServerName |  Where-Object { $_.Displayname -match "Cluster*" }).Status -eq "Running") { throw }
        }
        Catch {
            Write-Warning 'Cluster service is not "Running"'
            Read-Host -Prompt "Press Enter to exit..."
            Break
        } 
		
        Try {
            # If checks passed then get cluster information		
            
            $CheckNode = Get-ClusterGroup | Where-Object { $_.Name -Like "*SQL Server*" -AND $_.OwnerNode -eq $ServerName.ToLower() } | Select-Object OwnerNode
        }
        Catch {            
            $_.Exception.Message
            Break
        }
    }
    Else {
        Write-Warning "Server does not exist"
    }

    if ($CheckNode) { $retVal = 1 } 
    else { $retVal = 0 }
    return $retVal
}