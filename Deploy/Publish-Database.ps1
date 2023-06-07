[CmdletBinding()]
param
(
    [String] [Parameter(Mandatory = $true)]
    $ServerName,
    [String] [Parameter(Mandatory = $false)]
    $ReplDrive,
	[String] [Parameter(Mandatory = $false)]
    $TcpPort,
	[String] [Parameter(Mandatory = $false)]
    $FwPort, 
	[String] [Parameter(Mandatory = $false)]
    $DBName,
	[String] [Parameter(Mandatory = $false)]
    $DC,  
    [switch] [Parameter(Mandatory = $false)]
    $IsReplication = $false,
    [switch] [Parameter(Mandatory = $false)]
    $IsCustomBuild = $false,
	[switch] [Parameter(Mandatory = $false)]
    $IsBuildBI = $false,
    [switch] [Parameter(Mandatory = $false)]
	$IsBackupJob = $false
)

$global:ErrorActionPreference = 'Stop';
$rootPath = ""
$sourcePath = ""

try {
    . ("{0}\Core\DBAStartup.ps1" -F $rootPath)
    . ("{0}\Core\DBABuildBI.ps1" -F $rootPath)
    . ("{0}\Core\DBACustomBuild.ps1" -F $rootPath)
    . ("{0}\Core\DBADeployBackupDB.ps1" -F $rootPath)
}
catch {
    Write-Error "Error while loading supporting PowerShell Scripts" 
    Write-Error "Error $_" 
    Break
}

try {
    Write-Host $ServerName 
    If ($IsServerConfig) {
        Write-Host "Init Server Configuration"
        InitServerConfiguration -ServerName $ServerName -SourcePath ("{0}\{1}" -f $rootPath, $sourcePath)
    }
    If ($IsSQLConfig) {
        Write-Host "Init SQL configuration"
        InitSqlConfiguration -ServerName $ServerName
    }
    If($IsReplication){
        Write-Host "Install Replication Distributor"
        InitReplication -ServerName $ServerName -DriveLetter $ReplDrive
    }	
	If($IsCustomBuild) {
        DBACustomBuild -ServerName $ServerName -DBName $DBName
	}	
	
	If($IsBuildBI) {
		Write-Host "BI report"
        DBABuildBI -ServerName $ServerName -DBName $DBName
	}

    If($IsBackupJob) {
		Write-Host "Deploy backup db job"        
        DBADeployBackupJob -ServerName $ServerName -SourcePath ("{0}\{1}" -f $rootPath, $sourcePath)
	}
} catch {
    Write-Error "Error: $_";
}