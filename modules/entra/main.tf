data "azuread_client_config" "current" {}

locals {
  user1 = "BatchUser"
}

resource "azuread_user" "batch_user" {
  account_enabled     = true
  user_principal_name = "${local.user1}@${var.tenant_domain}"
  display_name        = local.user1
  mail_nickname       = local.user1
  password            = "P@ssw0rd1234!"
}

resource "azurerm_role_assignment" "group" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = azuread_user.batch_user.id
}

resource "azurerm_role_assignment" "batch" {
  scope                = var.batch_account_id
  role_definition_name = "Contributor"
  principal_id         = azuread_user.batch_user.id
}
