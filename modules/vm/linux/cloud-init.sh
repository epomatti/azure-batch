#!/bin/sh

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Update
sudo apt update
sudo apt upgrade -y

# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Add Batch extensions if required
az extension add --name azure-batch-cli-extensions -y
