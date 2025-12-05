variable "project_name" {
  type        = string
  description = "Project name fed into the name generator."
}

variable "org_code" {
  type        = string
  default     = "bdso"
  description = "Optional organization code appended to generated resource names."
}

variable "environment" {
  type        = string
  description = "Environment short name (dev, qua, prd, ...)."
}

variable "location" {
  type        = string
  default     = "North Europe"
  description = "Azure region for all resources."
}

variable "resource_group_name" {
  type        = string
  description = "Existing resource group that hosts the storage account."
}

variable "infra_subscription_id" {
  type        = string
  description = "Subscription ID that hosts the storage account."
}

variable "dns_subscription_id" {
  type        = string
  default     = null
  description = "Subscription ID that hosts the private DNS zones. Falls back to infra subscription if null."
}

variable "name_random_postfix" {
  type        = bool
  default     = false
  description = "Sets whether generated names include a random numeric postfix."
}

variable "cost_center" {
  type        = string
  description = "Cost center tag."
}

variable "business_unit" {
  type        = string
  description = "Business unit tag."
}

variable "application_name" {
  type        = string
  description = "Application name tag."
}

variable "application_code" {
  type        = string
  description = "Application code tag."
}

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = "Optional extra tags merged into the default tag set."
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = {
    type = "SystemAssigned"
  }
  description = "Managed identity configuration passed directly to az_storage_account."
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "Identity type must be SystemAssigned, UserAssigned or SystemAssigned, UserAssigned."
  }
}

############################################################
# Storage account tiers
############################################################

variable "storage_tier" {
  type        = string
  description = "Applies predefined storage posture for replication + retention (bronze, silver, gold, plat, diamond, override)."
  validation {
    condition = contains(["bronze", "silver", "gold", "plat", "diamond", "override"], var.storage_tier)
    error_message = "storage_tier must be one of bronze, silver, gold, plat, diamond, override."
  }
}

variable "storage_tier_override" {
  type = object({
    account_tier                      = optional(string)
    account_kind                      = optional(string)
    access_tier                       = optional(string)
    account_replication_type          = optional(string)
    blob_delete_retention_days        = optional(number)
    container_delete_retention_days   = optional(number)
    enable_geo_priority_replication   = optional(bool)
    min_tls_version                   = optional(string)
    shared_access_key_enabled         = optional(bool)
    infrastructure_encryption_enabled = optional(bool)
    network_rules_bypass              = optional(list(string))
  })
  default     = null
  description = "Customizes the storage tier baseline when storage_tier equals override."
  validation {
    condition     = var.storage_tier != "override" || var.storage_tier_override != null
    error_message = "Provide storage_tier_override when storage_tier is set to override."
  }
}

############################################################
# Smart life cycle
############################################################

variable "smart_lifecycle_tier" {
  type        = string
  description = "Lifecycle automation tier (off, on, override)."
  validation {
    condition     = contains(["true", "false", "override"], var.smart_lifecycle_tier)
    error_message = "smart_lifecycle_tier must be off, on or override."
  }
}

variable "smart_lifecycle_override" {
  type = object({
    hot_to_cool_days    = number
    cool_to_cold_days   = number
    cold_to_archive_days = optional(number)
    delete_after_days   = optional(number)
  })
  default     = null
  description = "Custom lifecycle movement schedule used when smart_lifecycle_tier is override. Optional fields allow archive tiering and deletion."
  validation {
    condition     = var.smart_lifecycle_tier != "override" || var.smart_lifecycle_override != null
    error_message = "Provide smart_lifecycle_override when smart_lifecycle_tier is set to override."
  }
}

variable "lifecycle_prefix_match" {
  type        = list(string)
  default     = []
  description = "Optional list of prefixes to scope lifecycle policies to specific containers/folders."
}

############################################################
# Versioning tiers
############################################################

variable "versioning_tier" {
  type        = string
  description = "Applies predefined versioning retention policy (bronze, silver, gold, platinum, diamond, override)."
  validation {
    condition = contains(["bronze", "silver", "gold", "platinum", "diamond", "override"], var.versioning_tier)
    error_message = "versioning_tier must be one of bronze, silver, gold, platinum, diamond, override."
  }
}

variable "versioning_tier_override" {
  type = object({
    versioning_enabled                            = optional(bool)
    delete_after_days_since_creation              = optional(number)
    change_tier_to_cool_after_days_since_creation = optional(number)
    rule_name                                     = optional(string)
    filters_blob_types                            = optional(list(string))
    filters_prefix_match                          = optional(list(string))
  })
  default     = null
  description = "Customizes the versioning tier baseline when versioning_tier equals override."
  validation {
    condition     = var.versioning_tier != "override" || var.versioning_tier_override != null
    error_message = "Provide versioning_tier_override when versioning_tier is set to override."
  }
}

############################################################
# Networking
############################################################

variable "allowed_ip_addresses" {
  type        = list(string)
  default     = []
  description = "Public IPv4 addresses allowed through the firewall. Empty list disables public network access entirely."
}

variable "network_rules_bypass" {
  type        = list(string)
  default     = ["AzureServices"]
  description = "Services that bypass the network rules."
}

variable "enable_private_endpoint_blob" {
  type        = bool
  description = "Create a private endpoint for the Blob subresource."
}

variable "enable_private_endpoint_file" {
  type        = bool
  description = "Create a private endpoint for the File subresource."
}

variable "enable_private_endpoint_queue" {
  type        = bool
  description = "Create a private endpoint for the Queue subresource."
}

variable "enable_private_endpoint_table" {
  type        = bool
  description = "Create a private endpoint for the Table subresource."
}

variable "private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID used by every private endpoint. Optional when subnet details are provided."
  validation {
    condition = var.private_endpoint_subnet_id != null || (var.private_endpoint_subnet_name != null && var.private_endpoint_virtual_network_name != null)
    error_message = "Provide private_endpoint_subnet_id or both private_endpoint_subnet_name and private_endpoint_virtual_network_name."
  }
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Subnet name used to resolve the private endpoint subnet when subnet_id is null."
}

variable "private_endpoint_virtual_network_name" {
  type        = string
  description = "Virtual network name that hosts the private endpoint subnet (required when using name-based lookup)."
}

variable "private_endpoint_virtual_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network (defaults to resource_group_name when unset)."
}

variable "private_endpoint_location" {
  type        = string
  default     = null
  description = "Optional location override for private endpoints. Defaults to storage account location when null."
}

variable "dns_resource_group_name" {
  type        = string
  description = "Resource group that contains the Azure Private DNS zones."
}

variable "private_dns_zone_overrides" {
  type        = map(list(string))
  default     = {}
  description = "Optional override per service (blob/file/queue/table) for private DNS zone names."
}

############################################################
# RBAC profiles
############################################################

variable "write_access_principals" {
  description = "List of principal descriptors that should receive the write profile."
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "read_access_principals" {
  description = "List of principal descriptors that should receive the read profile."
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "alert_access_principals" {
  description = "List of principal descriptors that should receive alert access (BDSO Alert Operator) over the deployed monitor alerts."
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

############################################################
# Golden signal alerting
############################################################

variable "golden_signal_alert_emails" {
  description = "Map of action group receivers (key = alias, value = email). When non-empty we create a dedicated action group."
  type        = map(string)
  default     = {}
}

variable "golden_signal_action_group_ids" {
  description = "Optional extra action group IDs that should be invoked by every golden signal alert."
  type        = list(string)
  default     = []
}

variable "enable_base_alerts" {
  description = "Toggle core storage account level alerts (availability, capacity, ingress/egress)."
  type        = bool
  default     = false
}

variable "enable_blob_alerts" {
  description = "Toggle blob service specific alerts (capacity, latency)."
  type        = bool
  default     = false
}

variable "enable_file_alerts" {
  description = "Toggle file service specific alerts (availability, throttling, capacity, governance)."
  type        = bool
  default     = false
}

variable "enable_queue_alerts" {
  description = "Toggle queue service specific alerts (capacity, backlog, governance)."
  type        = bool
  default     = false
}

variable "golden_signal_alert_overrides" {
  description = "Per alert override map keyed by the alert slug (e.g., account_availability) allowing enabled/severity/threshold customization. Setting an override entry will force the alert to be deployed even if its surface toggle is off."
  type = map(object({
    enabled   = optional(bool)
    severity  = optional(number)
    threshold = optional(number)
  }))
  default = {}
}


