output "acr" {
  value = azurerm_container_registry.acr
}

output "merged_ids" {
  value = values(azurerm_container_registry.acr)[*].id
}