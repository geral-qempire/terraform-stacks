variable "roles" {
  description = "List of role definition names to assign (e.g., 'Storage Blob Data Contributor')"
  type        = list(string)
}

variable "principals" {
  description = <<DESCRIPTION
List of principal objects with name and type. Each principal object should have:
- `name` (string): Display name for Users/Groups/ServicePrincipals, or resource ID for Managed Identities
- `type` (string): Principal type - "User", "Group", "ServicePrincipal", or "ManagedIdentity"
DESCRIPTION
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "scope" {
  description = "The Azure resource ID where roles will be assigned"
  type        = string
  default     = null
  nullable    = true
}

variable "scopes" {
  description = "List of Azure resource IDs where roles will be assigned"
  type        = list(string)
  default     = []
}

variable "skip_service_principal_aad_check" {
  description = "If set to true, skips the Azure Active Directory check for the service principal in the tenant"
  type        = bool
  default     = true
}

