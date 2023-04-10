# ENTRY POINT MAIN()
Param(
    [Parameter(Mandatory=$true)]
    $SvrName = "",
    [Parameter(Mandatory=$true)]
    $SiteName = "",
    [Parameter(Mandatory=$true)]
    $Action = ""
)

$rootPath = (Split-Path $MyInvocation.MyCommand.Path)
. "$rootPath\Library.ps1"

Update-IISWebsiteStatus -server $SvrName -site $SiteName -a $Action