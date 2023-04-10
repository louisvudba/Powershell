$manifest = @{
    Path                = 'BackupDatabase.psd1'
    RootModule          = 'BackupDatabase.psm1' 
    Author              = 'Louis Vu'
    CompanyName         = 'Citigo'
    FunctionsToExport   = 'Invoke-BackupSQLDatabase'
    CmdletsToExport     = ''
    VariablesToExport   = ''
    AliasesToExport     = ''
    PowerShellVersion   = '5.0'
    Tags                = 'SQLBackup'

}
New-ModuleManifest @manifest


#Import-Module .\HealthCheck

#GetInfo $Env:COMPUTERNAME
