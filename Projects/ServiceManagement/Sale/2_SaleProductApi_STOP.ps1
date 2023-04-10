$rootPath = (Split-Path $MyInvocation.MyCommand.Path) 

Write-Host "BEGIN"
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 10 -Type 2 -SiteNo 1 -Action STOP
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 11 -Type 2 -SiteNo 1 -Action STOP
Write-Host "END`n"
Read-Host -Prompt "Press Enter to continue"