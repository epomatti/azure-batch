output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "batch_subnet_id" {
  value = azurerm_subnet.main.id
}

output "jumpbox_subnet_id" {
  value = azurerm_subnet.jumpbox.id
}
