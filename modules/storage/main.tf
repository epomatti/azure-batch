### Storage ###

# Batch Auto-storage
resource "azurerm_storage_account" "autostorage" {
  name                     = "st${var.sys}autostg"
  resource_group_name      = var.group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Batch Pool storage
resource "azurerm_storage_account" "jobfiles" {
  name                     = "st${var.sys}jobstg"
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
  source                 = "${path.module}/../artifacts/molecules.zip"
}
