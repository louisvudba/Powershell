Param(
    [Parameter(mandatory=$false)][string]$TargetServer,
    [Parameter(mandatory=$false)][string]$DatabaseName
)

Import-Module -Name PoshRSJob

$RootPath = "G:\DBA"
$DiskSpdArgs = "-b8K -d180 -h -L -o32 -t3 -r -w75 -c5G -Z10M F:\DiskSpd\IO.dat"
$LogFile = "$RootPath\Reports\IODianogstic\IO.LOG"
$Ts = (Get-Date).ToString("yyyy-MM-dd")
$ServerPath = "$RootPath\Config\dbservers.csv"
$ServerList = @()
if ($TargetServer) {
    $ServerList += ([PSCustomObject]@{
            ServerName = $TargetServer
            DBName = $DatabaseName
        })
}
else {$ServerList = Import-Csv $ServerPath -Delimiter ","}

$Data = @()

$Params = ($DiskSpdArgs,$RootPath,$LogFile,$Ts)
$ServerList | Start-RSJob -Throttle $(($ServerList | Measure-Object).Count) -ArgumentList $Params -ScriptBlock {
	Param($DiskSpdArgs,$RootPath,$LogFile,$Ts)
    $TargetServer = $_.ServerName
    $DatabaseName = $_.DBName
    Write-Host ("{0} - {1}" -f $TargetServer, $DatabaseName)

    $Session = New-PSSession $TargetServer
    $TxtLogFile = "DiskSpdTests_{0}_{1}.txt" -f $TargetServer.Replace("-","_"), $DatabaseName	
	$DestFilePath = "F:\DiskSpd.zip"
	$DiskspdPath = "F:\DiskSpd"	

    Copy-Item -Path "$RootPath\Source\DiskSpd.zip" -Destination $DestFilePath -ToSession $session -Force  
    Invoke-Command -Session $session -ArgumentList $DiskspdPath, $DestFilePath, $DiskSpdArgs -Command {
		Param($DiskspdPath, $DestFilePath, $DiskSpdArgs)
        If (!(test-path $DiskspdPath)) { New-Item -ItemType Directory -Force -Path $DiskspdPath | Out-Null}
		Else { Remove-Item $DiskspdPath }
        Expand-Archive $DestFilePath -DestinationPath $DiskspdPath
        Remove-Item $DestFilePath	
		
		#Test Command
        #Write-Output "$DiskspdPath\amd64\diskspd.exe $:DiskSpdArgs"		
		Invoke-Expression "$DiskspdPath\amd64\diskspd.exe $:DiskSpdArgs" | Select-String -pattern "total:" > "F:\DiskSpd\output.txt"
    }	 

    Copy-Item -Destination "$RootPath\Log\$TxtLogFile" -Path "F:\DiskSpd\output.txt" -FromSession $session -Force  
	$ResultGrid = Get-Content "$RootPath\Log\$TxtLogFile"
	Remove-Item "$RootPath\Log\$TxtLogFile"

	$Count = 0
	$ResultName = ""
	foreach ($line in $ResultGrid) {		
		if ($Count -eq 1) { $ResultName = "Total IO" }
		elseif ($Count -eq 2) { $ResultName = "Read IO" }
		elseif ($Count -eq 3) { $ResultName = "Write IO" }
		if ($line -like "total:*" -and $Count -lt 4) {			
			$mbps = $line.Split("|")[2].Trim()
			$iops = $line.Split("|")[3].Trim()
			$latency = $line.Split("|")[4].Trim()
			$totalbytes = $line.Split("|")[1].Trim()
			
			Write-Output ([PSCustomObject]@{
				TimeStamp = $Ts
				ServerName = $TargetServer
				DatabaseName = $DatabaseName
				ParamType = $ResultName
				TotalSize = $totalbytes
				Iops = $iops
				Mbps = $mbps
				AvgLat = $latency
			}) | ConvertTo-Json -Compress
		}
		$Count += 1
	}

    Invoke-Command -Session $session -Command {
        Remove-Item F:\DiskSpd -Force -Recurse        
    }
	Write-Output $FinalResult
} | Wait-RSJob | Foreach-Object { 
	$Job = Get-RSJob $_
	$Data += $Job | Receive-RSJob 
	$Job | Remove-RSJob	
}

$Data | Out-File -FilePath $LogFile -Append