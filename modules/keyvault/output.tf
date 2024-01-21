output "id" {
  value = azurerm_key_vault.default.id
}

output "batch_cmk_versionless_id" {
  value = azurerm_key_vault_key.batch.versionless_id
}
