[CmdletBinding()] 
Param
(   
    [Parameter()]
    [string]$SourcePath
    ,
    [Parameter()]
    [string]$LocalFile
    ,
    [Parameter()]
    [string]$RemotePath
    ,
    [Parameter(Mandatory = $False)]
    [string]$Option = "/J /MT:1 /COPY:DAT /Z /IS /IT /IM /NP /NJS /NJH /R:1 /W:1"
)

$Warning = "" | Select-Object Error, Detail		
    
try {
    ROBOCOPY $SourcePath $RemotePath $LocalFile $Option.Split(' ')
    
    $Warning.Error = if ($lastexitcode -eq 0 -or $lastexitcode -eq 1) { 0 } else { $lastexitcode }
    $Warning.Detail = ""
}
catch {
    $Warning.Error = 1
    $Warning.Detail = $_.Exception.Message			
}
finally {
}        
    
Write-Output $Warning
