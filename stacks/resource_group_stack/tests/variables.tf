variable "project_name" {
  type        = string
  description = "Project identifier consumed by the az_name_generator module."
}

variable "environment" {
  type        = string
  description = "Environment short name (dev, qua, prd, ...)."
}

variable "location" {
  type        = string
  default     = "North Europe"
  description = "Azure region where the resource group will be created."
}

variable "name_random_postfix" {
  type        = bool
  default     = false
  description = "Toggle to append a random postfix to the generated resource group name."
}

variable "infra_subscription_id" {
  type        = string
  description = "Subscription ID that will host the resource group."
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
  description = "Optional extra tags merged into the base tag set."
}

variable "write_access_principals" {
  description = "Principals that should receive Contributor over the resource group."
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "read_access_principals" {
  description = "Principals that should receive Reader over the resource group."
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "alert_access_principals" {
  description = "Principals that should receive the BDSO Alert Operator role over the resource group."
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

