$rootPath = (Split-Path $MyInvocation.MyCommand.Path) 

Write-Host "BEGIN"
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 9 -Type 2 -SiteNo 0 -Action START
Write-Host "END`n"
Read-Host -Prompt "Press Enter to continue"