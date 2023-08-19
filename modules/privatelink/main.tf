### Batch Private Endpoints ###

# Zone Link
resource "azurerm_private_dns_zone" "batch" {
  name                = "privatelink.batch.azure.com"
  resource_group_name = var.group
}

resource "azurerm_private_dns_zone_virtual_network_link" "batch" {
  name                  = "azurebatch-link"
  resource_group_name   = var.group
  private_dns_zone_name = azurerm_private_dns_zone.batch.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = true
}

# Account Endpoint
resource "azurerm_private_endpoint" "batch_account" {
  count               = var.provision_batchAccount_private_endpoint ? 1 : 0
  name                = "pe-batchaccount-${var.sys}"
  location            = var.location
  resource_group_name = var.group
  subnet_id           = var.subnet_id

  private_dns_zone_group {
    name = azurerm_private_dns_zone.batch.name
    private_dns_zone_ids = [
      azurerm_private_dns_zone.batch.id
    ]
  }

  private_service_connection {
    name                           = "batch-account"
    private_connection_resource_id = var.batch_account_id
    is_manual_connection           = false
    subresource_names              = ["batchAccount"]
  }
}

# Node Endpoint
resource "azurerm_private_endpoint" "node_management" {
  count               = var.provision_nodeManagement_private_endpoint ? 1 : 0
  name                = "pe-nodemanagement-${var.sys}"
  location            = var.location
  resource_group_name = var.group
  subnet_id           = var.subnet_id

  private_dns_zone_group {
    name = azurerm_private_dns_zone.batch.name
    private_dns_zone_ids = [
      azurerm_private_dns_zone.batch.id
    ]
  }

  private_service_connection {
    name                           = "node-management"
    private_connection_resource_id = var.batch_account_id
    is_manual_connection           = false
    subresource_names              = ["nodeManagement"]
  }
}
