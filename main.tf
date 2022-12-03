data "azurerm_client_config" "current" {}

#----------------------------------------------------------------------------------------
# resourcegroups
#----------------------------------------------------------------------------------------

data "azurerm_resource_group" "rg" {
  for_each = var.registry

  name = each.value.resourcegroup
}

#----------------------------------------------------------------------------------------
# generate random id
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
# user managed identity
#----------------------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "mi" {
  for_each = {
    for k, v in var.registry : k => v
    if try(v.identity.type, {}) == "UserAssigned"
  }

  name                = "id-${var.naming.company}-${each.key}-${var.naming.env}-${var.naming.region}"
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  location            = data.azurerm_resource_group.rg[each.key].location
}

#----------------------------------------------------------------------------------------
# role assignment
#----------------------------------------------------------------------------------------

resource "azurerm_role_assignment" "rol" {
  # for_each = var.registry
  for_each = {
    for k, v in var.registry : k => v
    if try(v.identity.type, {}) == "UserAssigned"
  }

  scope                = each.value.role_assignment.scope
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_user_assigned_identity.mi[each.key].principal_id
}

#----------------------------------------------------------------------------------------
# container registries
#----------------------------------------------------------------------------------------

resource "azurerm_container_registry" "acr" {
  for_each = var.registry

  name                = "acr${var.naming.company}${each.key}${var.naming.env}${var.naming.region}${random_string.random[each.key].result}"
  resource_group_name = data.azurerm_resource_group.rg[each.key].name
  location            = data.azurerm_resource_group.rg[each.key].location
  sku                 = each.value.sku

  anonymous_pull_enabled = (
    each.value.sku == "Standard" ||
    each.value.sku == "Premium" ?
    try(each.value.enable.anonymous_pull, false)
    : false
  )

  data_endpoint_enabled = (
    each.value.sku == "Premium" ?
    try(each.value.enable.data_endpoint, false)
    : false
  )

  export_policy_enabled = (
    each.value.sku == "Premium" &&
    try(each.value.enable.public_network_access, true) == false ?
    try(each.value.enable.export_policy, true)
    : true
  )

  public_network_access_enabled = (
    try(each.value.enable.export_policy, true) == false ?
    try(each.value.enable.public_network_access, true)
    : true
  )

  admin_enabled              = try(each.value.enable.admin, false)
  quarantine_policy_enabled  = try(each.value.enable.quarantine_policy, false)
  network_rule_bypass_option = try(each.value.network_rule_bypass, "AzureServices")

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

  dynamic "identity" {
    for_each = {
      for k, v in try(each.value.identity, {}) : k => v
    }

    content {
      type         = each.value.identity.type
      identity_ids = each.value.identity.type == "UserAssigned" ? [azurerm_user_assigned_identity.mi[each.key].id] : []
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

  dynamic "encryption" {
    for_each = {
      for k, v in try(each.value.encryption, {}) : k => v
    }

    content {
      enabled            = try(encryption.value.enable, true)
      key_vault_key_id   = encryption.value
      identity_client_id = azurerm_user_assigned_identity.mi[each.key].client_id
    }
  }

  depends_on = [
    azurerm_role_assignment.rol
  ]
}