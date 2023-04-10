Param(   
    [string] $Type
)
$Type
$set = "F,D,L"
$possibleValues = $set
$set | ForEach-Object { $_.Contains($Type) }

$User = "lamvt"
$Password = ConvertTo-SecureString "hh010898" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($User, $Password)
$Query = "USE [master]
GO
CREATE LOGIN [LOUISVU\administrator] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
GO
ALTER SERVER ROLE [sysadmin] ADD MEMBER [LOUISVU\administrator]
GO
"

Invoke-Sqlcmd -ServerInstance LabEDW\SQL2019DW -Credential $Credential -Query $Query

$outFile = "G:\DBA\OUTPUTlatest.txt"
$outFileCsv = "G:\DBA\OUTPUTlatest.csv"
$outFileTxt = "G:\DBA\OUTPUT.txt"

$instance = @("172.16.41.11",
"172.16.41.12",
"172.16.41.13",
"172.16.41.14",
"172.16.41.15",
"172.16.41.16",
"172.16.41.17",
"172.16.41.18",
"172.16.41.19",
"172.16.41.20",
"172.16.41.21",
"172.16.41.23",
"172.16.41.24")

$database = "monitoring"
$user = "replicator"
$pass = "kiotviet@1"

$password = ConvertTo-SecureString $pass -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($user, $password)

# $query = Get-Content "G:\DBA\getmsdbbackuphistory.sql" | Out-String
$query = Get-Content "G:\DBA\getbkhistoryerr.sql" | Out-String

$Result = @()
$instance | ForEach-Object {    
    $Dataset = Invoke-DbaQuery -Query $query -SqlCredential $Cred -SqlInstance $_ -Database $database -ErrorAction Stop | 
                Select-Object database_name, backup_type, backup_start_date, backup_finish_date, create_date
    $Result += $Dataset
}

# $Result | Sort-Object -Property database_name | Group-Object -Property database_name |
#     #Foreach { $_.Group | Sort create_date -Descending | Select -First 1 } |
#     Out-File -FilePath $outFile 

# $Result | Sort-Object -Property database_name | Group-Object -Property database_name |
#     Foreach { $_.Group | Sort create_date -Descending | Select -First 1 } |
#     Export-Csv -Path $outFileCsv -Delimiter ',' -Encoding "unicode"

# $Data = @()
# $Result | ForEach-Object {
#     $timestamp = Get-Date -Format “yyyy-MM-ddTHH:mm:ssK”
#     $json = @{
#         "@timestamp" = $_.backup_start_date;
#         "data" = $_
#     } | ConvertTo-Json -Compress 
#     $Data += $json
# }

# $data | Out-File -FilePath $outFileTxt 
