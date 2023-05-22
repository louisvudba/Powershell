[CmdletBinding()] 
Param
(   
    [String] [Parameter(Mandatory = $true)]
    $ServerName,
    [string] [Parameter(Mandatory = $true)]
    $Path  
)

$session = New-PSSession $ServerName


try {            
    Invoke-Command -Session $session -ArgumentList $Path -Command { 
        param($Path)

        $acl = Get-Acl $Path
        $username  = New-Object System.Security.Principal.Ntaccount("NT SERVICE\MSSQLSERVER")
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,"FullControl",  
        [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit", 
        [system.security.accesscontrol.PropagationFlags]"None",
        "Allow")
        $acl.AddAccessRule($AccessRule)
        $acl | Set-Acl $path
    }
}
catch {
    Write-Error "Error: $_"
}

$session | Remove-PSSession