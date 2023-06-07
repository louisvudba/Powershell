Param(
    [Parameter(mandatory=$false)][string]$TargetServer
)

Import-Module -Name PoshRSJob

$RootPath = "G:\DBA"
$ServerPath = "$RootPath\Config\dbservers.csv"
$ServerList = @()
if ($TargetServer) {
    $ServerList += ([PSCustomObject]@{
            ServerName = $TargetServer
        })
}
else {$ServerList = Import-Csv $ServerPath -Delimiter ","}

$Params = ($RootPath)
$ServerList | Start-RSJob -Throttle $(($ServerList | Measure-Object).Count) -ArgumentList $Params -ScriptBlock {
    Param($RootPath)
    $Session = New-PSSession $_.ServerName
    
    Invoke-Command -Session $Session -Command { 
        # Create Database Folder & Permission
        Set-Volume -DriveLetter 'D' -NewFileSystemLabel 'TEMP' | Out-Null

        $path = "D:\Database"
        If (!(test-path $path)) { New-Item -ItemType Directory -Force -Path $path | Out-Null }

        $acl = Get-Acl $path
        $username  = New-Object System.Security.Principal.Ntaccount("NT SERVICE\MSSQLSERVER")
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,"FullControl",  
        [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit", 
        [system.security.accesscontrol.PropagationFlags]"None",
        "Allow")
        $acl.AddAccessRule($AccessRule)
        $acl | Set-Acl $path

        $path = "C:\Program Files\Microsoft SQL Server\130\COM"

        $acl = Get-Acl $path
        $username  = New-Object System.Security.Principal.Ntaccount("NT SERVICE\SQLSERVERAGENT")
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($username,"FullControl",  
            [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit", 
            [system.security.accesscontrol.PropagationFlags]"None",
            "Allow")
        $acl.AddAccessRule($AccessRule)
        $acl | Set-Acl $path
       
        # Init configuration
        $Query = "
            IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'CITIGO\sang.qt' AND type = 'U')
                CREATE LOGIN [CITIGO\sang.qt] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
            GO
            IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'CITIGO\tu.nc' AND type = 'U')
                CREATE LOGIN [CITIGO\tu.nc] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
            GO
            IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'CITIGO\hung.dao' AND type = 'U')
                CREATE LOGIN [CITIGO\hung.dao] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
            GO 
            IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'replicator' AND type = 'S')
                CREATE LOGIN [replicator]
                WITH PASSWORD = 0x0200c2fff9379392d76fab35e93b6c0496fcd6d6f8f7b244a09dbd71a141e9231a5332c1555775ca6d6ffc0ec0fcf546a171ab70eaa4a1495c9d872f000a4468fe7ba211169e HASHED   
                    , DEFAULT_DATABASE = [master]
                    , DEFAULT_LANGUAGE = us_english
                    , CHECK_POLICY = OFF
                    , CHECK_EXPIRATION = OFF
            GO
            ALTER SERVER ROLE [sysadmin] ADD MEMBER [replicator]
            ALTER SERVER ROLE [sysadmin] ADD MEMBER [CITIGO\sang.qt]
            ALTER SERVER ROLE [sysadmin] ADD MEMBER [CITIGO\tu.nc]
            ALTER SERVER ROLE [sysadmin] ADD MEMBER [CITIGO\hung.dao]
            GO
        "
        Invoke-Sqlcmd -u sa -p "mssql#C1t1g0@sa" -Query $Query

        $Query = "
            ALTER LOGIN [sa] DISABLE
            GO
            ALTER SERVER CONFIGURATION SET PROCESS AFFINITY CPU = 0 TO 5,7 TO 12,14 TO 19,21 TO 26
            GO
            ALTER DATABASE tempdb MODIFY FILE (NAME = [tempdev], FILENAME = 'D:\Database\tempdev.mdf');
            ALTER DATABASE tempdb MODIFY FILE (NAME = [templog], FILENAME = 'D:\Database\templog.ldf');
            ALTER DATABASE tempdb MODIFY FILE (NAME = [temp2], FILENAME = 'D:\Database\temp2.mdf');
            ALTER DATABASE tempdb MODIFY FILE (NAME = [temp3], FILENAME = 'D:\Database\temp3.mdf');
            ALTER DATABASE tempdb MODIFY FILE (NAME = [temp4], FILENAME = 'D:\Database\temp4.mdf');
            ALTER DATABASE tempdb MODIFY FILE (NAME = [temp5], FILENAME = 'D:\Database\temp5.mdf');
            ALTER DATABASE tempdb MODIFY FILE (NAME = [temp6], FILENAME = 'D:\Database\temp6.mdf');
            ALTER DATABASE tempdb MODIFY FILE (NAME = [temp7], FILENAME = 'D:\Database\temp7.mdf');
            ALTER DATABASE tempdb MODIFY FILE (NAME = [temp8], FILENAME = 'D:\Database\temp8.mdf');
            GO
            EXEC sys.sp_configure N'show advanced options', N'1' RECONFIGURE WITH OVERRIDE
            GO
            EXEC sys.sp_configure N'max server memory (MB)', N'120832' /* base on server total memory */
            EXEC sys.sp_configure N'cost threshold for parallelism', N'50'
            EXEC sys.sp_configure N'max degree of parallelism', N'6'            
            EXEC sys.sp_configure N'max text repl size (B)', N'-1'
            EXEC sys.sp_configure N'user options', N'64'
            EXEC sys.sp_configure N'blocked process threshold (s)', N'15'
            GO
            RECONFIGURE WITH OVERRIDE
            GO
            EXEC sys.sp_configure N'show advanced options', N'0' RECONFIGURE WITH OVERRIDE
            GO
            DECLARE @HostName VARCHAR(100), @ServerName VARCHAR(100)
            SELECT @HostName = HOST_NAME(), @ServerName = @@SERVERNAME
            IF @HostName <> @ServerName
            BEGIN
                EXEC sp_dropserver @ServerName
                EXEC sp_addserver @HostName, 'local'
            END
            GO
        "
        Invoke-Sqlcmd -Query $Query

        Restart-Service MSSQLSERVER -Force
        Restart-Service SQLSERVERAGENT -Force
    }
} | Wait-RSJob | Receive-RSJob

Get-RSJob | Remove-RSJob