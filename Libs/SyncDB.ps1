Param(
    [Parameter(Mandatory)]	
	[string]$syncType	
	# 1: Sync EventMonitoring
	# 2: Sync Shard
	# null | 0: do nothing
)

if ($null -eq $syncType) {
	$syncType = 0
}

$rootPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$privateKeyPath = "{0}\Credentials\PrivateKey.txt" -F $rootPath
$dbPasswordHashPath = "{0}\Credentials\PasswordHash_DB.txt" -F $rootPath
$logPath = "{0}\log" -F $rootPath

$Monitoring = "{0}\Queries\ChangeRoleUser.sql" -F $rootPath
$Retail = "{0}\Queries\ChangeRoleUser.sql" -F $rootPath
$Fnb = "{0}\Queries\golive_EventMonitoring_Fragmentation.sql" -F $rootPath
$Kyc = "{0}\Queries\switch_dcs_owner_kyc.sql" -F $rootPath
$TimeSheet = "{0}\Queries\golive_login_invidualpermission.sql" -F $rootPath
$FnBEventStore = "{0}\Queries\golive_EventMonitoring_Fragmentation.sql" -F $rootPath
$KvSync = "{0}\Queries\SyncSP.sql" -F $rootPath
$CollectData = "{0}\Queries\getData01.sql" -F $rootPath
$privateKey = Get-Content -Path $privateKeyPath 
$dbUser = "replicator"
$dbPass = Get-Content -Path $dbPasswordHashPath | ConvertTo-SecureString -Key $PrivateKey
$SqlCredential = New-Object System.Management.Automation.PSCredential($DBUser, $dbPass)

function Invoke-DBDeployment {
	[CmdletBinding()] 
	Param(
		[Parameter()]
        [string]$ServerName
        ,
		[Parameter()]
        [string]$DBName
        ,
        [Parameter()]
        [string]$QueryPath
        ,
        [Parameter()]
        [string]$LogFile        
        ,
        [Parameter()]
        [PSCredential]$SqlCredential
    )
	
	Invoke-DBAQuery -SqlInstance $ServerName -Database $DBName -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput	| Out-File -FilePath $LogFile -Append
}

function SyncDBA {
    Param(
        [Parameter()]
        [string]$QueryPath
        ,
        [Parameter()]
        [string]$LogPath        
        ,
        [Parameter()]
        [PSCredential]$SqlCredential
    )

	$logFile = "{0}\LogSync_DBA_{1}.txt" -F $LogPath, ('{0:yyyyMMddHHmmss}' -f (Get-Date))
	Write-Host "$logFile"
	
	"$QueryPath" | Out-File -FilePath $logFile -Append	
	#DC2
	"============ DC2 ============" | Out-File -FilePath $logFile -Append
	Invoke-DBDeployment -ServerName 10-15-73-21 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-22 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-23 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-24 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-25 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-26 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-27 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-28 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-29 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-30 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-31 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-32 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-33 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-34 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-35 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-36 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-37 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-38 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-39 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-40 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-41 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-42 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-43 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-44 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-45 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-48 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-49 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#													
	#Invoke-DBDeployment -ServerName 10-15-83-31 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-83-32 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-83-33 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-83-34 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-83-35 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-83-36 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-83-37 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-83-38 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#
	#Invoke-DBDeployment -ServerName 10-15-83-101 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-83-102 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-83-103 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-83-1   -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#	
	#
	##DC1P
	"============ DC1P ============" | Out-File -FilePath $logFile -Append
	Invoke-DBDeployment -ServerName 10-12-73-21 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-22 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-23 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-24 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-25 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-26 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-27 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-28 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-29 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-30 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-31 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-32 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-33 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-34 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-35 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-36 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-37 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-38 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-39 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-40 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-41 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-42 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-43 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-44 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-45 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-47 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile	
	Invoke-DBDeployment -ServerName 10-12-73-48 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-49 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#
	#Invoke-DBDeployment -ServerName 10-12-83-31 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-83-32 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-83-33 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-83-34 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-83-35 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-83-36 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-83-37 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-83-38 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	##
	#Invoke-DBDeployment -ServerName 10-12-83-101 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-83-102 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-83-103 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-83-1   -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	##
	#Invoke-DBDeployment -ServerName 10-12-73-190 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-200 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-201 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-202 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-203 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#
	#Invoke-DBDeployment -ServerName 10-12-73-1 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-2 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-3 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-4 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-5 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-6 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-7 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-8 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	
	#Invoke-DBDeployment -ServerName 10-12-93-1 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-93-1 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	
    Write-Host "Done"
}

function SyncRetail {
    Param(
        [Parameter()]
        [string]$QueryPath
        ,
        [Parameter()]
        [string]$LogPath        
        ,
        [Parameter()]
        [PSCredential]$SqlCredential
    )
	# 29,24,30,32,19,20,26,39,1,14,37,36
	$logFile = "{0}\LogSync_Retail_{1}.txt" -F $LogPath, ('{0:yyyyMMddHHmmss}' -f (Get-Date))	
	Write-Host "$logFile"
	
	"$QueryPath" | Out-File -FilePath $logFile -Append    	
	"============ DC1 VMWARE ============" | Out-File -FilePath $logFile -Append
	Invoke-DBDeployment -ServerName 10-12-73-21 -DBName KiotViet -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile	
	Invoke-DBDeployment -ServerName 10-12-73-47 -DBName KiotVietShard2 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-23 -DBName KiotVietShard3 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-24 -DBName KiotVietShard4 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-25 -DBName KiotVietShard5 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-26 -DBName KiotVietShard6 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-27 -DBName KiotVietShard8 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-28 -DBName KiotVietShard9 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-29 -DBName KiotVietShard10 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-30 -DBName KiotVietShard11 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-31 -DBName KiotVietShard12 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-32 -DBName KiotVietShard13 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-33 -DBName KiotVietShard17 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-34 -DBName KiotVietShard18 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-35 -DBName KiotVietShard19 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-36 -DBName KiotVietShard20 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-37 -DBName KiotVietShard24 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-38 -DBName KiotVietShard26 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-39 -DBName KiotVietShard28 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-40 -DBName KiotVietShard29 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-41 -DBName KiotVietShard30 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-42 -DBName KiotVietShard32 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-43 -DBName KiotVietShard35 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-44 -DBName KiotVietShard36 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-45 -DBName KiotVietShard37 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-32 -DBName KiotVietShard14 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-32 -DBName KiotVietShard21 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-32 -DBName KiotVietShard23 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-22 -DBName KiotVietShard39 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-48 -DBName KiotVietShard42 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-49 -DBName KiotVietShard43 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
   
	"============ DC2 VMWARE ============" | Out-File -FilePath $logFile -Append
	Invoke-DBDeployment -ServerName 10-15-73-21 -DBName KiotViet -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-22 -DBName KiotVietShard2 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-23 -DBName KiotVietShard3 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-24 -DBName KiotVietShard4 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-25 -DBName KiotVietShard5 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-26 -DBName KiotVietShard6 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-27 -DBName KiotVietShard8 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-28 -DBName KiotVietShard9 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-29 -DBName KiotVietShard10 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-30 -DBName KiotVietShard11 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-31 -DBName KiotVietShard12 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-32 -DBName KiotVietShard13 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-33 -DBName KiotVietShard17 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-34 -DBName KiotVietShard18 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-35 -DBName KiotVietShard19 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-36 -DBName KiotVietShard20 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-37 -DBName KiotVietShard24 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-38 -DBName KiotVietShard26 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-39 -DBName KiotVietShard28 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-40 -DBName KiotVietShard29 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-41 -DBName KiotVietShard30 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-42 -DBName KiotVietShard32 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-43 -DBName KiotVietShard35 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-44 -DBName KiotVietShard36 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-45 -DBName KiotVietShard37 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-22 -DBName KiotVietShard39 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-32 -DBName KiotVietShard14 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-32 -DBName KiotVietShard21 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-32 -DBName KiotVietShard23 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-48 -DBName KiotVietShard42 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-49 -DBName KiotVietShard43 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
   
	Write-Host "Done"
}

function SyncFnB {
    Param(
        [Parameter()]
        [string]$QueryPath
        ,
        [Parameter()]
        [string]$LogPath        
        ,
        [Parameter()]
        [PSCredential]$SqlCredential
    )
	
	$logFile = "{0}\LogSync_FnB_{1}.txt" -F $LogPath, ('{0:yyyyMMddHHmmss}' -f (Get-Date))
	Write-Host "$logFile"
	
	"$QueryPath" | Out-File -FilePath $logFile -Append	
	"============ DC1P ============" | Out-File -FilePath $logFile -Append
	Invoke-DBDeployment -ServerName 10-12-83-32 -DBName KiotVietShard15 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-31 -DBName KiotVietShard7 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-33 -DBName KiotVietShard16 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-32 -DBName KiotVietShard22 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-34 -DBName KiotVietShard27 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-35 -DBName KiotVietShard31 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-36 -DBName KiotVietShard33 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-37 -DBName KiotVietShard34 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-38 -DBName KiotVietShard40 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-38 -DBName KiotVietShard41 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	
	"============ DR ============" | Out-File -FilePath $logFile -Append
	Invoke-DBDeployment -ServerName 10-15-83-31 -DBName KiotVietShard7 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-32 -DBName KiotVietShard15 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-33 -DBName KiotVietShard16 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-32 -DBName KiotVietShard22 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-34 -DBName KiotVietShard27 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-35 -DBName KiotVietShard31 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-36 -DBName KiotVietShard33 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-37 -DBName KiotVietShard34 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-38 -DBName KiotVietShard40 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-38 -DBName KiotVietShard41 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	
	Write-Host "Done"
}

function SyncKYC {
    Param(
        [Parameter()]
        [string]$QueryPath
        ,
        [Parameter()]
        [string]$LogPath        
        ,
        [Parameter()]
        [PSCredential]$SqlCredential
    )

	$logFile = "{0}\LogSync_KYC_{1}.txt" -F $LogPath, ('{0:yyyyMMddHHmmss}' -f (Get-Date))	
	Write-Host "$logFile"
	
	"$QueryPath" | Out-File -FilePath $logFile -Append
    "============ DC1P ============" | Out-File -FilePath $logFile -Append
	#Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC1 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile  
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC2 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile   
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC3 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC4 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC5 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC6 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile 
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC8 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC9 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC10 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC11 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC12 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC13 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC14 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC17 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC18 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile    
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC19 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC20 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC21 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC23 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC24 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC26 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile 
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC28 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC29 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC30 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC32 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC35 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC36 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC37 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC39 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC42 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC43 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	
	"============ DC2 ============" | Out-File -FilePath $logFile -Append
	Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC1 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile  
    Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC2 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile   
    Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC3 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC4 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC5 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC6 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile 
    Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC8 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC9 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC10 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC11 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC12 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC13 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC14 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC17 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC18 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile    
    Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC19 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC20 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC21 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC23 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC24 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC26 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile 
    Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC28 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC29 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC30 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC32 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC35 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC36 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC37 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC39 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC42 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC43 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile

	Write-Host "Done"
}

function SyncTimeSheet {
    Param(
        [Parameter()]
        [string]$QueryPath
        ,
        [Parameter()]
        [string]$LogPath        
        ,
        [Parameter()]
        [PSCredential]$SqlCredential
    )

	$logFile = "{0}\LogSync_TimeSheet_{1}.txt" -F $LogPath, ('{0:yyyyMMddHHmmss}' -f (Get-Date))	
	Write-Host "$logFile"
	
	"$QueryPath" | Out-File -FilePath $logFile -Append
    "============ DC ============" | Out-File -FilePath $logFile -Append
	#Connect-DbaInstance -SqlInstance "172.16.13.19" -Database "KiotVietTimeSheetS1" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB1   
    #Connect-DbaInstance -SqlInstance "172.16.13.26" -Database "KiotVietTimeSheetS2" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB2    
    #Connect-DbaInstance -SqlInstance "172.16.13.14" -Database "KiotVietTimeSheetS3" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB15
    #Connect-DbaInstance -SqlInstance "172.16.13.28" -Database "KiotVietTimeSheetS4" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB4
    #Connect-DbaInstance -SqlInstance "172.16.13.21" -Database "KiotVietTimeSheetS5" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB8
    #Connect-DbaInstance -SqlInstance "172.16.13.55" -Database "KiotVietTimeSheetS6" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB33    
    #Connect-DbaInstance -SqlInstance "172.16.13.56" -Database "KiotVietTimeSheetS8" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB34
    #Connect-DbaInstance -SqlInstance "172.16.13.19" -Database "KiotVietTimeSheetS9" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB1
    #Connect-DbaInstance -SqlInstance "172.16.13.200" -Database "KiotVietTimeSheetS10" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB10
    #Connect-DbaInstance -SqlInstance "172.16.13.12" -Database "KiotVietTimeSheetS11" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB11
    #Connect-DbaInstance -SqlInstance "172.16.13.25" -Database "KiotVietTimeSheetS12" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB12
    #Connect-DbaInstance -SqlInstance "172.16.13.12" -Database "KiotVietTimeSheetS13" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB11
    #Connect-DbaInstance -SqlInstance "172.16.13.21" -Database "KiotVietTimeSheetS14" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB8
    #Connect-DbaInstance -SqlInstance "172.16.13.37" -Database "KiotVietTimeSheetS17" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB22
    #Connect-DbaInstance -SqlInstance "172.16.13.28" -Database "KiotVietTimeSheetS18" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB4
    #Connect-DbaInstance -SqlInstance "172.16.13.200" -Database "KiotVietTimeSheetS19" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB10
    #Connect-DbaInstance -SqlInstance "172.16.13.14" -Database "KiotVietTimeSheetS20" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB15
    #Connect-DbaInstance -SqlInstance "172.16.13.37" -Database "KiotVietTimeSheetS21" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB22
	#Connect-DbaInstance -SqlInstance "172.16.13.200" -Database "KiotVietTimeSheetS30" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB10	
	#Connect-DbaInstance -SqlInstance "172.16.13.54" -Database "KiotVietTimeSheetS35" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB32
	#Connect-DbaInstance -SqlInstance "172.16.13.26" -Database "KiotVietTimeSheetS36" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB2
	#Connect-DbaInstance -SqlInstance "172.16.13.35" -Database "KiotVietTimeSheetS37" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB20
    #
    #Connect-DbaInstance -SqlInstance "172.16.13.37" -Database "KiotVietTimeSheet" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB22
	#Connect-DbaInstance -SqlInstance "172.16.13.32" -Database "KiotVietTimeSheet33" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB14	
	#Connect-DbaInstance -SqlInstance "172.16.13.33" -Database "KiotVietTimeSheet34" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB18
	
	"============ DR ============" | Out-File -FilePath $logFile -Append
	Connect-DbaInstance -SqlInstance "192.168.41.11" -Database "KiotVietTimeSheetS1" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP1   
    Connect-DbaInstance -SqlInstance "192.168.41.12" -Database "KiotVietTimeSheetS2" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP2    
    Connect-DbaInstance -SqlInstance "192.168.41.13" -Database "KiotVietTimeSheetS3" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP3
    Connect-DbaInstance -SqlInstance "192.168.41.14" -Database "KiotVietTimeSheetS4" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP4
    Connect-DbaInstance -SqlInstance "192.168.41.15" -Database "KiotVietTimeSheetS5" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP5
    Connect-DbaInstance -SqlInstance "192.168.41.37" -Database "KiotVietTimeSheetS6" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP18   
    Connect-DbaInstance -SqlInstance "192.168.41.18" -Database "KiotVietTimeSheetS8" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP8
    Connect-DbaInstance -SqlInstance "192.168.41.11" -Database "KiotVietTimeSheetS9" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DB1
    Connect-DbaInstance -SqlInstance "192.168.41.21" -Database "KiotVietTimeSheetS10" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP10
    Connect-DbaInstance -SqlInstance "192.168.41.19" -Database "KiotVietTimeSheetS11" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP11
    Connect-DbaInstance -SqlInstance "192.168.41.20" -Database "KiotVietTimeSheetS12" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP12
    Connect-DbaInstance -SqlInstance "192.168.41.19" -Database "KiotVietTimeSheetS13" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP11
    Connect-DbaInstance -SqlInstance "192.168.41.15" -Database "KiotVietTimeSheetS14" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP5
    Connect-DbaInstance -SqlInstance "192.168.41.24" -Database "KiotVietTimeSheetS17" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP14
    Connect-DbaInstance -SqlInstance "192.168.41.14" -Database "KiotVietTimeSheetS18" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP4
    Connect-DbaInstance -SqlInstance "192.168.41.21" -Database "KiotVietTimeSheetS19" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP10
    Connect-DbaInstance -SqlInstance "192.168.41.13" -Database "KiotVietTimeSheetS20" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP3
    Connect-DbaInstance -SqlInstance "192.168.41.24" -Database "KiotVietTimeSheetS21" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP14
	Connect-DbaInstance -SqlInstance "192.168.41.21" -Database "KiotVietTimeSheetS30" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP10
	Connect-DbaInstance -SqlInstance "192.168.41.21" -Database "KiotVietTimeSheetS35" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP10
	Connect-DbaInstance -SqlInstance "192.168.41.12" -Database "KiotVietTimeSheetS36" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP2
	Connect-DbaInstance -SqlInstance "192.168.41.29" -Database "KiotVietTimeSheetS37" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP16
                                      
    Connect-DbaInstance -SqlInstance "192.168.41.18" -Database "KiotVietTimeSheet" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP8
	Connect-DbaInstance -SqlInstance "192.168.41.25" -Database "KiotVietTimeSheet33" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP15	
	Connect-DbaInstance -SqlInstance "192.168.41.25" -Database "KiotVietTimeSheet34" -SqlCredential $SqlCredential | Invoke-DbaQuery -File $QueryPath -MessagesToOutput | Out-File -FilePath $logFile -Append # VM-KV-DBREP15
	   
	#$Response | export-csv -Path $logFile -NoTypeInformation -Delimiter "`t" -Encoding UTF8
	Write-Host "Done"
}

function SyncFnBEventStore {
    Param(
        [Parameter()]
        [string]$QueryPath
        ,
        [Parameter()]
        [string]$LogPath        
        ,
        [Parameter()]
        [PSCredential]$SqlCredential
    )

	$logFile = "{0}\LogSync_FnbEventStore_{1}.txt" -F $LogPath, ('{0:yyyyMMddHHmmss}' -f (Get-Date))	
	Write-Host "$logFile"
	
	"$QueryPath -MessagesToOutput" | Out-File -FilePath $logFile -Append
	"============ DC1P ============" | Out-File -FilePath $logFile -Append
	Invoke-DBDeployment -ServerName 10-12-83-101 -DBName FnbEventStore7 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-101 -DBName FnbEventStore15 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-101 -DBName FnbEventStore16 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-101 -DBName FnbEventStore22 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-101 -DBName FnbEventStore27 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-102 -DBName FnbEventStore31 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-102 -DBName FnbEventStore33 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-102 -DBName FnbEventStore34 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-102 -DBName FnbEventStore40 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-83-103 -DBName FnbEventStore41 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile

	"============ DC2 ============" | Out-File -FilePath $logFile -Append
	Invoke-DBDeployment -ServerName 10-15-83-101 -DBName FnbEventStore7 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-101 -DBName FnbEventStore15 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-101 -DBName FnbEventStore16 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-101 -DBName FnbEventStore22 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-101 -DBName FnbEventStore27 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-102 -DBName FnbEventStore31 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-102 -DBName FnbEventStore33 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-102 -DBName FnbEventStore34 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-102 -DBName FnbEventStore40 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-83-103 -DBName FnbEventStore41 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Write-Host "Done"
}

function SyncKvSync {
    Param(
        [Parameter()]
        [string]$QueryPath
        ,
        [Parameter()]
        [string]$LogPath        
        ,
        [Parameter()]
        [PSCredential]$SqlCredential
    )

	$logFile = "{0}\LogSync_KvSync_{1}.txt" -F $LogPath, ('{0:yyyyMMddHHmmss}' -f (Get-Date))
	Write-Host "$logFile"
	
	#Invoke-DBDeployment -ServerName 10-12-73-1 -DBName KiotVietSync10 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-1 -DBName KiotVietSync20 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-1 -DBName KiotVietSync24 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-1 -DBName KiotVietSync9 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile	
	#Invoke-DBDeployment -ServerName 10-12-73-2 -DBName KiotVietSync12 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-2 -DBName KiotVietSync23 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-2 -DBName KiotVietSync26 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-2 -DBName KiotVietSync3 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-3 -DBName KiotVietSync2 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-3 -DBName KiotVietSync28 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-3 -DBName KiotVietSync30 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-4 -DBName KiotVietSync -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-4 -DBName KiotVietSync19 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-4 -DBName KiotVietSync29 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-5 -DBName KiotVietSync17 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-5 -DBName KiotVietSync21 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-5 -DBName KiotVietSync32 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-5 -DBName KiotVietSync4 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-6 -DBName KiotVietSync14 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-6 -DBName KiotVietSync18 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-6 -DBName KiotVietSync35 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-6 -DBName KiotVietSync5 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile 
	#Invoke-DBDeployment -ServerName 10-12-73-7 -DBName KiotVietSync11 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-7 -DBName KiotVietSync13 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-7 -DBName KiotVietSync36 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-7 -DBName KiotVietSync6 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-8 -DBName KiotVietSync37 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-8 -DBName KiotVietSync8 -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-1 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-2 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-3 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-4 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile	
	Invoke-DBDeployment -ServerName 10-12-73-5 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-6 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-7 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-12-73-8 -DBName EventMonitoring -SqlCredential $SqlCredential -QueryPath $QueryPath -LogFile $logFile

    Write-Host "Done"
}

function SwitchDCs {	
	Param(
        [Parameter()]
        [string]$RootPath
        ,
        [Parameter()]
        [string]$LogPath        
        ,
        [Parameter()]
        [PSCredential]$SqlCredential
    )
	
	#$Retail = "{0}\Queries\switch_dcs_owner.sql" -F $RootPath	
	#$Kyc = "{0}\Queries\switch_dcs_owner_kyc.sql" -F $RootPath
	
	$Retail = "{0}\Queries\switch_dcs_reader.sql" -F $RootPath	
	$Kyc = "{0}\Queries\switch_dcs_reader_kyc.sql" -F $RootPath
	
	$logFile = "{0}\LogSync_SwitchDCs_{1}.txt" -F $LogPath, ('{0:yyyyMMddHHmmss}' -f (Get-Date))	
	Write-Host "$logFile"	
	"$Retail" | Out-File -FilePath $logFile -Append	
	"$Kyc" | Out-File -FilePath $logFile -Append	
    	
	"============ DC1 VMWARE ============" | Out-File -FilePath $logFile -Append
	#Invoke-DBDeployment -ServerName 10-12-73-21 -DBName KiotViet 		-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-22 -DBName KiotVietShard2 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-47 -DBName KiotVietShard2 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-23 -DBName KiotVietShard3 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-24 -DBName KiotVietShard4 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-25 -DBName KiotVietShard5 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-26 -DBName KiotVietShard6 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-27 -DBName KiotVietShard8 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-28 -DBName KiotVietShard9 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-29 -DBName KiotVietShard10 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-30 -DBName KiotVietShard11 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-31 -DBName KiotVietShard12 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-32 -DBName KiotVietShard13 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-33 -DBName KiotVietShard17 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-34 -DBName KiotVietShard18 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-35 -DBName KiotVietShard19 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-36 -DBName KiotVietShard20 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-37 -DBName KiotVietShard24 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-38 -DBName KiotVietShard26 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-39 -DBName KiotVietShard28 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-40 -DBName KiotVietShard29 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-41 -DBName KiotVietShard30 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-42 -DBName KiotVietShard32 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-43 -DBName KiotVietShard35 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-44 -DBName KiotVietShard36 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-45 -DBName KiotVietShard37 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-32 -DBName KiotVietShard14 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-32 -DBName KiotVietShard21 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-32 -DBName KiotVietShard23 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-22 -DBName KiotVietShard39 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	
	#Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC1 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile  
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC2 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile   
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC3 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC4 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC5 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC6 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile 
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC8 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC9 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC10 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC11 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC12 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC13 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC14 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC17 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC18 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile    
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC19 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-202 -DBName KiotVietYC20 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC21 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC23 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC24 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC26 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile 
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC28 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC29 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC30 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC32 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC35 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC36 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-203 -DBName KiotVietYC37 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-12-73-201 -DBName KiotVietYC39 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
   
	"============ DC2 VMWARE ============" | Out-File -FilePath $logFile -Append
	#Invoke-DBDeployment -ServerName 10-15-73-21 -DBName KiotViet 		-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-22 -DBName KiotVietShard2 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-23 -DBName KiotVietShard3 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-24 -DBName KiotVietShard4 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-25 -DBName KiotVietShard5 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-26 -DBName KiotVietShard6 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-27 -DBName KiotVietShard8 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-28 -DBName KiotVietShard9 	-SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-29 -DBName KiotVietShard10 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-30 -DBName KiotVietShard11 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-31 -DBName KiotVietShard12 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-32 -DBName KiotVietShard13 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-33 -DBName KiotVietShard17 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-34 -DBName KiotVietShard18 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-35 -DBName KiotVietShard19 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-36 -DBName KiotVietShard20 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-37 -DBName KiotVietShard24 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-38 -DBName KiotVietShard26 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-39 -DBName KiotVietShard28 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-40 -DBName KiotVietShard29 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-41 -DBName KiotVietShard30 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-42 -DBName KiotVietShard32 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-43 -DBName KiotVietShard35 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-44 -DBName KiotVietShard36 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-45 -DBName KiotVietShard37 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-22 -DBName KiotVietShard39 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-32 -DBName KiotVietShard14 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-32 -DBName KiotVietShard21 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-32 -DBName KiotVietShard23 -SqlCredential $SqlCredential -QueryPath $Retail -LogFile $logFile	
	
	#Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC1 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile  
    #Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC2 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile   
    #Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC3 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC4 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC5 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC6 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile 
    #Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC8 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC9 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC10 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC11 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC12 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC13 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC14 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC17 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC18 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile    
    #Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC19 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-202 -DBName KiotVietYC20 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC21 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC23 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC24 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC26 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile 
    #Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC28 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
    #Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC29 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC30 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC32 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC35 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC36 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	Invoke-DBDeployment -ServerName 10-15-73-203 -DBName KiotVietYC37 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
	#Invoke-DBDeployment -ServerName 10-15-73-201 -DBName KiotVietYC39 	-SqlCredential $SqlCredential -QueryPath $Kyc -LogFile $logFile
   
	Write-Host "Done"
}

function CollectData {
    Param(
        [Parameter()]
        [string]$QueryPath
        ,
        [Parameter()]
        [string]$LogPath        
        ,
        [Parameter()]
        [PSCredential]$SqlCredential
    )
	
	$logFile = "{0}\CollectData_{1}.csv" -F $LogPath, ('{0:yyyyMMdd}' -f (Get-Date))
	Write-Host "$logFile"
	
	$Data = @()		
	#$Data += Invoke-DBAQuery -SqlInstance  10-12-83-32 -Database KiotVietShard15 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  10-12-83-32 -Database KiotVietShard22 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  10-12-83-33 -Database KiotVietShard16 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput	
	#$Data += Invoke-DBAQuery -SqlInstance  10-12-83-31 -Database KiotVietShard7 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput	
	#$Data += Invoke-DBAQuery -SqlInstance  10-12-83-34 -Database KiotVietShard27 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  10-12-83-35 -Database KiotVietShard31 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  10-12-83-36 -Database KiotVietShard33 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  10-12-83-37 -Database KiotVietShard34 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  10-12-83-38 -Database KiotVietShard40 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  10-12-83-38 -Database KiotVietShard41 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#
	#$Data += Invoke-DBAQuery -SqlInstance  172.16.13.18 -Database FnBEventStore7 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  172.16.13.18 -Database FnBEventStore15 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  172.16.13.18 -Database FnBEventStore16 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  172.16.13.18 -Database FnBEventStore22 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  172.16.13.18 -Database FnBEventStore27 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  172.16.13.59 -Database FnBEventStore31 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput	
	#$Data += Invoke-DBAQuery -SqlInstance  172.16.13.59 -Database FnBEventStore33 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  172.16.13.59 -Database FnBEventStore34 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance  172.16.13.59 -Database FnBEventStore40 -File $QueryPath -SqlCredential $SqlCredential -MessagesToOutput	
	
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-201 -Database KiotVietYC1  -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput 
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-201 -Database KiotVietYC2  -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput  
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-201 -Database KiotVietYC3  -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-201 -Database KiotVietYC4  -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-201 -Database KiotVietYC5  -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-201 -Database KiotVietYC6  -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-201 -Database KiotVietYC8  -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-201 -Database KiotVietYC9  -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-201 -Database KiotVietYC10 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-202 -Database KiotVietYC11 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-202 -Database KiotVietYC12 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-202 -Database KiotVietYC13 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-202 -Database KiotVietYC14 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-202 -Database KiotVietYC17 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-202 -Database KiotVietYC18 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput   
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-202 -Database KiotVietYC19 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-202 -Database KiotVietYC20 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-203 -Database KiotVietYC21 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-203 -Database KiotVietYC23 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-203 -Database KiotVietYC24 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-203 -Database KiotVietYC26 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-203 -Database KiotVietYC28 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
    #$Data += Invoke-DBAQuery -SqlInstance 10-12-73-203 -Database KiotVietYC29 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-203 -Database KiotVietYC30 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-203 -Database KiotVietYC32 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-203 -Database KiotVietYC35 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-203 -Database KiotVietYC36 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-203 -Database KiotVietYC37 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-201 -Database KiotVietYC39 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-201 -Database KiotVietKYCMaster -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-21 -Database KiotViet -SqlCredential $SqlCredential 		 -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-22 -Database KiotVietShard2 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-23 -Database KiotVietShard3 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-24 -Database KiotVietShard4 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-25 -Database KiotVietShard5 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-26 -Database KiotVietShard6 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-27 -Database KiotVietShard8 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-28 -Database KiotVietShard9 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-29 -Database KiotVietShard10 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-30 -Database KiotVietShard11 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-31 -Database KiotVietShard12 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-32 -Database KiotVietShard13 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-33 -Database KiotVietShard17 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-34 -Database KiotVietShard18 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-35 -Database KiotVietShard19 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-36 -Database KiotVietShard20 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-37 -Database KiotVietShard24 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-38 -Database KiotVietShard26 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-39 -Database KiotVietShard28 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-40 -Database KiotVietShard29 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-41 -Database KiotVietShard30 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-42 -Database KiotVietShard32 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-43 -Database KiotVietShard35 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-44 -Database KiotVietShard36 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-45 -Database KiotVietShard37 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-32 -Database KiotVietShard14 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-32 -Database KiotVietShard21 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-32 -Database KiotVietShard23 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-22 -Database KiotVietShard39 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-21 -Database KiotViet -SqlCredential $SqlCredential 		 -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-22 -Database KiotVietShard2 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-23 -Database KiotVietShard3 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-24 -Database KiotVietShard4 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-25 -Database KiotVietShard5 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-26 -Database KiotVietShard6 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-27 -Database KiotVietShard8 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-28 -Database KiotVietShard9 -SqlCredential $SqlCredential  -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-29 -Database KiotVietShard10 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-30 -Database KiotVietShard11 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-31 -Database KiotVietShard12 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-32 -Database KiotVietShard13 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-33 -Database KiotVietShard17 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-34 -Database KiotVietShard18 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-35 -Database KiotVietShard19 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-36 -Database KiotVietShard20 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-37 -Database KiotVietShard24 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-38 -Database KiotVietShard26 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-39 -Database KiotVietShard28 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-40 -Database KiotVietShard29 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-41 -Database KiotVietShard30 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-42 -Database KiotVietShard32 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-43 -Database KiotVietShard35 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-44 -Database KiotVietShard36 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-45 -Database KiotVietShard37 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-32 -Database KiotVietShard14 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-32 -Database KiotVietShard21 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-32 -Database KiotVietShard23 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	$Data += Invoke-DBAQuery -SqlInstance 10-15-73-22 -Database KiotVietShard39 -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-83-31 -Database EventMonitoring -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-83-32 -Database EventMonitoring -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-83-33 -Database EventMonitoring -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-83-34 -Database EventMonitoring -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-83-35 -Database EventMonitoring -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-83-36 -Database EventMonitoring -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-83-37 -Database EventMonitoring -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-83-38 -Database EventMonitoring -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-83-101 -Database EventMonitoring -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-83-102 -Database EventMonitoring -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-83-103 -Database EventMonitoring -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	
	#$Data += Invoke-DBAQuery -SqlInstance 10-12-73-200 -Database KiotVietMaster -SqlCredential $SqlCredential -File $QueryPath -MessagesToOutput
	
	$Data | Export-csv $logFile -NoTypeInformation -Delimiter ';' -Encoding UTF8
	
	Write-Host "Done"
}

switch ($syncType) {
    "DBA" { SyncDBA -QueryPath $Monitoring -LogPath $logPath -SqlCredential $SqlCredential }
    "RETAIL" { SyncRetail -QueryPath $Retail -LogPath $logPath -SqlCredential $SqlCredential }
	"FNB" { SyncFnB -QueryPath $Fnb -LogPath $logPath -SqlCredential $SqlCredential }
	"KYC" { SyncKYC -QueryPath $Kyc -LogPath $logPath -SqlCredential $SqlCredential }
	"TS" { SyncTimeSheet -QueryPath $TimeSheet -LogPath $logPath -SqlCredential $SqlCredential }
	"ES" { SyncFnBEventStore -QueryPath $FnBEventStore -LogPath $logPath -SqlCredential $SqlCredential }
	"KS" { SyncKvSync -QueryPath $KvSync -LogPath $logPath -SqlCredential $SqlCredential }
	"DATA" { CollectData -QueryPath $CollectData -LogPath $logPath -SqlCredential $SqlCredential }
	"RETAILDC" { SwitchDCs -RootPath $rootPath -LogPath $logPath -SqlCredential $SqlCredential }
    Default { Read-Host "Do nothing!"}
}