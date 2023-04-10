function Invoke-BackupSQLDatabase {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .PARAMETER Type
    Parameter description
    
    .PARAMETER SqlInstance
    Parameter description

    .PARAMETER SqlCredential
    Parameter description
    
    .PARAMETER DbName
    Parameter description
    
    .PARAMETER SqlBackupDir
    Parameter description
    
    .PARAMETER ReplaceInName
    Parameter description

    .PARAMETER FileCount
    Parameter description
    
    .PARAMETER CompressBackup
    Parameter description
    
    .PARAMETER IgnoreFileChecks
    Parameter description
    
    .PARAMETER Checksum
    Parameter description
    
    .PARAMETER Verify
    Parameter description

    .PARAMETER Encryption
    Parameter description

    .PARAMETER EncryptionCertificate
    Parameter description

    .PARAMETER EncryptionAlgorithm
    Parameter description
    
    .PARAMETER IsCluster
    Parameter description    

    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>
    [cmdletbinding( )]   
    Param
    (   
        [Parameter(Mandatory, HelpMessage = "Backup Type: F - Full, D - Differential, L - Log")]     
        [string]$Type
        ,
        [Parameter(Mandatory)]     
        [string]$SqlInstance
        ,
        [Parameter()]   
        [PSCredential]$SqlCredential
        ,
        [Parameter(Mandatory, ValueFromPipeline)]     
        [string[]]$DbName
        ,
        [Parameter(Mandatory)]     
        [string]$SqlBackupDir
        ,
        [Parameter()]     
        [switch]$ReplaceInName
        ,
        [Parameter()]     
        [int]$FileCount = 1
        ,
        [Parameter()]     
        [switch]$CompressBackup
        ,
        [Parameter()]     
        [switch]$IgnoreFileChecks
        ,
        [Parameter()]     
        [switch]$Checksum
        ,
        [Parameter()]     
        [switch]$Verify
        ,
        [Parameter()]     
        [switch]$Encryption
        ,
        [Parameter()]     
        [string]$EncryptionCertificate
        ,
        [Parameter()]     
        [string]$EncryptionAlgorithm
        ,
        [Parameter()]     
        [switch]$IsCluster
    )
  
    begin {        
        #Checking module
        Try {
            Import-Module dbatools -ErrorAction Stop
        }
        Catch {
            $_.Exception.Message
            Write-Verbose "dbatools module not installed!"
            Break
        }
		
        if ($IsCluster) {
            $isPrimary = Get-ClusterCurrentStatus $env:COMPUTERNAME
            Write-Host "Current node $env:COMPUTERNAME status: $isPrimary"
            if ($isPrimary -ne 1) {        
                break
            }
        }

        switch ($Type) {
            "F" { $fileExtension = "bak"; $fileType = "Full" }
            "D" { $fileExtension = "bak"; $fileType = "Diff" }
            "L" { $fileExtension = "trn"; $fileType = "Log" }
            Default { $fileExtension = "bak"; $fileType = "Full" }
        }
        $timeStamp = '{0:yyyyMMddHHmmss}' -f (Get-Date)
        
        $Result = @()
    }

    process {   
        $Warning = "" | Select-Object Instance, Database, Error, Detail
        $Warning.Instance = $SqlInstance
        $Warning.Database = $DbName
        # Warnings actions
        $WarningToDo = @{
            WarningAction   = 'SilentlyContinue'
            WarningVariable = 'RestoreWarning'
        }        
        # Error actions
        # $ErrorToDo = @{
        #     ErrorAction   = 'SilentlyContinue'
        #     ErrorVariable = 'RestoreError'
        # }      
        try {
            $BackupPath = "{0}\{1}" -f $SqlBackupDir, ($DbName | Select-Object -First 1)		
    
            if (!(Test-Path $BackupPath -PathType Container)) {  
                New-Item -ItemType Directory -Force -Path $BackupPath | Out-Null
                Write-Verbose "Folder path has been created successfully at: $BackupPath";
            }
            else { 
                Write-Verbose "The given folder path $BackupPath already exists"; 
            }
            $BackupFileName = "{0}_{1}_{2}.{3}" -f ($DbName | Select-Object -First 1),$fileType,$timeStamp,$fileExtension;
            $params = @{
                SqlInstance      = $SqlInstance
                Database         = $DbName
                BackupDirectory  = $BackupPath
                BackupFileName   = $BackupFileName
                Type             = $fileType
                ReplaceInName    = $ReplaceInName
                CompressBackup   = $CompressBackup
                IgnoreFileChecks = $IgnoreFileChecks
                Checksum         = $Checksum
                Verify           = $Verify
                FileCount        = $FileCount
                SqlCredential    = $null
            }
            if ($null -ne $SqlCredential) {
                $params.SqlCredential = $SqlCredential
            }
            if ($Encryption) {
                $encrypt = @{
                    EncryptionAlgorithm = $EncryptionAlgorithm
                    EncryptionCertificate = $EncryptionCertificate
                }  
                $Response = Backup-DbaDatabase @params @encrypt @WarningToDo -EnableException
            } 
            else {
                $Response = Backup-DbaDatabase @params @WarningToDo -EnableException   
            }
            
            if ($RestoreWarning.Count -gt 0) {                 
                $Warning.Error = 1
                $Warning.Detail = Write-Output $RestoreWarning
            }
            else {
                $Warning.Error = 0
                $Warning.Detail = $Response                
            }
            $Result += $Warning
            #if ($RestoreError.Count -gt 0) { $Response += @{ Message = $RestoreError } }
        }        
        catch {           
            $Warning.Error = 1
            $Warning.Detail = $_.Exception.Message
            $Result += $Warning
        }        
    }

    end {
        $Result
    }
}

function Get-ClusterCurrentStatus {
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .PARAMETER ServerName
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    Param
    (            
        [string]$ServerName
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
function Compress-Backup7z {
    [cmdletbinding( )]   
    Param
    (   
        [Parameter(Mandatory)]     
        [string]$FilesToZip
        ,
        [Parameter(Mandatory)]     
        [string]$ZipOutputFilePath
        ,
        [Parameter()]     
        [string]$Pass
        ,
        [Parameter()]     
        [string]$CompressionType = 'zip'
        ,
        [Parameter()]     
        [switch]$HideWindow
        ,
        [Parameter()]     
        [switch]$DeleteAfterArchive
    )

    $pathTo32Bit7Zip = "C:\Program Files (x86)\7-Zip\7z.exe"
    $pathTo64Bit7Zip = "C:\Program Files\7-Zip\7z.exe"
    $THIS_SCRIPTS_DIRECTORY = Split-Path $script:MyInvocation.MyCommand.Path
    $pathToStandAloneExe = Join-Path $THIS_SCRIPTS_DIRECTORY "7za.exe"
    if (Test-Path $pathTo64Bit7Zip) { $pathTo7ZipExe = $pathTo64Bit7Zip }
    elseif (Test-Path $pathTo32Bit7Zip) { $pathTo7ZipExe = $pathTo32Bit7Zip }
    elseif (Test-Path $pathToStandAloneExe) { $pathTo7ZipExe = $pathToStandAloneExe }
    else { throw "Could not find the 7-zip executable." }

    # Delete the destination zip file if it already exists (i.e. overwrite it).
    if (Test-Path $ZipOutputFilePath) { Remove-Item $ZipOutputFilePath -Force }

    $windowStyle = "Normal"
    if ($HideWindow) { $windowStyle = "Hidden" }    

    # Create the arguments to use to zip up the files.
    # Command-line argument syntax can be found at: http://www.dotnetperls.com/7-zip-examples
    $arguments = "a -t$CompressionType ""$ZipOutputFilePath"" ""$FilesToZip"" -mmt=12"
    if (!([string]::IsNullOrEmpty($Pass))) { $arguments += " -p$Pass" }
    if ($DeleteAfterArchive)  { $arguments += " -sdel" }

    # Zip up the files.
    $p = Start-Process $pathTo7ZipExe -ArgumentList $arguments -Wait -PassThru -WindowStyle $windowStyle

    # If the files were not zipped successfully.
    if (!(($p.HasExited -eq $true) -and ($p.ExitCode -eq 0)))
    {
        throw "There was a problem creating the zip file '$ZipFilePath'."
    }
}