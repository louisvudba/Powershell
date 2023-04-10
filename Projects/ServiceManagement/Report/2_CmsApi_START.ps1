$rootPath = (Split-Path $MyInvocation.MyCommand.Path) 

Write-Host "BEGIN"
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 7 -Type 2 -SiteNo 3 -Action START
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 8 -Type 2 -SiteNo 3 -Action START
Write-Host "END`n"
Read-Host -Prompt "Press Enter to continue"