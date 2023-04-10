 # Prompt you to enter the username and password
 $credObject = Get-Credential

 # The credObject now holds the password in a ‘securestring’ format
 $passwordSecureString = $credObject.password

 # Define a location to store the AESKey
 $AESKeyFilePath = “aeskey.txt”
 # Define a location to store the file that hosts the encrypted password
 $credentialFilePath = “credpassword.txt”

 # Generate a random AES Encryption Key.
 $AESKey = New-Object Byte[] 32
 [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)

 # Store the AESKey into a file. This file should be protected! (e.g. ACL on the file to allow only select people to read)

 Set-Content $AESKeyFilePath $AESKey # Any existing AES Key file will be overwritten

 $password = $passwordSecureString | ConvertFrom-SecureString -Key $AESKey

 Add-Content $credentialFilePath $password

# =================================================================================================================== #

 #set up path and user variables
 $AESKeyFilePath = “aeskey.txt” # location of the AESKey                
 $SecurePwdFilePath = “credpassword.txt” # location of the file that hosts the encrypted password                
 $userUPN = "domain\userName" # User account login 

 #use key and password to create local secure password
 $AESKey = Get-Content -Path $AESKeyFilePath 
 $pwdTxt = Get-Content -Path $SecurePwdFilePath
 $securePass = $pwdTxt | ConvertTo-SecureString -Key $AESKey

 #crete a new psCredential object with required username and password
 $adminCreds = New-Object System.Management.Automation.PSCredential($userUPN, $securePass)

 #use the $adminCreds for some task
 some-Task-that-needs-credentials -Credential $adminCreds