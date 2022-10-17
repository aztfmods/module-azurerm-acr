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
  admin_enabled       = true

  dynamic "trust_policy" {
    for_each = {
      for k, v in var.registry : k => v
      if try(v.enable.trust_policy, false) == true && v.sku == "Premium"
    }

    content {
      enabled = each.value.enable.trust_policy
    }
  }
}