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
    resource_group = "rg-proj-${local.name_suffix}"
    ai_project     = "mlw-proj-${local.name_suffix}"
    storage          = "stproj${replace(local.name_suffix, "-", "")}"
    storage_datalake = "stdlproj${replace(local.name_suffix, "-", "")}"
    key_vault        = "kv-proj-${local.name_suffix}"
    ai_search      = "srch-proj-${local.name_suffix}"
    sql_server     = "sql-proj-${local.name_suffix}"
    sql_database   = "sqldb-proj-${local.name_suffix}"
  }
}

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
