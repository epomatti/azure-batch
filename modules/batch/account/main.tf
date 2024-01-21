# INFO: Using this because the Batch resources does not support CMK permissions directly with System-Assigned identity
resource "azurerm_user_assigned_identity" "main" {
  name                = "batch-account-user"
  location            = var.location
  resource_group_name = var.group
}

resource "azurerm_role_assignment" "keyvault_crypto_officer" {
  scope                = var.keyvault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_batch_account" "main" {
  name                          = "ba${var.sys}"
  resource_group_name           = var.group
  location                      = var.location
  public_network_access_enabled = var.batch_account_public

  storage_account_id                  = var.autostorage_id
  storage_account_authentication_mode = "BatchAccountManagedIdentity"

  # Azure-managed compute
  pool_allocation_mode = "BatchService"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.main.id
    ]
  }

  encryption {
    key_vault_key_id = var.cmk_versionless_id
  }

  # Allow or block public IPs
  network_profile {
    account_access {
      default_action = var.network_account_access
    }
    node_management_access {
      default_action = var.network_node_management_access
    }
  }

  depends_on = [azurerm_role_assignment.keyvault_crypto_officer]
}

resource "azurerm_role_assignment" "batch" {
  scope                = var.autostorage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
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
