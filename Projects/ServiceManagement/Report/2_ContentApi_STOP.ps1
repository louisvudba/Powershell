$rootPath = (Split-Path $MyInvocation.MyCommand.Path) 
. "$rootPath\..\Core\Library.ps1"
Write-Host "BEGIN"
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 7 -Type 2 -SiteNo 1 -Action STOP
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 8 -Type 2 -SiteNo 1 -Action STOP
Write-Host "END`n"
Read-Host -Prompt "Press Enter to continue"