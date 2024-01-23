# Network access
batch_account_public           = true
network_account_access         = "Deny"
network_node_management_access = "Deny"

batch_allow_ip = "<IP>"

# Private Link
provision_private_link                    = false
provision_batchAccount_private_endpoint   = false
provision_nodeManagement_private_endpoint = false

# Batch Pool
provision_batch_pool             = false
batch_vm_size                    = "Standard_D2ads_v5" # STANDARD_D2S_V3
public_address_provisioning_type = "BatchManaged"      # NoPublicIPAddresses

# Entra ID
tenant_domain = "<DOMAIN>.onmicrosoft.com"

# Virtual Machines (Jumpbox)
provision_linux_vm = false
provision_win_vm   = false

jumpbox_linux_vm_size = "Standard_B2pts_v2"
jumpbox_win_vm_size   = "Standard_B4as_v2"
