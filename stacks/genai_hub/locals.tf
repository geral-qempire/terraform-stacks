########################################
# Location short codes (CAF)
########################################

locals {
  location_short_map = {
    "eastus"             = "eus"
    "eastus2"            = "eus2"
    "westus"             = "wus"
    "westus2"            = "wus2"
    "westus3"            = "wus3"
    "centralus"          = "cus"
    "southcentralus"     = "scus"
    "westeurope"         = "weu"
    "northeurope"        = "neu"
    "swedencentral"      = "swc"
    "uksouth"            = "uks"
    "ukwest"             = "ukw"
    "francecentral"      = "frc"
    "germanywestcentral" = "gwc"
    "italynorth"         = "itn"
    "japaneast"          = "jpe"
    "australiaeast"      = "aue"
    "canadacentral"      = "cac"
    "brazilsouth"        = "brs"
    "southafricanorth"   = "san"
    "uaenorth"           = "uan"
    "southindia"         = "si"
    "canadaeast"         = "cae"
    "spaincentral"       = "spc"
  }
  location_short = lookup(local.location_short_map, var.location, substr(var.location, 0, 4))
}

########################################
# Naming convention (CAF-aligned)
########################################

locals {
  name_suffix = "${var.project_name}-${var.environment}-${local.location_short}"

  resource_names = {
    resource_group = "rg-${local.name_suffix}"
    ai_hub         = "mlw-hub-${local.name_suffix}"
    storage          = "sthub${replace(local.name_suffix, "-", "")}"
    storage_datalake = "stdlhub${replace(local.name_suffix, "-", "")}"
    key_vault        = "kv-hub-${local.name_suffix}"
    ai_search      = "srch-hub-${local.name_suffix}"
    sql_server     = "sql-hub-${local.name_suffix}"
    sql_database   = "sqldb-hub-${local.name_suffix}"
    app_insights   = "appi-${local.name_suffix}"
    log_analytics  = "log-${local.name_suffix}"
    ai_services    = var.ai_services_name != "" ? var.ai_services_name : "cog-${local.name_suffix}"
  }
}

########################################
# Tier presets
########################################

locals {
  tier_config = {
    poc_dev = {
      storage_replication_type     = "LRS"
      keyvault_sku                 = "standard"
      keyvault_purge_protection    = false
      ai_search_sku                = "basic"
      ai_search_replica_count      = 1
      ai_search_partition_count    = 1
      sql_sku_name                 = "Basic"
      sql_max_size_gb              = 2
      log_analytics_retention_days = 30
    }
    prod = {
      storage_replication_type     = "ZRS"
      keyvault_sku                 = "standard"
      keyvault_purge_protection    = true
      ai_search_sku                = "standard"
      ai_search_replica_count      = 2
      ai_search_partition_count    = 1
      sql_sku_name                 = "S1"
      sql_max_size_gb              = 50
      log_analytics_retention_days = 90
    }
    prod_critical = {
      storage_replication_type     = "GZRS"
      keyvault_sku                 = "premium"
      keyvault_purge_protection    = true
      ai_search_sku                = "standard"
      ai_search_replica_count      = 3
      ai_search_partition_count    = 2
      sql_sku_name                 = "P1"
      sql_max_size_gb              = 250
      log_analytics_retention_days = 180
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
      public_network_access            = true
      public_network_access_string     = "Enabled"
      managed_network_isolation_mode   = "Disabled"
      enable_outbound_rules            = false
    }
    inbound_safe = {
      public_network_access            = false
      public_network_access_string     = "Disabled"
      managed_network_isolation_mode   = "AllowInternetOutbound"
      enable_outbound_rules            = false
    }
    inbound_outbound_safe = {
      public_network_access            = false
      public_network_access_string     = "Disabled"
      managed_network_isolation_mode   = "AllowOnlyApprovedOutbound"
      enable_outbound_rules            = true
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
