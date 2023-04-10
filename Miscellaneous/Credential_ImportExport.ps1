# 1 
$Credential = Get-Credential

# 2
$USER = ""
$PASSWORD = ""

$HASH_PASSWORD = ConvertTo-SecureString $PASSWORD -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($USER, $HASH_PASSWORD)

# Export
Export-Clixml -InputObject $Credential -Path ""
$Credential | Export-Clixml -Path ""

# Import
$Path = "$(Split-Path $MyInvocation.MyCommand.Path)\Credential.xml"
$Credential = Import-Clixml -Path $Path