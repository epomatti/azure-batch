output "ssh_connect" {
  value = "ssh bastionadmin@${azurerm_public_ip.main.ip_address}"
}
