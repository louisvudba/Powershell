$rootPath = (Split-Path $MyInvocation.MyCommand.Path) 

Write-Host "BEGIN"
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 7 -Type 2 -SiteNo 2 -Action STOP
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 8 -Type 2 -SiteNo 2 -Action STOP
Write-Host "END`n"
Read-Host -Prompt "Press Enter to continue"