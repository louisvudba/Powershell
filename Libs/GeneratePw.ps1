#$KeyFile = ".\AES.key"
#$Key = New-Object Byte[] 32   # You can use 16, 24, or 32 for AES
#[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
#$Key | out-file $KeyFile
   
$PasswordFile = "E:\Repositories\Citigo\cluster-citigo-dba\Powershell\Credentials\Password_Mail.txt"
$KeyFile = "E:\Repositories\Citigo\cluster-citigo-dba\Powershell\Credentials\PrivateKey.txt"
$Key = Get-Content $KeyFile
$Password = "" | ConvertTo-SecureString -AsPlainText -Force
$Password | ConvertFrom-SecureString -key $Key | Out-File $PasswordFile
   
#$User = "sa"
#$PasswordFile = ".\Password.txt"
#$KeyFile = ".\AES.key"
#$key = Get-Content $KeyFile
#$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $PasswordFile | ConvertTo-SecureString -Key $key)
   
#$MyCredential