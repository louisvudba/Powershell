function Invoke-HealthCheck {    
    <#
    .SYNOPSIS
    Doing service/api health check 
    
    .DESCRIPTION
    Verify api health check via Url
    Verify host:port health check via tcp/udp client
    
    .PARAMETER Url
    api url
    
    .PARAMETER IpAddress
    host ip address
    
    .PARAMETER Port
    port
    
    .PARAMETER Tag
    API/TCP/UDP
    
    .EXAMPLE
    Invoke-HealthCheck -Url http://local/api/hc -Tag API

    Call restful api http://local/api/hc with GET Method

    .EXAMPLE
    Invoke-HealthCheck -Address 192.168.1.1 -Port 1433 -Tag TCP

    Create request to 192.168.1.1:1433 using TcpClient

    .EXAMPLE
    Invoke-HealthCheck -IpAddress 192.168.1.1 -Port 1434 -Tag UDP

    Create request to 192.168.1.1:1434 using UdpClient
    
    .NOTES
    General notes
    #>
    [cmdletbinding(   
        DefaultParameterSetName = '',   
        ConfirmImpact = 'low'   
    )]   
    Param(
        [Parameter(   
            Mandatory = $True,   
            ParameterSetName = '',   
            ValueFromPipeline = $True)]   
        [string]$Url, 
        [Parameter(
            Mandatory = $True,   
            ParameterSetName = '')]   
        [string]$IpAddress,  
        [Parameter(
            Mandatory = $True,   
            ParameterSetName = '')]   
        [string]$Port,       
        [Parameter(   
            Mandatory = $True,   
            ParameterSetName = '')]   
        [string]$Tag     
    )
    Begin {
        $ErrorActionPreference = "SilentlyContinue"   
        $Result = @()
    }   
    Process {
        $temp = "" | Select-Object Url, IpAddress, Port, Tag, Status, Notes

        switch ($Tag) {
            "API" {
                $Response = Test-Api -Url $Url
                Break
            }
            "TCP" {
                $Response = Test-Tcp -IpAddress $IpAddress -Port $Port
                Break
            }
            "UDP" {
                $Response = Test-Udp -IpAddress $IpAddress -Port $Port
                Break
            }
            default {
                $Response = "" | Select-Object Status, Notes               
                Write-Verbose "Nothing to do"
                Break
            }
        }
        $temp.Url = $Url
        $temp.IpAddress = $IpAddress
        $temp.Port = $Port
        $temp.Tag = $Tag
        $temp.Status = $Response.Status
        $temp.Notes = $Response.Notes

        $Result += $temp
    }   
    End {
        $Result  
    } 
}

function Test-Api {
    [cmdletbinding()]
    Param(
        [Parameter(   
            Mandatory = $true,   
            ParameterSetName = '')]   
        [string]$Url
        ,
        [Parameter(   
            Mandatory = $False,   
            ParameterSetName = '')]   
        [int]$ApiTimeOut = 5
    )
    # For untrusted SSL
    add-type @"
            using System.Net;
            using System.Security.Cryptography.X509Certificates;
            public class TrustAllCertsPolicy : ICertificatePolicy {
                public bool CheckValidationResult(
                    ServicePoint srvPoint, X509Certificate certificate,
                    WebRequest request, int certificateProblem) {
                    return true;
                }
            }
"@
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    $Result = "" | Select-Object Status, Notes  
    $Result.Status = $False

    try {
        Write-Verbose "Get web request http status"
        $Response = Invoke-WebRequest -Uri $Url -Method GET -TimeoutSec $ApiTimeOut		
        
        $Result.Status = ($Response.StatusCode -eq 200)
        $Result.Notes = $Response.StatusDescription
    }
    catch {
        Write-Verbose ($global:error)[0].Exception.Message
        $Result.Notes = ($global:error)[0].Exception.Message
    }
    $Result
}
function Test-Tcp {
    [cmdletbinding()]
    Param(
        [Parameter(   
            Mandatory = $true,   
            ParameterSetName = '')]   
        [string]$IpAddress
        ,
        [Parameter(   
            Mandatory = $true,   
            ParameterSetName = '')]   
        [string]$Port
        ,
        [Parameter(   
            Mandatory = $False,   
            ParameterSetName = '')]   
        [int]$TcpTimeOut = 10000
    )
    $Result = "" | Select-Object Status, Notes
    $Result.Status = $False   
    
    $TcpObject = new-Object System.Net.Sockets.TcpClient    
    $Connect = $tcpobject.BeginConnect($IpAddress, $Port, $null, $null)   
    $Wait = $connect.AsyncWaitHandle.WaitOne($TcpTimeOut, $False)   
 
    If (!$Wait) {   
        $TcpObject.Close()   
        Write-Verbose "Connection Timeout"   
        
        $Result.Status = $False   
        $Result.Notes = "Connection to port $($Port) Timed Out"   
    }
    Else {   
        $Error.Clear()   
        $TcpObject.EndConnect($Connect) | out-Null   

        If ($global:error) {
            [string]$ErrorString = $global:error   
            $Message = (($ErrorString.Split(":")[1]).Replace('"', "")).TrimStart()   
            $IsError = $True   
        }
        $TcpObject.Close()   
      
        If ($IsError) {
            $Result.Status = $False   
            $Result.Notes = "$message"   
        }
        Else {
            $Result.Status = $True
            $Result.Notes = "OK"   
        }   
    }      
    $Result  
}
function Test-Udp {
    [cmdletbinding()]
    Param(
        [Parameter(   
            Mandatory = $true,   
            ParameterSetName = '')]   
        [string]$IpAddress
        ,
        [Parameter(   
            Mandatory = $true,   
            ParameterSetName = '')]   
        [string]$Port
        ,
        [Parameter(   
            Mandatory = $False,   
            ParameterSetName = '')]   
        [int]$UdpTimeOut = 10000
    )
    $Result = "" | Select-Object Status, Notes
    $Result.Status = $False
		  
    $UdpObject = new-Object System.Net.Sockets.Udpclient     
    $UdpObject.Client.ReceiveTimeout = $UdpTimeOut  
                  
    Write-Verbose "Making UDP connection to remote server"  
    $UdpObject.Connect("$IpAddress", $Port)  
    
    Write-Verbose "Sending message to remote host"  
    $Obj = new-object System.text.AsciiEncoding  
    $ByteForSent = $Obj.GetBytes("$(Get-Date)")  
    [void]$UdpObject.Send($ByteForSent, $ByteForSent.Length)  
 
    Write-Verbose "Creating remote endpoint"  
    $RemoteEndPoint = New-Object System.Net.IpEndPoint([System.Net.IpAddress]::Any, 0)  
    Try {
        Write-Verbose "Waiting for message return"  
        $ReceiveBytes = $UdpObject.Receive([ref]$RemoteEndPoint)  
        [string]$ReturnData = $Obj.GetString($ReceiveBytes) 
        If ($ReturnData) { 
            Write-Verbose "Connection Successful"
            
            $Result.Notes = "Connection Successful"
            $UdpObject.Close()    
        }                        
    }
    Catch {
        If ($global:error -match "\bRespond after a period of time\b") {
            $UdpObject.Close()   
            
            If (Test-Connection -comp $IpAddress -count 1 -quiet) {  
                Write-Verbose "Connection Open"   
                
                $Result.Status = $True   
                $Result.Notes = "Respond after a period of time"  
            }
            Else {                  
                Write-Verbose "Host maybe unavailable"   
                
                $Result.Status = $False   
                $Result.Notes = "Unable to verify if port is open or if host is unavailable."                                  
            }                          
        }
        ElseIf ($global:error -match "forcibly closed by the remote host" ) {              
            $UdpObject.Close()   
            Write-Verbose "Connection Timeout"   
           
            $Result.Status = $False   
            $Result.Notes = "Connection to Port Timed Out"
        }
        Else {		
            $UdpObject.close()
            Write-Verbose "Unknow result"   
           
            $Result.Status = $False   
            $Result.Notes = $global:error			
        }  
    }      
    finally {
        $Result
    }
}