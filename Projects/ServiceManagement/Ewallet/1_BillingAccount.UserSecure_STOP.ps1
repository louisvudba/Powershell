$rootPath = (Split-Path $MyInvocation.MyCommand.Path) 

Write-Host "BEGIN"
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 1 -Type 1 -ServiceNo 3 -Action STOP
& "$rootPath\..\Core\ProcessServiceControl.ps1" -ServerNo 2 -Type 1 -ServiceNo 3 -Action STOP
Write-Host "END`n"
Read-Host -Prompt "Press Enter to continue"