# Azure Batch

> You might need to increase your Batch quotas when first creating accounts and pools

Create the account:

```sh
terraform init
terraform apply -auto-approve
```

Upload the application:

```sh
az batch application package create \
  -n "babatchsandbox" \
  -g "rg-batchsandbox" \
  --application-name "molecularanalysis" \
  --package-file run.zip \
  --version-name "2.0"

az batch application set \
  -n "babatchsandbox" \
  -g "rg-batchsandbox" \
  --application-name "molecularanalysis" \
  --default-version "2.0"
```

## Reference

- [Azure Batch permissions](https://techcommunity.microsoft.com/t5/azure-paas-blog/the-usage-of-managed-identity-in-the-azure-batch-account-and/ba-p/3607014)