### Storage ###

# This will be used as auto-storage
resource "azurerm_storage_account" "autostorage" {
  name                     = "st${var.sys}789"
  resource_group_name      = var.group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# This will be a resource file from the blob
resource "azurerm_storage_account" "jobfiles" {
  name                     = "st${var.sys}res111"
  resource_group_name      = var.group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

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
  source                 = "molecules.zip"
}
