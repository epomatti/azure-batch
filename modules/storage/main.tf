# Required due to limitations of the provider for System-Assigned identities
resource "azurerm_user_assigned_identity" "storage" {
  name                = "storages-identity"
  location            = var.location
  resource_group_name = var.group
}

resource "azurerm_role_assignment" "keyvault_crypto_officer" {
  scope                = var.keyvault_id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = azurerm_user_assigned_identity.storage.principal_id
}

### Storage ###

# Batch Auto-storage
resource "azurerm_storage_account" "autostorage" {
  name                     = "st${var.sys}autostg"
  resource_group_name      = var.group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.storage.id
    ]
  }

  customer_managed_key {
    key_vault_key_id          = var.keyvault_autostorage_key_id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
  }

  depends_on = [azurerm_role_assignment.keyvault_crypto_officer]
}

# Batch Pool Storage Account
resource "azurerm_storage_account" "jobfiles" {
  name                     = "st${var.sys}jobstg"
  resource_group_name      = var.group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.storage.id
    ]
  }

  customer_managed_key {
    key_vault_key_id          = var.keyvault_jobfiles_key_id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
  }

  depends_on = [azurerm_role_assignment.keyvault_crypto_officer]
}

# Blob
resource "azurerm_storage_container" "jobfiles" {
  name                  = "jobfiles"
  storage_account_name  = azurerm_storage_account.jobfiles.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "molecules_zip" {
  name                   = "molecules.zip"
  storage_account_name   = azurerm_storage_account.jobfiles.name
  storage_container_name = azurerm_storage_container.jobfiles.name
  type                   = "Block"
  source                 = "${path.module}/../../artifacts/molecules.zip"
}

resource "azurerm_storage_container" "blobs" {
  name                  = "blobs"
  storage_account_name  = azurerm_storage_account.jobfiles.name
  container_access_type = "private"
}

resource "azurerm_storage_share" "share" {
  name                 = "share"
  storage_account_name = azurerm_storage_account.jobfiles.name
  quota                = 50
}
