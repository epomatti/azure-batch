# Network access
batch_account_public           = true
network_account_access         = "Deny"
network_node_management_access = "Deny"

batch_allow_ip = "123.123.123.123"

# Private Link
provision_private_link                    = true
provision_batchAccount_private_endpoint   = true
provision_nodeManagement_private_endpoint = true

# Batch Pool
provision_batch_pool             = true
batch_vm_size                    = "Standard_D2ads_v5" # STANDARD_D2S_V3
public_address_provisioning_type = "BatchManaged" # NoPublicIPAddresses

# Virtual Machines (Jumpbox)
provision_linux_vm = false
provision_win_vm   = false

jumpbox_linux_vm_size = "Standard_B2pts_v2"
jumpbox_win_vm_size   = "Standard_B4as_v2"
