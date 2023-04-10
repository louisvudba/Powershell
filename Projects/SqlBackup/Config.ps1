$SqlInstance = "LAMVT1FINTECH\SQL2019"
$SqlBackupDir = "D:\Database Backup"
$SqlDbExclude = "AdventureWorksDW2019", "StackOverflow2013", "StackOverflow"
$DbUser = "lamvt"
$DbPassword = "hh010898"
$ValidateClusterNode = @("MBFHN-WALLETDB2", "MBFHN-WALLETDB1")
$ValidateBackupType = @("F", "D", "L")