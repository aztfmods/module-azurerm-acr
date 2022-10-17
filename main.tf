#----------------------------------------------------------------------------------------
# Resourcegroups
#----------------------------------------------------------------------------------------

data "azurerm_resource_group" "rg" {
  for_each = var.registry

  name = each.value.resourcegroup
}

#----------------------------------------------------------------------------------------
# Generate random id
#----------------------------------------------------------------------------------------

resource "random_string" "random" {
  for_each = var.registry

  length    = 3
  min_lower = 3
  special   = false
  numeric   = false
  upper     = false
}

#----------------------------------------------------------------------------------------
# Container registry
#----------------------------------------------------------------------------------------

resource "azurerm_container_registry" "acr" {
  for_each = var.registry

  name                = "acr${var.naming.company}${each.key}${var.naming.env}${var.naming.region}${random_string.random[each.key].result}"
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  location            = data.azurerm_resource_group.rg[each.key].location
  sku                 = each.value.sku
  admin_enabled       = try(each.value.enable.admin, false)

  dynamic "trust_policy" {
    for_each = {
      for k, v in var.registry : k => v
      if try(v.enable.trust_policy, false) == true && v.sku == "Premium"
    }

    content {
      enabled = each.value.enable.trust_policy
    }
  }

  dynamic "retention_policy" {
    for_each = {
      for k, v in var.registry : k => v
      if try(v.enable.retention_policy, false) == true && v.sku == "Premium"
    }

    content {
      enabled = each.value.enable.retention_policy
      days    = try(each.value.retention_in_days, null)
    }
  }

  dynamic "georeplications" {
    for_each = {
      for k, v in try(each.value.replications, {}) : k => v
      if each.value.sku == "Premium"
    }

    content {
      location                  = georeplications.value.location
      zone_redundancy_enabled   = try(georeplications.value.enable_zone_redundancy, null)
      regional_endpoint_enabled = try(georeplications.value.regional_endpoint_enabled, null)
    }
  }
}