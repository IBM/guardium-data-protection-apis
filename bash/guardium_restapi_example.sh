#!/bin/bash

# Function to display usage information
usage() {
    echo "Precondtions: set environment variables GDP_BASE_URL, CLIENT_ID, CLIENT_SECRET, GUI_USER, GUI_PASSWORD"
    echo "Usage: $0 [OPTION] [PARAMETERS...]"
    echo "Options:"
    echo "  -t, --access-token       : Get OAuth Token. No parameters, all required inputs are defined as environment variables"
    echo "  -la, --list-apis         : List available REST API endpoints. Parameters (optional): --withParams (it's flag, no value), --apiNameLike <value>"
    echo "  -re, --report-example    : Get S-TAP Status Monitor report"
    echo "  -qs, --quick-search      : Quick search example for category ACCESS, filtered by DB Type MS SQL SERVER"
    echo "  -ft, --field-titles      : Field titles for Quick search results view"
    echo "  -ga, --group-add         : Create new PUBLIC group of USERS: creates group and then gets created group details. Parameters: --name <group name>"
    echo "  -gd, --group-delete      : Delete group by name. Parameters: --name <group name>"
    echo "  -gma, --group-member-add : Add member to existing group by it's name. List group members. Parameters: --name <group name>, --member-name <member to add>"
    echo "  -up, --update-password   : Update user password. Requires accessmrg user credentials . Parameters: --name <user name>, --password <password to set>"
    exit 1
}

# Default behavior if no option is provided
if [[ $# -eq 0 ]]; then
    usage
fi

action=""
withParams=false
apiNameLike=""
name=""
memberName=""
password=""

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -t|--token)
            action=token
            shift
            ;;
        -la|--list-apis)
            action="list-apis"
            shift
            ;;
        --withParams)
            # Optional parameter for action list-apis
            withParams=true
            shift
            ;;
        --apiNameLike)
            # Optional parameter for action list-apis
            apiNameLike="$2"
            shift 2
            ;;
        -re|--report)
            action="report-example"
            shift
            ;;
        -qs|--quick-search)
            action="quick-search"
            shift
            ;;
        -ft|--field-titles)
            action="field-titles"
            shift
            ;;
        -ga|--group-add)
            action="group-add"
            shift
            ;;
        -gd|--group-delete)
            action="group-delete"
            shift
            ;;
        --name)
            # Name parameter for action group-add, group-delete, group-member-add, update-password 
            name="$2"
            shift 2
            ;;
        -gma|--group-member-add)
            action="group-member-add"
            shift
            ;;
        --member-name)
            # Member name parameter for action group-member-add 
            memberName="$2"
            shift 2
            ;;
        -up|--update-password)
            action="update-password"
            shift
            ;;
        --password)
            # New password for user, action update-password 
            password="$2"
            shift 2
            ;;     
        *)
            action="usage"
            shift 
            ;;
    esac
done

# Function to URL encode a string
urlencode() {
  # Usage: urlencode "string"
  local string="$1"
  printf '%s' "$string" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g'
}

# Function to get access token and set is as environment variable 
get_access_token() {
    curl_response=$(curl --request POST "$GDP_BASE_URL/oauth/token?client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET&grant_type=password&username=$GUI_USER&password=$GUI_PASSWORD" -s --insecure)
    if [[ "$1" = "printResponse" ]]; then
        echo $curl_response
    else
        echo $(echo "$curl_response" | grep -o '"access_token":"[^"]*' | awk -F'"' '{print $4}')
    fi
}

echo "Action to execute: $action"

#Execute action
case $action in
    "token")
        # Get Oauth token
        get_access_token "printResponse"

        ;;
    "list-apis")
        # Get access token for subsequent API call
        access_token=$(get_access_token)

        # Get available REST API endpoints. 
        requestParams=""
        if $withParams; then
            requestParams="?withParameters=1"
        fi

        # Append apiNameLike if provided
        if [[ -n "$apiNameLike" ]]; then
            if [[ -n "$requestParams" ]]; then
                requestParams="${requestParams}&apiNameLike=$apiNameLike"
            else
                requestParams="?apiNameLike=$apiNameLike"
            fi
        fi

        curl --header "Authorization: Bearer $access_token" "$GDP_BASE_URL/restAPI/restapi${requestParams}" --insecure 

        ;;
    "report-example")
        # Get access token for subsequent API call
        access_token=$(get_access_token)

        # Get S-STAP status monitor report
        curl --header "Authorization: Bearer $access_token" --header 'Content-Type: application/json'  --data '{"reportName": "S-TAP Status Monitor", "reportParameter": {"SHOW_ALIASES": "Default", "REMOTE_SOURCE": "%"}}' "$GDP_BASE_URL/restAPI/online_report" --insecure
        
        ;;
    "quick-search")
        # Get access token for subsequent API call
        access_token=$(get_access_token)

        ## Quick search for ERRORs for MS SQL SERVER databases
        curl --header "Authorization: Bearer $access_token" --header 'Content-Type: application/json'  --data '{"category": "ACCESS", "inputTZ": "UTC", "startTime": "20240301 00:00:01", "endTime": "20240320 23:00:11", "filters":"name=DB Type&value=MS SQL SERVER"}' "$GDP_BASE_URL/restAPI/quick_search" --insecure        

        ;;
    "field-titles")
        # Get access token for subsequent API call
        access_token=$(get_access_token)

        #List fieldsTitles
        curl --header "Authorization: Bearer $access_token" "$GDP_BASE_URL/restAPI/fieldsTitles" --insecure

        ;;
    "group-add")
        # Get access token for subsequent API call
        access_token=$(get_access_token)

        ## Create group with appid=PUBLIC and type=USERS with provided 
        curl --header "Authorization: Bearer $access_token" --header 'Content-Type: application/json'  --data "{\"appid\": \"PUBLIC\", \"type\": \"USERS\", \"desc\": \"$name\"}" "$GDP_BASE_URL/restAPI/group" --insecure        

        ## Get created group details
        curl --header "Authorization: Bearer $access_token" "$GDP_BASE_URL/restAPI/group?desc=$(urlencode "$name")" --insecure 
        ;;
    "group-delete")
        # Get access token for subsequent API call
        access_token=$(get_access_token)

        ## Delete group by name
        curl --header "Authorization: Bearer $access_token" -X DELETE "$GDP_BASE_URL/restAPI/group?desc=$(urlencode "$name")" --insecure 
        ;;
    "group-member-add")
        # Get access token for subsequent API call
        access_token=$(get_access_token)

        ## Add member to group by group name 
        curl --header "Authorization: Bearer $access_token" --header 'Content-Type: application/json'  --data "{\"desc\": \"$name\", \"member\": \"$memberName\"}" "$GDP_BASE_URL/restAPI/group_member" --insecure        

        ## List group members
        curl --header "Authorization: Bearer $access_token" "$GDP_BASE_URL/restAPI/group_members_by_group_desc?desc=$(urlencode "$name")" --insecure 
        ;;
    "update-password")
        # Get access token for subsequent API call
        access_token=$(get_access_token)

        ## Update user password 
        curl --header "Authorization: Bearer $access_token" --header 'Content-Type: application/json' -X PUT --data "{\"userName\": \"$name\", \"password\": \"$password\", \"confirmPassword\": \"$password\"}" "$GDP_BASE_URL/restAPI/user" --insecure        

        ;;  
    *)
        #Display help/usage infor
        usage

        ;;
esac
