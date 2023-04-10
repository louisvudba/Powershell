$rootPath = (Split-Path $MyInvocation.MyCommand.Path) 
. "$rootPath\..\Core\Library.ps1"
Write-Host "BEGIN"
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 10 -Type 1 -ServiceNo 4 -Action START
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 11 -Type 1 -ServiceNo 4 -Action START
Write-Host "END`n"
Read-Host -Prompt "Press Enter to continue"