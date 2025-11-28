# Resource Group and Storage Account Workflow

This env0 workflow orchestrates the deployment of a resource group followed by a storage account within that resource group.

## Workflow Structure

The workflow consists of two environments:

1. **resource_group**: Creates the Azure resource group
2. **storage_account**: Creates the storage account in the resource group (depends on resource_group)

## Setup Instructions

### 1. Create the Workflow Template in env0

1. In env0, create a new template
2. Select **env0 Workflow** as the Template Type
3. In the VCS step:
   - Repository: `https://github.com/geral-qempire/terraform-stacks`
   - Path: `workflows/resource_group_storage_account_workflow`
   - Select your GitHub installation
4. Save the template

### 2. Configure Environment Variables

#### Global Workflow Variables

Set these at the workflow/template level:

- `GITHUB_INSTALLATION_ID`: Your GitHub installation ID for env0

#### Resource Group Environment Variables

Configure the following variables for the `resource_group` environment:

- `TF_VAR_project_name`: Project identifier
- `TF_VAR_environment`: Environment short name (dev, qua, prd, ...)
- `TF_VAR_location`: Azure region (default: "North Europe")
- `TF_VAR_infra_subscription_id`: Subscription ID hosting the resource group
- `TF_VAR_cost_center`: Cost center tag
- `TF_VAR_business_unit`: Business unit tag
- `TF_VAR_application_name`: Application name tag
- `TF_VAR_application_code`: Application code tag
- `TF_VAR_name_random_postfix`: (optional) Append random postfix to names (default: false)
- `TF_VAR_additional_tags`: (optional) Additional tags as JSON map
- `TF_VAR_write_access_principals`: (optional) List of principals for Contributor role
- `TF_VAR_read_access_principals`: (optional) List of principals for Reader role
- `TF_VAR_alert_access_principals`: (optional) List of principals for Alert Operator role

#### Storage Account Environment Variables

Configure the following variables for the `storage_account` environment:

**Critical**: Set `TF_VAR_resource_group_name` to reference the output from the resource_group environment:
```
TF_VAR_resource_group_name = ${resource_group.resource_group_name}
```

**Other required variables:**

- `TF_VAR_project_name`: Project identifier
- `TF_VAR_org_code`: (optional) Organization code
- `TF_VAR_environment`: Environment short name (dev, qua, prd, ...)
- `TF_VAR_location`: Azure region (default: "North Europe")
- `TF_VAR_infra_subscription_id`: Subscription ID hosting the storage account
- `TF_VAR_dns_subscription_id`: (optional) DNS subscription ID
- `TF_VAR_dns_resource_group_name`: Resource group containing private DNS zones
- `TF_VAR_cost_center`: Cost center tag
- `TF_VAR_business_unit`: Business unit tag
- `TF_VAR_application_name`: Application name tag
- `TF_VAR_application_code`: Application code tag
- `TF_VAR_name_random_postfix`: (optional) Append random postfix to names (default: false)
- `TF_VAR_additional_tags`: (optional) Additional tags as JSON map

**Storage configuration:**

- `TF_VAR_storage_tier`: Storage tier (bronze, silver, gold, plat, diamond, override)
- `TF_VAR_versioning_tier`: Versioning tier (bronze, silver, gold, platinum, diamond, override)
- `TF_VAR_smart_lifecycle_tier`: Lifecycle tier (off, on, override)
- `TF_VAR_identity`: (optional) Managed identity configuration as JSON object

**Networking configuration:**

- `TF_VAR_allowed_ip_addresses`: (optional) List of allowed IP addresses
- `TF_VAR_network_rules_bypass`: (optional) Services that bypass network rules
- `TF_VAR_enable_private_endpoint_blob`: (optional) Enable blob private endpoint (default: true)
- `TF_VAR_enable_private_endpoint_file`: (optional) Enable file private endpoint (default: false)
- `TF_VAR_enable_private_endpoint_queue`: (optional) Enable queue private endpoint (default: false)
- `TF_VAR_enable_private_endpoint_table`: (optional) Enable table private endpoint (default: false)
- `TF_VAR_private_endpoint_subnet_name`: (optional) Subnet name for private endpoints
- `TF_VAR_private_endpoint_virtual_network_name`: (optional) VNet name for private endpoints
- `TF_VAR_private_endpoint_virtual_network_resource_group_name`: (optional) VNet resource group
- `TF_VAR_private_endpoint_location`: (optional) Location override for private endpoints

**RBAC configuration:**

- `TF_VAR_write_access_principals`: (optional) List of principals for write access
- `TF_VAR_read_access_principals`: (optional) List of principals for read access
- `TF_VAR_alert_access_principals`: (optional) List of principals for alert access

**Alerting configuration:**

- `TF_VAR_golden_signal_alert_emails`: (optional) Map of email addresses for alerts
- `TF_VAR_golden_signal_action_group_ids`: (optional) List of action group IDs
- `TF_VAR_enable_base_alerts`: (optional) Enable base alerts (default: true)
- `TF_VAR_enable_blob_alerts`: (optional) Enable blob alerts (default: true)
- `TF_VAR_enable_file_alerts`: (optional) Enable file alerts (default: true)
- `TF_VAR_enable_queue_alerts`: (optional) Enable queue alerts (default: false)

### 3. Deploy the Workflow

1. Create an environment from the workflow template
2. Select either `resource_group` or `storage_account` from the environment dropdown
3. Configure the variables as described above
4. Deploy the workflow

The workflow will automatically:
- Deploy the resource_group environment first
- Wait for it to complete successfully
- Then deploy the storage_account environment, which will use the resource group name from the first environment

## Outputs

### Resource Group Environment Outputs

- `resource_group_name`: Generated resource group name
- `resource_group_id`: Resource ID of the deployed resource group
- `resource_group_location`: Azure region where the resource group resides
- `resource_group_subscription_id`: Subscription ID hosting the resource group
- `resource_group_tags`: Final tag set applied to the resource group

### Storage Account Environment Outputs

Refer to the storage_account_stack outputs for available values.

## Notes

- The workflow uses `environmentRemovalStrategy: destroy` which means removed environments will be automatically destroyed
- Both environments use Terraform version 1.7.5
- The storage_account environment depends on resource_group via the `needs` field in the workflow configuration
- Make sure to set `TF_VAR_resource_group_name` in the storage_account environment to reference `${resource_group.resource_group_name}` to pass the resource group name from the first environment

