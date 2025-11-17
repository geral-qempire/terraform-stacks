variable "service_prefix" {
  type        = string
  description = "Prefix or name of the project"
}

variable "location" {
  type        = string
  description = "Azure region for the deployment."
  default     = "North Europe"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the existing Resource Group where resources will be created."
}

variable "infra_subscription_id" {
  type        = string
  default     = null
  description = "Subscription ID for infrastructure resources. If null, defaults to environment-based subscription IDs."
}

variable "dns_subscription_id" {
  type        = string
  default     = null
  description = "Subscription Id where the Azure Private DNS zones are located"
}

variable "environment" {
  type        = string
  description = "Environment label (dev, qua, prd). Used for naming where upstream modules require it."
}

#####################################################################
# Private Endpoint Configuration
#####################################################################

variable "dns_hub_resource_group_name" {
  type        = string
  default     = "rg-ne-dns"
  description = "Resource group name containing the Private DNS zones for storage endpoints."
}

variable "subnet_name" {
  type        = string
  default     = "tech-infra-snet"
  description = "Subnet name for private endpoints."
}

variable "vnet_name" {
  type        = string
  default     = null
  description = "Virtual Network name for private endpoints. If null, defaults to tech-{environment}-vnet based on environment."
}

variable "vnet_resource_group_name" {
  type        = string
  default     = null
  description = "Resource Group name containing the Virtual Network. If null, defaults to tech-net{environment}-ne-rg based on environment."
}

#####################################################################
# Tier Selection
#####################################################################

variable "parameter_tier" {
  type        = string
  default     = "bronze"
  description = "Parameter tier applied to the storage account (replication, networking posture, defaults). Valid options: bronze, silver, custom."
  validation {
    condition = (
      contains(["bronze", "silver", "custom"], var.parameter_tier) &&
      (var.parameter_tier != "custom" || var.parameter_tier_custom != null)
    )
    error_message = "parameter_tier must be bronze, silver, or custom. Provide parameter_tier_custom when using custom."
  }
}

variable "parameter_tier_custom" {
  type = object({
    account_tier                      = optional(string)
    account_replication_type          = optional(string)
    account_kind                      = optional(string)
    access_tier                       = optional(string)
    public_network_access_enabled     = optional(bool)
    shared_access_key_enabled         = optional(bool)
    infrastructure_encryption_enabled = optional(bool)
    min_tls_version                   = optional(string)
    network_rules_default_action      = optional(string)
    network_rules_bypass              = optional(list(string))
    blob_delete_retention_days        = optional(number)
    container_delete_retention_days   = optional(number)
  })
  default     = null
  description = "Override baseline account settings when parameter_tier is custom. Fields omitted fall back to the bronze defaults."
}

variable "versioning_tier" {
  type        = string
  default     = "bronze"
  description = "Versioning tier applied to blob data. Valid options: bronze, silver, gold, custom."
  validation {
    condition = (
      contains(["bronze", "silver", "gold", "custom"], var.versioning_tier) &&
      (var.versioning_tier != "custom" || var.versioning_tier_custom != null)
    )
    error_message = "versioning_tier must be bronze, silver, gold, or custom. Provide versioning_tier_custom when using custom."
  }
}

variable "versioning_tier_custom" {
  type = object({
    versioning_enabled                            = optional(bool)
    rule_name                                     = optional(string)
    delete_after_days_since_creation              = optional(number)
    change_tier_to_cool_after_days_since_creation = optional(number)
    filters_blob_types                            = optional(list(string))
    filters_prefix_match                          = optional(list(string))
  })
  default     = null
  description = "Override versioning behaviour when versioning_tier is custom. Fields omitted fall back to the bronze defaults."
}

variable "lifecycle_tier" {
  type        = string
  default     = "bronze"
  description = "Lifecycle management tier applied to base blobs. Valid options: bronze, silver, custom."
  validation {
    condition = (
      contains(["bronze", "silver", "custom"], var.lifecycle_tier) &&
      (var.lifecycle_tier != "custom" || var.lifecycle_tier_custom != null)
    )
    error_message = "lifecycle_tier must be bronze, silver, or custom. Provide lifecycle_tier_custom when using custom."
  }
}

variable "lifecycle_tier_custom" {
  type = object({
    last_access_time_enabled                  = optional(bool)
    rule_name                                 = optional(string)
    auto_tier_to_hot_from_cool_enabled        = optional(bool)
    tier_to_cool_after_days_since_last_access = optional(number)
    delete_after_days_since_last_access       = optional(number)
    filters_blob_types                        = optional(list(string))
    filters_prefix_match                      = optional(list(string))
  })
  default     = null
  description = "Override lifecycle management behaviour when lifecycle_tier is custom. Fields omitted fall back to the bronze defaults."
}

#####################################################################
# Private Endpoint Configuration
#####################################################################

variable "enable_private_endpoint_blob" {
  type        = bool
  default     = true
  description = "Create a private endpoint for blob service."
}

variable "enable_private_endpoint_file" {
  type        = bool
  default     = false
  description = "Create a private endpoint for file service."
}

variable "enable_private_endpoint_queue" {
  type        = bool
  default     = false
  description = "Create a private endpoint for queue service."
}

variable "enable_private_endpoint_table" {
  type        = bool
  default     = false
  description = "Create a private endpoint for table service."
}

variable "enable_private_endpoint_dfs" {
  type        = bool
  default     = false
  description = "Create a private endpoint for dfs (Data Lake Gen2) service."
}

#####################################################################
# Alert Configuration
#####################################################################

variable "action_group_emails" {
  type        = list(string)
  default     = []
  description = "List of email addresses to create an action group for storage account alerts. If provided, an action group will be created automatically."
}

variable "alert_action_group_ids" {
  type        = list(string)
  default     = []
  description = "Optional: Existing Action Group IDs to notify for storage account alerts (availability, latency, capacity). If action_group_emails is provided, this will be ignored."
}

variable "enable_availability_alert" {
  type        = bool
  default     = false
  description = "Enable the availability metric alert."
}

variable "availability_alert_severity" {
  type        = number
  default     = 1
  description = "Availability alert severity (0-4). Matches az_storage_account_v2 default of 1."
}

variable "availability_alert_threshold" {
  type        = number
  default     = 100
  description = "Availability alert threshold percentage. Matches az_storage_account_v2 default of 100."
}

variable "enable_success_server_latency_alert" {
  type        = bool
  default     = false
  description = "Enable the success server latency metric alert."
}

variable "success_server_latency_alert_severity" {
  type        = number
  default     = 2
  description = "Success server latency alert severity (0-4). Matches az_storage_account_v2 default of 2."
}

variable "success_server_latency_alert_threshold" {
  type        = number
  default     = 1000
  description = "Success server latency alert threshold in milliseconds. Matches az_storage_account_v2 default of 1000."
}

variable "enable_used_capacity_alert" {
  type        = bool
  default     = false
  description = "Enable the used capacity metric alert."
}

variable "used_capacity_alert_severity" {
  type        = number
  default     = 3
  description = "Used capacity alert severity (0-4). Matches az_storage_account_v2 default of 3."
}

variable "used_capacity_alert_threshold" {
  type        = number
  default     = 5e+14
  description = "Used capacity alert threshold in bytes. Matches az_storage_account_v2 default of 5e+14."
}

#####################################################################
# Identity Configuration
#####################################################################

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = {
    type = "SystemAssigned"
  }
  description = "Managed identity configuration. Possible types: SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "Possible values are SystemAssigned, UserAssigned, and SystemAssigned, UserAssigned."
  }
}

#####################################################################
# RBAC Configuration - Write Access Profile
#####################################################################

variable "write_access_principals" {
  type = list(object({
    name = string
    type = string
  }))
  default     = []
  description = <<DESCRIPTION
List of principal objects to receive write access roles (Storage Blob/File/Table/Queue Data Contributor, Reader).
Each principal object should have:
- `name` (string): Display name for Users/Groups/ServicePrincipals, or resource ID for Managed Identities
- `type` (string): Principal type - "User", "Group", "ServicePrincipal", or "ManagedIdentity"
DESCRIPTION
}

#####################################################################
# RBAC Configuration - Read Access Profile
#####################################################################

variable "read_access_principals" {
  type = list(object({
    name = string
    type = string
  }))
  default     = []
  description = <<DESCRIPTION
List of principal objects to receive read access roles (Storage Blob/File/Table/Queue Data Reader, Reader).
Each principal object should have:
- `name` (string): Display name for Users/Groups/ServicePrincipals, or resource ID for Managed Identities
- `type` (string): Principal type - "User", "Group", "ServicePrincipal", or "ManagedIdentity"
DESCRIPTION
}

#####################################################################
# RBAC Configuration - Alert Access Profile
#####################################################################

variable "alert_access_principals" {
  type = list(object({
    name = string
    type = string
  }))
  default     = []
  description = <<DESCRIPTION
List of principal objects to receive alert access roles (e.g., BDSO Alert Operator).
Each principal object should have:
- `name` (string): Display name for Users/Groups/ServicePrincipals, or resource ID for Managed Identities
- `type` (string): Principal type - "User", "Group", "ServicePrincipal", or "ManagedIdentity"
DESCRIPTION
}

#####################################################################
# Custom tags variables
#####################################################################

variable "costCenter" {
  type        = string
  description = "Cost center associated with the resource."
}

variable "businessUnit" {
  type        = string
  description = "Business unit associated with the resource."
}

variable "applicationName" {
  type        = string
  description = "Application name associated with the resource."
}

variable "applicationCode" {
  type        = string
  description = "Application code associated with the resource."
}

