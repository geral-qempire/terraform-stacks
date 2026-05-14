########################################
# Tier presets
########################################

locals {
  tier_config = {
    poc_dev = {
      storage_replication_type  = "LRS"
      keyvault_sku              = "standard"
      keyvault_purge_protection = false
      ai_search_sku             = "basic"
      ai_search_replica_count   = 1
      ai_search_partition_count = 1
      sql_sku_name              = "Basic"
      sql_max_size_gb           = 2
    }
    prod = {
      storage_replication_type  = "ZRS"
      keyvault_sku              = "standard"
      keyvault_purge_protection = true
      ai_search_sku             = "standard"
      ai_search_replica_count   = 2
      ai_search_partition_count = 1
      sql_sku_name              = "S1"
      sql_max_size_gb           = 50
    }
    prod_critical = {
      storage_replication_type  = "GZRS"
      keyvault_sku              = "premium"
      keyvault_purge_protection = true
      ai_search_sku             = "standard"
      ai_search_replica_count   = 3
      ai_search_partition_count = 2
      sql_sku_name              = "P1"
      sql_max_size_gb           = 250
    }
  }
  tier = local.tier_config[var.tier]
}

########################################
# Network security presets
########################################

locals {
  network_config = {
    public = {
      enable_outbound_rules    = false
      enable_private_endpoints = false
    }
    inbound_safe = {
      enable_outbound_rules    = false
      enable_private_endpoints = true
    }
    inbound_outbound_safe = {
      enable_outbound_rules    = true
      enable_private_endpoints = true
    }
  }
  network = local.network_config[var.network_security]
}

########################################
# Common tags
########################################

locals {
  common_tags = merge({
    environment = var.environment
    project     = var.project_name
    tier        = var.tier
    managed_by  = "terraform"
  }, var.tags)
}
