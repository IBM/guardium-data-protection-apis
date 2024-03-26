# PowerShell examples of Guardium REST APIs usage

## Preparations

Make sure you have .env file with all required variables as described on [main examples page](../README.md)
Adjust path to your .env file in [GuardiumRestApiExample.ps1](./GuardiumRestApiExample.ps1)

```powershell
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
```

## Explore bash examples

Run [GuardiumRestApiExample.ps1](./GuardiumRestApiExample.ps1) without options to see Help

```powershell
PS ../guardium-guard-restapi/powershell> ./GuardiumRestApiExample.ps1
Available Actions:
AccessToken
ListAPIs -WithParams <true/false> -ApiNameLike <name to search for> (both params are optional)
ReportExample
QuickSearch
FieldList
GroupAdd -GroupName <name> (will add PUBLIC group, type USERS)
GroupDelete -GroupName <name>
GroupMemberAdd -GroupName <name> -MemberName <name>
UpdatePassword -Username <name> -NewPassword <pwd>
```

## Try listed examples

- Some examples have hardcoded inputs (ReportExample, QuickSearch). If you receive empty results, please tweak params in bash script to reflect your environment data.
- UpdatePassword example requires user with 'accessmgr' role. Make sure to update/setup corresponding environment variables to ensure REST API token is received for user with sifficient privileges

## Call examples with output

```powershell
PS ../guardium-guard-restapi/powershell> ./GuardiumRestApiExample.ps1 AccessToken

access_token                token_type expires_in scope
------------                ---------- ---------- -----
lnhqbYkurhfg0DAwg8EePzLe160 bearer          10799 read write
```

```powershell
PS /Users/mtykhenko/work-files/Security/GDP/guardium-guard-restapi/powershell> ./GuardiumRestApiExample.ps1 ListAPIs -WithParams true -ApiNameLike delete

resource_id       : 3
api_function_name : delete_datasource_by_id
resourceName      : delete_datasource_by_id
verb              : DELETE
sql_app_name      : Datasource Builder
version           : v9.5
apiDescription    : This command deletes a datasource definition identified by an identification key.
parameters        : {@{parameterName=id; parameterType=java.lang.Integer; isRequired=True; parameterDescription=Required. The identification key of the datasource to be 
                    deleted.}, @{parameterName=cascade; parameterType=java.lang.Boolean; isRequired=False; parameterDescription=Lists all the applications where the datasource 
                    is referenced. It also displays a confirmation number. Valid values: Default = 0 (false); parameterValues=System.Object[]}, 
                    @{parameterName=confirmationNumber; parameterType=java.lang.Integer; isRequired=False; parameterDescription=When the confirmation number is used, all 
                    references of the datasource are deleted. Default = 0}, @{parameterName=api_target_host; parameterType=java.lang.String; isRequired=False; 
                    parameterDescription=Specifies the target hosts where the API executes. Valid values: IP addresses must conform to the IP mode of your network. For dual IP 
                    mode, use the same IP protocol with which the managed unit is registered with the central manager. For example, if the registration uses IPv6, specify an 
                    IPv6 address. The hostname is independent of IP mode and can be used with any mode.; parameterValues=System.Object[]}}

resource_id       : 6
api_function_name : delete_datasource_by_name
resourceName      : datasource
verb              : DELETE
sql_app_name      : Datasource Builder
version           : v9.5
apiDescription    : This command deletes a datasource definition identified by name.
parameters        : {@{parameterName=name; parameterType=java.lang.String; isRequired=True; parameterDescription=Required. The datasource name.}, @{parameterName=cascade; 
                    parameterType=java.lang.Boolean; isRequired=False; parameterDescription=Lists all the applications where the datasource is referenced. It also displays a 
                    confirmation number. Valid values: Default = 0 (false); parameterValues=System.Object[]}, @{parameterName=confirmationNumber; 
                    parameterType=java.lang.Integer; isRequired=False; parameterDescription=When the confirmation number is used, all references of the datasource are deleted. 
                    Default = 0}, @{parameterName=api_target_host; parameterType=java.lang.String; isRequired=False; parameterDescription=Specifies the target hosts where the 
                    API executes. Valid values: IP addresses must conform to the IP mode of your network. For dual IP mode, use the same IP protocol with which the managed 
                    unit is registered with the central manager. For example, if the registration uses IPv6, specify an IPv6 address. The hostname is independent of IP mode 
                    and can be used with any mode.; parameterValues=System.Object[]}}

resource_id       : 7
api_function_name : delete_group_by_id
resourceName      : group
verb              : DELETE
sql_app_name      : Group Builder
version           : v9.5
apiDescription    : This command deletes a group identified by its identification key.
parameters        : {@{parameterName=id; parameterType=java.lang.Integer; isRequired=True; parameterDescription=Required. Identifies the group by its identification key.}, 
                    @{parameterName=api_target_host; parameterType=java.lang.String; isRequired=False; parameterDescription=Specifies the target hosts where the API executes. 
                    Valid values: IP addresses must conform to the IP mode of your network. For dual IP mode, use the same IP protocol with which the managed unit is 
                    registered with the central manager. For example, if the registration uses IPv6, specify an IPv6 address. The hostname is independent of IP mode and can be 
                    used with any mode.; parameterValues=System.Object[]}}

resource_id       : 10
api_function_name : delete_group_by_desc
resourceName      : group
verb              : DELETE
sql_app_name      : Group Builder
version           : v9.5
apiDescription    : This command deletes a group identified by its description.
parameters        : {@{parameterName=desc; parameterType=java.lang.String; isRequired=True; parameterDescription=Required. Identifies the group by its description.}, 
                    @{parameterName=api_target_host; parameterType=java.lang.String; isRequired=False; parameterDescription=Specifies the target hosts where the API executes. 
                    Valid values: IP addresses must conform to the IP mode of your network. For dual IP mode, use the same IP protocol with which the managed unit is 
                    registered with the central manager. For example, if the registration uses IPv6, specify an IPv6 address. The hostname is independent of IP mode and can be 
                    used with any mode.; parameterValues=System.Object[]}}

...
<more>
```
