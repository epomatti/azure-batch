# Azure Batch

> You might need to increase your Batch quotas when first creating accounts and pools

Create the account:

```sh
terraform init
terraform apply -auto-approve
```

Upload the application package:

```sh
az batch application package create \
  -n "bafastbrains" \
  -g "rg-fastbrains" \
  --application-name "molecular-analysis" \
  --package-file run.zip \
  --version-name "1.0"

az batch application set \
  -n "bafastbrains" \
  -g "rg-fastbrains" \
  --application-name "molecular-analysis" \
  --default-version "<VERSION>"
```

## Reference

- [Azure Batch permissions](https://techcommunity.microsoft.com/t5/azure-paas-blog/the-usage-of-managed-identity-in-the-azure-batch-account-and/ba-p/3607014)
