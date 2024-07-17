# Utilize the Get-Credential cmdlet to prompt for Windows authentication
$cred = Get-Credential -Message "Enter your CyberArk credentials"

#Define variables for the API endpoint
$baseUrl = "https://pvwa1.mylab.net/PasswordVault/API"
$authEndpoint = "$baseUrl/auth/ldap/Logon"
$logoffEndpoint = "$baseUrl/auth/logoff"
$SetNextPassword = "$baseUrl/Accounts/22_22/SetNextPassword/"

#Extract the username and encrypted password from the credential object
$username = $cred.UserName
$password = $cred.GetNetworkCredential().Password

#Create the body for the authentication request
$authBody = @{
    username = $username
    password = $password
} | ConvertTo-Json

#Authenticate to the CyberArk REST API to get a session token
try {
    $authResponse = Invoke-RestMethod -Uri $authEndpoint -Method 'POST' -Body $authBody -ContentType 'application/json'
    $sessionToken = $authResponse
    Write-Host "Successfully authenticated."
} catch {
    Write-Host "Failed to authenticate. Please check your credentials and try again."
    exit
}

#Create the headers for the GET requests using the session token
$headers = @{
    "Authorization" = $sessionToken
    "Content-Type" = "application/json"
}
#Parameters for next password
$body = @"

{
   "ChangeImmediately" : true,
   "NewCredentials": "z6yV3Aq{jH>q%:O0"
}

"@

#Perform POST request to set next password 
$response = Invoke-RestMethod -Uri $SetNextPassword -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json

#Logoff from session
$response = Invoke-RestMethod -Uri $logoffEndpoint -Method 'POST' -Headers $headers
Write-Host "Success...logging off"



