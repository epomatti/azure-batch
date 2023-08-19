#!/bin/bash

batchAccountName="bafastbrains"
resourceGroup="rg-fastbrains"
applicationName="molecular-analysis"
version="1.0"

az batch application package delete \
  -n $batchAccountName \
  -g $resourceGroup \
  --application-name $applicationName \
  --version-name $version \
  --yes \
  --only-show-errors

az batch application delete \
  -n $batchAccountName \
  -g $resourceGroup \
  --application-name $applicationName \
  --yes \
  --only-show-errors
