# ENTRY POINT MAIN()
Param(
    [Parameter(Mandatory=$true)]
    $SvrName = "",
    [Parameter(Mandatory=$true)]
    $SvcName = "",
    [Parameter(Mandatory=$true)]
    $Action = ""
)
$rootPath = (Split-Path $MyInvocation.MyCommand.Path)
. "$rootPath\Library.ps1"

Update-ServiceStatus -server $SvrName -service $SvcName -a $Action