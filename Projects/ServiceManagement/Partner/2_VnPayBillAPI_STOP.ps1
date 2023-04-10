$rootPath = (Split-Path $MyInvocation.MyCommand.Path) 

Write-Host "BEGIN"
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 3 -Type 2 -SiteNo 6 -Action STOP
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 4 -Type 2 -SiteNo 6 -Action STOP
Write-Host "END`n"
Read-Host -Prompt "Press Enter to continue"