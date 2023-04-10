$rootPath = (Split-Path $MyInvocation.MyCommand.Path)
. "$rootPath\Libs.ps1"


function Invoke-CleanOldBackupFile {
    $isPrimary = Get-ClusterCurrentStatus $env:COMPUTERNAME
    Write-Host "Current node $env:COMPUTERNAME status: $isPrimary"
    if ($isPrimary -ne 1) {        
        return
    }

    $Path = "D:\Database Backup"
    $DaysToKeep = "-14"
    $CurrentDate = Get-Date
    $DatetoDelete = $CurrentDate.AddDays($DaysToKeep)
    Get-ChildItem $Path -Recurse -filter "*.trn" | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item -Recurse
    Get-ChildItem $Path -Recurse -filter "*.bak" | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item -Recurse
}

Invoke-CleanOldBackupFile