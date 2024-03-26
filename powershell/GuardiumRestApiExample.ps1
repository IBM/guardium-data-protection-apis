function Read-EnvironmentVariables {
    # Read environment variables from .env file
    Get-Content ../.env | ForEach-Object {
        if ($_ -match '\A\s*(\w+)\s*=\s*(.*)\s*\z') {
            $envName = $Matches[1]
            $envValue = $Matches[2]
            [Environment]::SetEnvironmentVariable($envName, $envValue, 'Process')
        }
    }
}

function BuildRequestParamsString {
    param (
        [hashtable]$Data
    )

    $RequestParamsString = "" 
    $Data.GetEnumerator() | ForEach-Object { $RequestParamsString += $_.Key + "=" + [uri]::EscapeDataString($_.Value) + "&" }
    $RequestParamsString = $RequestParamsString.TrimEnd("&")
    
    return $RequestParamsString
}

function AccessToken {
    <#PrintResponse parameter is only necessary for internal script purposes
      - to print reponse when showcasing access token retrival
      - skip printing response when acquiring token to call other endpoints
    #>
    param (
        [bool]$PrintResponse = $false
    )

    $oauth_url = "$env:GDP_BASE_URL/oauth/token" 
    $oauth_params = @{
        client_id = $env:CLIENT_ID
        client_secret = $env:CLIENT_SECRET
        grant_type = "password"
        username = $env:ACCESSMGR
        password = $env:ACCESSMGR_PASSWORD
    }

    # Convert parameters to query string
    $oauth_url_withParam = $oauth_url + "?" + (BuildRequestParamsString $oauth_params)

    $oauth_response = Invoke-RestMethod -Uri $oauth_url_withParam -Method Post -SkipCertificateCheck
    if ($PrintResponse) {
        $oauth_response
    }
    
    # return token
    return $oauth_response.access_token 
}

function ListAPIs {
    param (
        [string]$WithParams = "false",
        [string]$ApiNameLike = ""
    )

    $ListApisUrl = "$env:GDP_BASE_URL/restAPI/restapi"
    $list_api_params = @{
        withParameters = $WithParams
        apiNameLike = $ApiNameLike
    }
    
    # Convert parameters to query string
    $ListApisUrlWithParams = $ListApisUrl + "?" + (BuildRequestParamsString $list_api_params)

    $Headers = @{
        "Authorization" = "Bearer $(AccessToken)"
        "Content-Type" = "application/json"
    }
    
    Invoke-RestMethod -Method Get -Uri $ListApisUrlWithParams -Headers $headers -SkipCertificateCheck
}

function ReportExample {
    $online_report_url = "$env:GDP_BASE_URL/restAPI/online_report"
    $online_report_data = @{
        reportName = "S-TAP Status Monitor"
        reportParameter = @{
            SHOW_ALIASES = "Default" 
            REMOTE_SOURCE = "%"
        }
    } | ConvertTo-Json

    $Headers = @{
        "Authorization" = "Bearer $(AccessToken)"
        "Content-Type" = "application/json"
    }

    Invoke-RestMethod -Method Post -Uri $online_report_url -Headers $Headers -Body $online_report_data -SkipCertificateCheck
}
function QuickSearch {
    $QuickSearchUrl = "$env:GDP_BASE_URL/restAPI/quick_search"
    $QuickSearchData = @{
        category = "ACCESS"
        inputTZ = "UTC"
        startTime = "20240301 00:00:01"
        endTime = "20240320 23:00:11"
        filters = "name=DB Type&value=MS SQL SERVER"
    } | ConvertTo-Json

    $Headers = @{
        "Authorization" = "Bearer $(AccessToken)"
        "Content-Type" = "application/json"
    }

    Write-Host (Invoke-RestMethod -Method Post -Uri $QuickSearchUrl -Headers $Headers -Body $QuickSearchData -SkipCertificateCheck | ConvertTo-Json)
}

function FieldList {
    $FieldListUrl = "$env:GDP_BASE_URL/restAPI/fieldsTitles"

    $Headers = @{
        "Authorization" = "Bearer $(AccessToken)"
        "Content-Type" = "application/json"
    }

    Invoke-RestMethod -Method Get -Uri $FieldListUrl -Headers $Headers -SkipCertificateCheck 
}

function GroupAdd {
    param (
        [string]$GroupName
    )

    $GroupUrl = "$env:GDP_BASE_URL/restAPI/group"

    $GroupAddData = @{
        appid = "PUBLIC"
        type = "USERS"
        desc =  $GroupName
    } | ConvertTo-Json 

    $Headers = @{
        "Authorization" = "Bearer $(AccessToken)"
        "Content-Type" = "application/json"
    }

    #Add group
    Write-Host (Invoke-RestMethod -Method Post -Uri $GroupUrl -Headers $Headers -Body $GroupAddData -SkipCertificateCheck | ConvertTo-Json)

    #Get group to show details
    $GroupGetParams = @{
        desc =  $GroupName
    } 
    $GroupUrlWithParams = $GroupUrl + "?" + (BuildRequestParamsString $GroupGetParams)

    Write-Host (Invoke-RestMethod -Method Get -Uri $GroupUrlWithParams -Headers $Headers -SkipCertificateCheck | ConvertTo-Json)
}

function GroupDelete {
    param (
        [string]$GroupName
    )

    $GroupUrl = "$env:GDP_BASE_URL/restAPI/group"
    $Headers = @{
        "Authorization" = "Bearer $(AccessToken)"
        "Content-Type" = "application/json"
    }
    $GroupGetParams = @{
        desc =  $GroupName
    } 
    $GroupUrlWithParams = $GroupUrl + "?" + (BuildRequestParamsString $GroupGetParams) 
   
    Invoke-RestMethod -Method Delete -Uri $GroupUrlWithParams -Headers $Headers -SkipCertificateCheck 
}

function GroupMemberAdd {
    param (
        [string]$GroupName,
        [string]$MemberName
    )

    $GroupMemberAddUrl = "$env:GDP_BASE_URL/restAPI/group_member"
    $Headers = @{
        "Authorization" = "Bearer $(AccessToken)"
        "Content-Type" = "application/json"
    }
    $GroupMemberAddData = @{
        desc = $GroupName
        member = $MemberName
    } | ConvertTo-Json

    #Add group member
    Write-Host (Invoke-RestMethod -Method Post -Uri $GroupMemberAddUrl -Headers $Headers -Body $GroupMemberAddData -SkipCertificateCheck | ConvertTo-Json)

    #List group members
    $ListGroupMembersUrl = "$env:GDP_BASE_URL/restAPI/group_members_by_group_desc"
    $ListGroupMembersParams = @{
        desc =  $GroupName
    }
    $ListGroupMembersUrlWithParams = $ListGroupMembersUrl + "?" + (BuildRequestParamsString $ListGroupMembersParams) 

    Write-Host (Invoke-RestMethod -Method Get -Uri $ListGroupMembersUrlWithParams -Headers $Headers -SkipCertificateCheck | ConvertTo-Json)  
}

function UpdatePassword {
    param (
        [string]$Username,
        [string]$NewPassword
    )

    $UpdateUserUrl = "$env:GDP_BASE_URL/restAPI/user"
    $Headers = @{
        "Authorization" = "Bearer $(AccessToken)"
        "Content-Type" = "application/json"
    }
    $UpdateUserData = @{
        userName = $Username
        password = $NewPassword
        confirmPassword = $NewPassword
    } | ConvertTo-Json

    Invoke-RestMethod -Method Put -Uri $UpdateUserUrl -Headers $Headers -Body $UpdateUserData -SkipCertificateCheck
}

function Help {
    # Display help information
    Write-Host "Available Actions:"
    Write-Host "AccessToken"
    Write-Host "ListAPIs -WithParams <true/false> -ApiNameLike <name to search for> (both params are optional)"
    Write-Host "ReportExample"
    Write-Host "QuickSearch"
    Write-Host "FieldList"
    Write-Host "GroupAdd -GroupName <name> (will add PUBLIC group, type USERS)"
    Write-Host "GroupDelete -GroupName <name>"
    Write-Host "GroupMemberAdd -GroupName <name> -MemberName <name>"
    Write-Host "UpdatePassword -Username <name> -NewPassword <pwd>" 
}

# Main script

# Read environment variables
Read-EnvironmentVariables

# Parse command line arguments
$action = $args[0]
$params = @()
if ($args.Length -gt 1) {
    $params = $args[1..($args.Length - 1)]
}

# Invoke actions based on the specified action

switch ($action) {
    "AccessToken" {
        AccessToken -PrintResponse $true
    }
    "ListAPIs" {
        ListAPIs @params
    }
    "ReportExample" {
        ReportExample
    }
    "QuickSearch" {
        QuickSearch
    }
    "FieldList" {
        FieldList
    }
    "GroupAdd" {
        GroupAdd @params
    }
    "GroupDelete" {
        GroupDelete @params
    }
    "GroupMemberAdd" {
        GroupMemberAdd @params
    }
    "UpdatePassword" {
        UpdatePassword @params
    }
    "Help" {
        Help
    }
    Default {
        Help
    }
}
