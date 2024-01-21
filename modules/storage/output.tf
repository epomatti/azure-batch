output "autostorage_id" {
  value = azurerm_storage_account.autostorage.id
}

output "jobfiles_storage_id" {
  value = azurerm_storage_account.jobfiles.id
}

output "jobfiles_storage_name" {
  value = azurerm_storage_account.jobfiles.name
}

output "account_key" {
  value     = azurerm_storage_account.jobfiles.primary_access_key
  sensitive = true
}
