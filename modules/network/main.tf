### Network ###
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.sys}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.group
}

### Batch Subnet ###
resource "azurerm_network_security_group" "batch" {
  name                = "nsg-batch-${var.sys}"
  location            = var.location
  resource_group_name = var.group
}

resource "azurerm_network_security_rule" "batch_inbound" {
  name                        = "batch-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.group
  network_security_group_name = azurerm_network_security_group.batch.name
}

resource "azurerm_network_security_rule" "batch_outbound" {
  name                        = "batch-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.group
  network_security_group_name = azurerm_network_security_group.batch.name
}

resource "azurerm_subnet" "main" {
  name                 = "batch-subnet"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.batch.id
}

### Jumpbox Subnet ###
resource "azurerm_network_security_group" "jumpbox" {
  name                = "nsg-jumpbox-${var.sys}"
  location            = var.location
  resource_group_name = var.group
}

resource "azurerm_network_security_rule" "jumpbox_inbound" {
  name                        = "jumpbox-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.group
  network_security_group_name = azurerm_network_security_group.jumpbox.name
}

resource "azurerm_network_security_rule" "jumpbox_outbound" {
  name                        = "jumpbox-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.group
  network_security_group_name = azurerm_network_security_group.jumpbox.name
}

resource "azurerm_subnet" "jumpbox" {
  name                 = "jumpbox-subnet"
  resource_group_name  = var.group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "jumpbox" {
  subnet_id                 = azurerm_subnet.jumpbox.id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}
