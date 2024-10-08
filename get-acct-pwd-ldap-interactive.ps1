# Utilize the Get-Credential cmdlet to prompt for Windows authentication
$cred = Get-Credential -Message "Enter your CyberArk credentials"

# Define variables for the API endpoint
$baseUrl = "https://pvwa1.mylab.net/PasswordVault/API"
$authEndpoint = "$baseUrl/auth/ldap/Logon"
$logoffEndpoint = "$baseUrl/auth/logoff"

# Prompt the user to enter the account ID
$accountID = Read-Host -Prompt "Enter the account ID"

# Construct the URL for retrieving the account password dynamically
$getAccountPassword = "$baseUrl/Accounts/$accountID/Password/Retrieve"

# Extract the username and encrypted password from the credential object
$username = $cred.UserName
$password = $cred.GetNetworkCredential().Password

# Create the body for the authentication request
$authBody = @{
    username = $username
    password = $password
} | ConvertTo-Json

# Authenticate to the CyberArk REST API to get a session token
try {
    $authResponse = Invoke-RestMethod -Uri $authEndpoint -Method 'POST' -Body $authBody -ContentType 'application/json'
    $sessionToken = $authResponse
    Write-Host "Successfully authenticated."
} catch {
    Write-Host "Failed to authenticate. Please check your credentials and try again."
    exit
}

# Create the headers for the GET requests using the session token
$headers = @{
    "Authorization" = $sessionToken
    "Content-Type" = "application/json"
}

# Perform POST request for retrieving the account password 
try {
    $response = Invoke-RestMethod -Uri $getAccountPassword -Method 'POST' -Headers $headers
    $response | ConvertTo-Json
} catch {
    Write-Host "Failed to retrieve the password for account ID $accountID. Please check the account ID and try again."
    exit
}

# Log off from session
$response = Invoke-RestMethod -Uri $logoffEndpoint -Method 'POST' -Headers $headers
Write-Host "Success...logging off"
