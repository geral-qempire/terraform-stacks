output "role_assignment_ids" {
  description = "Map of role assignment resource IDs keyed by the assignment key"
  value       = module.rbac_assignments.role_assignment_ids
}


