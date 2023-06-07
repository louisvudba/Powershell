[CmdletBinding()] 
Param
(   
    [String] [Parameter(Mandatory = $True)]
    $ServerName,
    [String] [Parameter(Mandatory = $True)]
    $DBName,
	[String] [Parameter(Mandatory = $False)]
    $Separator = "*|KiotViet|*",
	[int] [Parameter(Mandatory = $True)]
	$CommandType = 0, # 1: Generate Stored Procedures, 2: Build Customer Injection, 3: Deploy Injected Sps, 4: Rollback Sps
	[int] [Parameter(Mandatory = $False)]
    $Type = 0, # 0: All, 1: Insert Commands, 2: Update Commands, 3: Delete Commands
	[String] [Parameter(Mandatory = $False)]
    $TableName = ""	
)

$RootPath = "G:\DBA"
$SourcePath = "{0}\Source\SQLReplInjection" -F $RootPath

try {
    . ("{0}\Core\DBAReplicationInjection.ps1" -F $RootPath)
}
catch {
    Write-Error "Error while loading supporting PowerShell Scripts" 
    Write-Error "Error $_" 
    Break
}

if ($CommandType -eq 1) {	
	Invoke-GenerateSPs -ServerName $ServerName -DBName $DBName -Path $SourcePath -TableName $TableName
}
elseif ($CommandType -eq 2) {
	Invoke-ReplicationInjection -ServerName $ServerName -DBName $DBName -SourcePath $SourcePath -Separator $Separator
}
elseif ($CommandType -eq 3) {
	Invoke-ReplDeploy -ServerName $ServerName -DBName $DBName -SourcePath $SourcePath -Type $Type -IsInjected
}
elseif ($CommandType -eq 4) {
	Invoke-ReplDeploy -ServerName $ServerName -DBName $DBName -SourcePath $SourcePath -Type $Type
}