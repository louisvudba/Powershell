$rootPath = (Split-Path $MyInvocation.MyCommand.Path) 

Write-Host "BEGIN"
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 5 -Type 2 -SiteNo 1 -Action STOP
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 6 -Type 2 -SiteNo 1 -Action STOP
Write-Host "END`n"
Read-Host -Prompt "Press Enter to continue"