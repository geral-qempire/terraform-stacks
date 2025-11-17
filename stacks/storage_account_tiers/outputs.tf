########################################
# Action Group Outputs
########################################

output "action_group_id" {
  value       = length(local.action_group_receivers) > 0 ? module.action_group[0].action_group_id : null
  description = "The ID of the created Action Group (if action_group_emails was provided)."
}

output "action_group_name" {
  value       = length(local.action_group_receivers) > 0 ? module.action_group[0].action_group_name : null
  description = "The Name of the created Action Group (if action_group_emails was provided)."
}

########################################
# Storage Account Outputs
########################################

output "storage_account_id" {
  value       = module.storage_account.storage_account_id
  description = "The ID of the Storage Account."
}

output "storage_account_name" {
  value       = module.storage_account.storage_account_name
  description = "The Name of the Storage Account."
}

output "storage_account_primary_blob_endpoint" {
  value       = module.storage_account.storage_account_primary_blob_endpoint
  description = "Primary Blob service endpoint for the Storage Account."
}

output "private_endpoint_blob_id" {
  value       = module.storage_account.private_endpoint_blob_id
  description = "The ID of the Blob private endpoint."
}

output "private_endpoint_file_id" {
  value       = module.storage_account.private_endpoint_file_id
  description = "The ID of the File private endpoint."
}

########################################
# Alert Outputs
########################################

output "availability_alert_id" {
  value       = module.storage_account.availability_alert_id
  description = "Resource ID of the availability metric alert (null if disabled)."
}

output "success_server_latency_alert_id" {
  value       = module.storage_account.success_server_latency_alert_id
  description = "Resource ID of the success server latency metric alert (null if disabled)."
}

output "used_capacity_alert_id" {
  value       = module.storage_account.used_capacity_alert_id
  description = "Resource ID of the used capacity metric alert (null if disabled)."
}

output "parameter_tier" {
  value       = var.parameter_tier
  description = "The parameter tier applied to this storage account."
}

output "parameter_tier_config" {
  value       = local.selected_parameter_tier
  description = "Resolved parameter tier configuration."
}

output "versioning_tier" {
  value       = var.versioning_tier
  description = "The versioning tier applied to this storage account."
}

output "versioning_tier_config" {
  value       = local.selected_versioning_tier
  description = "Resolved versioning tier configuration."
}

output "lifecycle_tier" {
  value       = var.lifecycle_tier
  description = "The lifecycle tier applied to this storage account."
}

output "lifecycle_tier_config" {
  value       = local.selected_lifecycle_tier
  description = "Resolved lifecycle tier configuration."
}
