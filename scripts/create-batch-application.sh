#!/bin/bash

batchAccountName="bafastbrains"
resourceGroup="rg-fastbrains"
applicationName="molecular-analysis"
version="1.0"

az batch application package create \
  -n $batchAccountName \
  -g $resourceGroup \
  --application-name $applicationName \
  --package-file ../artifacts/run.zip \
  --version-name $version \
  --only-show-errors

az batch application set \
  -n $batchAccountName \
  -g $resourceGroup \
  --application-name $applicationName \
  --default-version $version \
  --only-show-errors
