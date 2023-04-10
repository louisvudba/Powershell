$rootPath = (Split-Path $MyInvocation.MyCommand.Path) 

Write-Host "BEGIN"
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 10 -Type 1 -ServiceNo 1 -Action STOP
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 11 -Type 1 -ServiceNo 1 -Action STOP
Write-Host "END`n"
Read-Host -Prompt "Press Enter to continue"