# Bash examples of Guardium REST APIs usage

## Preparations

Make sure you have .env file with all required variables as described on [main examples page](../README.md)
Have variables exported into environment to make them available for bash script.

```bash
export $(grep -v '^#' .env | xargs)
```

## Explore bash examples

Run [guardium_restapi_example.sh](./guardium_restapi_example.sh) without options to see Help

```bash
❯ ./guardium_restapi_example.sh
Precondtions: set environment variables GDP_BASE_URL, CLIENT_ID, CLIENT_SECRET, GUI_USER, GUI_PASSWORD
Usage: ./guardium_restapi_example.sh [OPTION] [PARAMETERS...]
Options:
  -t, --access-token       : Get OAuth Token. No parameters, all required inputs are defined as environment variables
  -la, --list-apis         : List available REST API endpoints. Parameters (optional): --withParams (its flag, no value), --apiNameLike <value>
  -re, --report-example    : Get S-TAP Status Monitor report with default params
  -qs, --quick-search      : Quick search example for category ACCESS, filtered by DB Type MS SQL SERVER
  -ft, --field-titles      : Field titles of Quick search results view
  -ga, --group-add         : Create new PUBLIC group of USERS, creates group and then gets created group details. Parameters: --name <group name>
  -gd, --group-delete      : Delete group by name. Parameters: --name <group name>
  -gma, --group-member-add : Add member to existing group by its name. List group members. Parameters: --name <group name>, --member-name <member to add>
  -up, --update-password   : Update user password. Requires accessmrg user credentials . Parameters: --name <user name>, --password <password to set>
```

## Try listed examples

- Some examples have hardcoded inputs (--report-example, --quick-search). If you receive empty results, please tweak params in bash script to reflect your environment data.
- --update-password example requires user with 'accessmgr' role. Make sure to update/setup corresponding environment variables to ensure REST API token is received for user with sifficient privileges

## Call examples with output

```bash
❯ ./guardium_restapi_example.sh -t
Action to execute: token
{"access_token":"s2R4IJR57_Aaa8BqFqZP3vG3qbU","token_type":"bearer","expires_in":10799,"scope":"read write"}
```

```bash
❯ ./guardium_restapi_example.sh -la --withParams --apiNameLike delete_group
Action to execute: list-apis
[
  {
    "resource_id": 7,
    "api_function_name": "delete_group_by_id",
    "resourceName": "group",
    "verb": "DELETE",
    "sql_app_name": "Group Builder",
    "version": "v9.5",
    "apiDescription": "This command deletes a group identified by its identification key.",
    "parameters": [
      {
        "parameterName": "id",
        "parameterType": "java.lang.Integer",
        "isRequired": true,
        "parameterDescription": "Required. Identifies the group by its identification key."
      },
      {
        "parameterName": "api_target_host",
        "parameterType": "java.lang.String",
        "isRequired": false,
        "parameterDescription": "Specifies the target hosts where the API executes. Valid values: IP addresses must conform to the IP mode of your network. For dual IP mode, use the same IP protocol with which the managed unit is registered with the central manager. For example, if the registration uses IPv6, specify an IPv6 address. The hostname is independent of IP mode and can be used with any mode.",
        "parameterValues": [
          "all_managed: execute on all managed units but not the central manager",
          "all: execute on all managed units and the central manager",
          "group:<group name>: execute on all managed units identified by <group name>",
          "host name or IP address of a managed unit: specified from the central manager to execute on a managed unit. For example, api_target_host=10.0.1.123.",
          "host name or IP address of the central manager: specified from a managed unit to execute on the central manager. For example, api_target_host=10.0.1.123."
        ]
      }
    ]
  },
  {
    "resource_id": 10,
    "api_function_name": "delete_group_by_desc",
    "resourceName": "group",
    "verb": "DELETE",
    "sql_app_name": "Group Builder",
    "version": "v9.5",
    "apiDescription": "This command deletes a group identified by its description.",
    "parameters": [
      {
        "parameterName": "desc",
        "parameterType": "java.lang.String",
        "isRequired": true,
        "parameterDescription": "Required. Identifies the group by its description."
      },
      {
        "parameterName": "api_target_host",
        "parameterType": "java.lang.String",
        "isRequired": false,
        "parameterDescription": "Specifies the target hosts where the API executes. Valid values: IP addresses must conform to the IP mode of your network. For dual IP mode, use the same IP protocol with which the managed unit is registered with the central manager. For example, if the registration uses IPv6, specify an IPv6 address. The hostname is independent of IP mode and can be used with any mode.",
        "parameterValues": [
          "all_managed: execute on all managed units but not the central manager",
          "all: execute on all managed units and the central manager",
          "group:<group name>: execute on all managed units identified by <group name>",
          "host name or IP address of a managed unit: specified from the central manager to execute on a managed unit. For example, api_target_host=10.0.1.123.",
          "host name or IP address of the central manager: specified from a managed unit to execute on the central manager. For example, api_target_host=10.0.1.123."
        ]
      }
    ]
  }
]
```