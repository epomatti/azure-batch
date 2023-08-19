resource "azurerm_batch_account" "main" {
  name                          = "ba${var.sys}"
  resource_group_name           = var.group
  location                      = var.location
  public_network_access_enabled = var.batch_account_public

  storage_account_id                  = var.autostorage_id
  storage_account_authentication_mode = "BatchAccountManagedIdentity"

  # Provisioning happens behind the scenes
  pool_allocation_mode = "BatchService"

  identity {
    type = "SystemAssigned"
  }

  # network_profile {}

  # To make life easier during tests
  # lifecycle {
  #   ignore_changes = [
  #     public_network_access_enabled
  #   ]
  # }
}

resource "azurerm_role_assignment" "batch" {
  scope                = var.autostorage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_batch_account.main.identity[0].principal_id
}

resource "azurerm_batch_application" "main" {
  name                = "molecular-analysis"
  display_name        = "Molecular Analysis"
  resource_group_name = var.group
  account_name        = azurerm_batch_account.main.name
  allow_updates       = true

  lifecycle {
    ignore_changes = [
      default_version
    ]
  }

  depends_on = [
    azurerm_role_assignment.batch
  ]
}
