output "acr" {
  value = azurerm_container_registry.acr
}

output "merged_ids" {
  value = values(azurerm_container_registry.acr)[*].id
}

output "mi" {
  value = azurerm_user_assigned_identity.mi
}