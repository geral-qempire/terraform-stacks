########################################
# Core context
########################################

variable "project_name" {
  description = "Short project identifier used in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,12}$", var.project_name))
    error_message = "project_name must be 2-12 characters, lowercase alphanumeric only."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "qa", "staging", "prod"], var.environment)
    error_message = "Must be one of: dev, qa, staging, prod."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
}

########################################
# Tier and network security
########################################

variable "tier" {
  description = "Infrastructure tier controlling SKU sizes, redundancy and SLA."
  type        = string
  default     = "poc_dev"

  validation {
    condition     = contains(["poc_dev", "prod", "prod_critical"], var.tier)
    error_message = "Must be one of: poc_dev, prod, prod_critical."
  }
}

variable "network_security" {
  description = "Network security posture for the hub."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "inbound_safe", "inbound_outbound_safe"], var.network_security)
    error_message = "Must be one of: public, inbound_safe, inbound_outbound_safe."
  }
}

########################################
# Optional resource toggles
########################################

variable "enable_storage_datalake" {
  description = "Deploy an HNS-enabled (Data Lake Gen2) storage account for Fabric integration."
  type        = bool
  default     = false
}

variable "enable_ai_search" {
  description = "Deploy an AI Search (vector store) service in the hub resource group."
  type        = bool
  default     = false
}

variable "enable_sql_database" {
  description = "Deploy a SQL database in the hub resource group."
  type        = bool
  default     = false
}

########################################
# Outbound rules (inbound_outbound_safe only)
########################################

variable "outbound_fqdn_rules" {
  description = "Custom FQDN destinations to allow through the managed network firewall. Only used when network_security = inbound_outbound_safe."
  type        = list(string)
  default     = []
}

########################################
# SQL configuration
########################################

variable "sql_azuread_administrator" {
  description = "Azure AD administrator for the SQL server. Required when enable_sql_database = true."
  type = object({
    login_username              = string
    object_id                   = string
    azuread_authentication_only = optional(bool, true)
  })
  default = null
}

########################################
# AI Services
########################################

variable "ai_services_name" {
  description = "Name override for the AI Services (Cognitive Services) account. If empty, auto-generated."
  type        = string
  default     = ""
}

########################################
# Tagging
########################################

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
