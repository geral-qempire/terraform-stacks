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
# Hub reference
########################################

variable "hub_workspace_id" {
  description = "Resource ID of the parent AI Hub workspace."
  type        = string
}

########################################
# Tier
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

########################################
# Network security
########################################

variable "network_security" {
  description = "Network security posture. Must match the hub's setting to correctly create PE outbound rules."
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

variable "enable_storage" {
  description = "Deploy a storage account for this project."
  type        = bool
  default     = false
}

variable "enable_storage_datalake" {
  description = "Deploy an HNS-enabled (Data Lake Gen2) storage account for Fabric integration."
  type        = bool
  default     = false
}

variable "enable_keyvault" {
  description = "Deploy a key vault for this project."
  type        = bool
  default     = false
}

variable "enable_ai_search" {
  description = "Deploy an AI Search (vector store) service for this project."
  type        = bool
  default     = false
}

variable "enable_sql_database" {
  description = "Deploy a SQL database for this project."
  type        = bool
  default     = false
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
# RBAC profiles
########################################

variable "reader_group_ids" {
  description = "List of Azure AD group object IDs to grant Reader access across all project resources."
  type        = list(string)
  default     = []
}

variable "contributor_group_ids" {
  description = "List of Azure AD group object IDs to grant Contributor access across all project resources."
  type        = list(string)
  default     = []
}

########################################
# Tagging
########################################

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
