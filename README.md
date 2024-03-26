# Guardium Data Protection REST API Examples

## Disclaimer

Code provided in examples is sufficient for demonstration/reference purposes only:

- covers success scenarios: in production proper validation and error handling are required
- ignores SSL certificates, which is not recommended in production scenarios
- may not follow best practices of specific programming language

## Overview

This guide provides examples of Guardium Data Protection REST API usage.
Please check user guide here - [Using Guardium REST APIs](https://www.ibm.com/docs/en/guardium/12.0?topic=commands-using-guardium-rest-apis)

Below you can find pre-requisites and several basic examples of Guardium REST API calls using curl (bash), powershell and python. Please check additional examples for each language/tool in detailed guides:

- [bash/curl](bash/README.md)
- [PowerShell](powershell/README.md)
- [Jupyter/Python](jupyter/README.md)

## Setup environment variables to store required settings and credentials

Guide will use .env file to store user/client credentials and other environment properties

**.env:**
```bash
GDP_BASE_URL=...      #this is URL of your Guardium appliance you typically access using GUI. Format: https://<host>:<port> (skip trailing slash)
CLIENT_ID=...         #client_id and client_secret you receive running 'grdapi register_oauth_client client_id=<client id> grant_types="password"' using CLI
CLIENT_SECRET=...     #client_id - name you provide as a part of registration, client_secret - you get as a result of client registration
GUI_USER=...          #GUI_USER and GUI_PASSWORD are user credentials for Guardium GUI with sufficient previliges to run required commands
GUI_PASSWORD=...      #most of examples will work with user having 'admin' role, example about changing user password will require user with 'accessmgr' role.
```

## Import variables from .env file

### Bash

```bash
# Set properties from .env file as environment variables (if you want to run commands on by one in terminal)
source .env

# or run this if you want environment variables to be available in bash scripts
export $(grep -v '^#' .env | xargs)
```

### Powershell

```powershell
# Read properties from .env file and set as environment variables
Get-Content .env | ForEach-Object {
    if ($_ -match '\A\s*(\w+)\s*=\s*(.*)\s*\z') {
        $envName = $Matches[1]
        $envValue = $Matches[2]
        [Environment]::SetEnvironmentVariable($envName, $envValue, 'Process')
    }
}
```

### Python

```python
#Load properties from .env file using dotenv library
env_vars = dotenv_values()

#Populate varibles with values from .env file
gdp_base_url=env_vars.get('GDP_BASE_URL')
client_id=env_vars.get('CLIENT_ID')
client_secret=env_vars.get('CLIENT_SECRET')
gui_user=env_vars.get('GUI_USER')
gui_password=env_vars.get('GUI_PASSWORD')
```

## Get access token

### Bash

```bash
curl --request POST "$GDP_BASE_URL/oauth/token?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&grant_type=password&username=$GUI_USER&password=$GUI_PASSWORD" --insecure

# store access_token value from output as $TOKEN variable: export TOKEN=<access token value> 
```

### Powershell

```powershell
$oauth_url = "$env:GDP_BASE_URL/oauth/token" 
$oauth_params = @{
    client_id = $env:CLIENT_ID
    client_secret = $env:CLIENT_SECRET
    grant_type = "password"
    username = $env:GUI_USER
    password = $env:GUI_PASSWORD
}

# Convert parameters to query string
$oauth_query_string = "" 
$oauth_params.GetEnumerator() | ForEach-Object { $oauth_query_string += $_.Key + "=" + [uri]::EscapeDataString($_.Value) + "&" }
$oauth_query_string = $oauth_query_string.TrimEnd("&") 

$oauth_url_withParam = $oauth_url + "?" + $oauth_query_string

$oauth_response = Invoke-RestMethod -Method Post -Uri $oauth_url_withParam -SkipCertificateCheck
$token = $oauth_response.access_token  
```

### Python

```python
oauth_url = f"{gdp_base_url}/oauth/token"
oauth_params = {
    'client_id': client_id,
    'client_secret': client_secret,
    'grant_type': 'password',
    'username': gui_user,
    'password': gui_password
}

oauth_response = requests.post(oauth_url, params=oauth_params, verify=False)
access_token = oauth_response['access_token']
```

## Retrieve report

### Bash

```bash
curl --header "Authorization: Bearer $TOKEN" --header 'Content-Type: application/json'  --data '{"reportName": "S-TAP Status Monitor", "reportParameter": {"SHOW_ALIASES": "Default", "REMOTE_SOURCE": "%"}}' "$GDP_BASE_URL/restAPI/online_report" --insecure
```

### Powershell

```powershell
$online_report_url = "$env:GDP_BASE_URL/restAPI/online_report"
$online_report_data = @{
    reportName = "S-TAP Status Monitor"
    reportParameter = @{
        SHOW_ALIASES = "Default" 
        REMOTE_SOURCE = "%"
    }
} | ConvertTo-Json

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$online_report_response = Invoke-RestMethod -Method Post -Uri $online_report_url -Headers $headers -Body $online_report_data -SkipCertificateCheck
```

### Python

```python
online_report_url = f"{gdp_base_url}/restAPI/online_report"
online_report_data = {
    "reportName": "S-TAP Status Monitor",
    "reportParameter": {
        "SHOW_ALIASES": "Default", 
        "REMOTE_SOURCE": "%"
    }
}

online_report_response = requests.post(online_report_url, headers=auth_headers_for_restapi, json=online_report_data, verify=False)
```