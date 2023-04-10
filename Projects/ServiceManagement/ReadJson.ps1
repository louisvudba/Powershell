# ENTRY POINT MAIN()
Param(
    [Parameter(Mandatory=$false)]
    $ServerNo = 0,
    [Parameter(Mandatory=$false)]
    $ServiceNo = 0,
    [Parameter(Mandatory=$false)]
    $IISNo = 0,
    [Parameter(Mandatory=$true)]
    $ActionType = ""
)
<# Test Data 
ForEach ($serv in $json){
    "Id: {0}" -f $serv.id
    "Name: {0}" -f $serv.server
    "Services: {0}" -f $serv.services    
}
#>
. (Split-Path $MyInvocation.InvocationName) + "\Core\Library.ps1"

CallScript($ServerNo, $ServiceNo, $IISNo, $ActionType)