[CmdletBinding()]
param
(    
	[string] [Parameter(Mandatory = $true)]
    $Ticket
)

$global:ErrorActionPreference = 'Stop';
$date = Get-Date
$logFile = "G:\DBA\log\LogOmniTrial_$Ticket_{0}.txt" -f $date.ToString('yyyyMMddHHmmss')
$dataFile = "G:\DBA\log\OmniTrial.dat"
$user = "replicator"
$password = "kiotviet@1"

# Collect Data
$Query = "SELECT * FROM {0}.dbo._rtValidOmniTrial_KO5590"
bcp ($Query -f "KiotVietMaster") queryout $dataFile  -S 172.16.13.23 -N -U $user -P $password -w -a 32768 -t"\",\"" | Out-Null

# Create TAble
$Query = "
DROP TABLE IF EXISTS _rtValidOmniTrial_PosParameter_KO5590
DROP TABLE IF EXISTS _rtValidOmniTrial_KO5590
CREATE TABLE [dbo].[_rtValidOmniTrial_KO5590](
	[Id] [int] PRIMARY KEY,
	[GroupId] [int] NOT NULL,
	[Code] [nvarchar](100) NOT NULL,
	[ExpiryDate] [datetime] NULL,
	[ContractType] [int] NULL
) ON [PRIMARY]
GO
" -f $Ticket

# FNB
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.15 -Database KiotVietShard15
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.15 -Database KiotVietShard22
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.31 -Database KiotVietShard16	
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.39 -Database KiotVietShard7 
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.30 -Database KiotVietShard27
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.30 -Database KiotVietShard31
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.32 -Database KiotVietShard33
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.33 -Database KiotVietShard34
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-12-83-38  -Database KiotVietShard40 

# Retail
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-21 -Database KiotViet
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-22 -Database KiotVietShard2
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-23 -Database KiotVietShard3
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-24 -Database KiotVietShard4
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-25 -Database KiotVietShard5
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-26 -Database KiotVietShard6
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-27 -Database KiotVietShard8
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-28 -Database KiotVietShard9
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-29 -Database KiotVietShard10
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-30 -Database KiotVietShard11
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-31 -Database KiotVietShard12
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-32 -Database KiotVietShard13
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-32 -Database KiotVietShard14
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-33 -Database KiotVietShard17
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-34 -Database KiotVietShard18
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-35 -Database KiotVietShard19
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-36 -Database KiotVietShard20
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-32 -Database KiotVietShard21
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-32 -Database KiotVietShard23
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-37 -Database KiotVietShard24
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-38 -Database KiotVietShard26
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-39 -Database KiotVietShard28
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-40 -Database KiotVietShard29
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-41 -Database KiotVietShard30
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-42 -Database KiotVietShard32
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-43 -Database KiotVietShard35
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-44 -Database KiotVietShard36
Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-45 -Database KiotVietShard37

# Push data
$TableName = "{0}.[dbo].[_rtValidOmniTrial_KO5590]"
bcp ($TableName -f "KiotViet")        in $dataFile -S 10-15-73-21 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard2")  in $dataFile -S 10-15-73-22 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard3")  in $dataFile -S 10-15-73-23 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard4")  in $dataFile -S 10-15-73-24 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard5")  in $dataFile -S 10-15-73-25 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard6")  in $dataFile -S 10-15-73-26 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard8")  in $dataFile -S 10-15-73-27 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard9")  in $dataFile -S 10-15-73-28 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard10") in $dataFile -S 10-15-73-29 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard11") in $dataFile -S 10-15-73-30 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard12") in $dataFile -S 10-15-73-31 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard13") in $dataFile -S 10-15-73-32 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard14") in $dataFile -S 10-15-73-32 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard17") in $dataFile -S 10-15-73-33 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard18") in $dataFile -S 10-15-73-34 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard19") in $dataFile -S 10-15-73-35 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard20") in $dataFile -S 10-15-73-36 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard21") in $dataFile -S 10-15-73-32 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard23") in $dataFile -S 10-15-73-32 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard24") in $dataFile -S 10-15-73-37 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard26") in $dataFile -S 10-15-73-38 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard28") in $dataFile -S 10-15-73-39 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard29") in $dataFile -S 10-15-73-40 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard30") in $dataFile -S 10-15-73-41 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard32") in $dataFile -S 10-15-73-42 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard35") in $dataFile -S 10-15-73-43 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard36") in $dataFile -S 10-15-73-44 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard37") in $dataFile -S 10-15-73-45 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null

bcp ($TableName -f "KiotVietShard15") in $dataFile -S 172.16.13.15 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard22") in $dataFile -S 172.16.13.15 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard16") in $dataFile -S 172.16.13.31 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard7") in $dataFile  -S 172.16.13.39 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard27") in $dataFile -S 172.16.13.30 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard31") in $dataFile -S 172.16.13.30 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard33") in $dataFile -S 172.16.13.32 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard34") in $dataFile -S 172.16.13.33 -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null
bcp ($TableName -f "KiotVietShard40") in $dataFile -S 10-12-83-38  -U $user -P $password -w -h TABLOCK -b 100000 -t"\",\"" | Out-Null

$Query = "
SELECT pp.Id, pp.Value, pp.[isActive]
INTO _rtValidOmniTrial_PosParameter_KO5590
FROM dbo._rtValidOmniTrial_KO5590 AS rv INNER JOIN dbo.PosParameter AS pp ON rv.Id = pp.RetailerId 
WHERE pp.[Key]='OmniChannel' AND pp.StartTrialDate IS NOT NULL AND pp.[Value] = 'False'
-- Update
UPDATE pp
SET pp.Value = 'True', pp.isActive = 1
FROM dbo._rtValidOmniTrial_PosParameter_KO5590 AS p INNER JOIN dbo.PosParameter AS pp ON p.Id = pp.Id
SELECT CONCAT(DB_NAME(),': ',@@ROWCOUNT) LogResult
"


$Result = @()
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.15 -Database KiotVietShard15
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.15 -Database KiotVietShard22
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.31 -Database KiotVietShard16	
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.39 -Database KiotVietShard7 
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.30 -Database KiotVietShard27
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.30 -Database KiotVietShard31
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.32 -Database KiotVietShard33
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 172.16.13.33 -Database KiotVietShard34
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-12-83-38  -Database KiotVietShard40 
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-21 -Database KiotViet
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-22 -Database KiotVietShard2
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-23 -Database KiotVietShard3
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-24 -Database KiotVietShard4
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-25 -Database KiotVietShard5
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-26 -Database KiotVietShard6
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-27 -Database KiotVietShard8
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-28 -Database KiotVietShard9
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-29 -Database KiotVietShard10
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-30 -Database KiotVietShard11
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-31 -Database KiotVietShard12
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-32 -Database KiotVietShard13
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-32 -Database KiotVietShard14
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-33 -Database KiotVietShard17
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-34 -Database KiotVietShard18
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-35 -Database KiotVietShard19
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-36 -Database KiotVietShard20
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-32 -Database KiotVietShard21
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-32 -Database KiotVietShard23
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-37 -Database KiotVietShard24
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-38 -Database KiotVietShard26
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-39 -Database KiotVietShard28
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-40 -Database KiotVietShard29
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-41 -Database KiotVietShard30
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-42 -Database KiotVietShard32
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-43 -Database KiotVietShard35
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-44 -Database KiotVietShard36
$Result += Invoke-Sqlcmd -Query $Query -u $user -p $password -ServerInstance 10-15-73-45 -Database KiotVietShard37

$Result | Out-File -FilePath $logFile