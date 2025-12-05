output "storage_account_id" {
  description = "Resource ID of the deployed storage account."
  value       = module.storage_account.storage_account_id
}

output "storage_account_name" {
  description = "Name of the deployed storage account."
  value       = module.storage_account.storage_account_name
}

output "storage_account_primary_endpoints" {
  description = "Primary service endpoints for the storage account."
  value = {
    blob  = module.storage_account.storage_account_primary_blob_endpoint
    file  = module.storage_account.storage_account_primary_file_endpoint
    queue = module.storage_account.storage_account_primary_queue_endpoint
    table = module.storage_account.storage_account_primary_table_endpoint
  }
}

output "generated_name_seed" {
  description = "Base name returned by the az_name_generator module."
  value       = module.storage_account_name.name
}

output "private_endpoint_ids" {
  description = "Map of private endpoint IDs keyed by storage subresource."
  value = {
    for key, mod in module.private_endpoints :
    key => {
      private_endpoint_id  = mod.private_endpoint_id
      network_interface_id = mod.network_interface_id
    }
  }
}

output "rbac_write_assignment_ids" {
  description = "Role assignment IDs for the write profile."
  value       = try(module.rbac_write_profile[0].role_assignment_ids, {})
}

output "rbac_read_assignment_ids" {
  description = "Role assignment IDs for the read profile."
  value       = try(module.rbac_read_profile[0].role_assignment_ids, {})
}

output "rbac_alert_assignment_ids" {
  description = "Role assignment IDs for the alert access profile."
  value       = try(module.rbac_alert_profile[0].role_assignment_ids, {})
}

output "golden_signal_alerts" {
  description = "Map of golden signal alerts keyed by slug with IDs and applied settings."
  value       = local.golden_signal_alert_outputs
}

output "golden_signal_action_group_id" {
  description = "ID of the managed golden signal action group when created."
  value       = local.golden_signal_primary_action_group_id
}

output "golden_signal_action_group_ids" {
  description = "List of action group IDs attached to the golden signal alerts (managed + user supplied)."
  value       = local.golden_signal_action_group_ids
}



