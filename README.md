# Azure Batch

> You might need to increase your Batch quotas when first creating accounts and pools

<img src=".docs/batch.png" />

To override TF variables create the `.auto.tfvars` file:

```sh
cp config/template.tfvars .auto.tfvars
```

Create the account:

```sh
terraform init
terraform apply -auto-approve
```

ℹ️ The pool will be provisioned with 0 nodes. Adjust your preferences accordingly.

Configure your Batch account logs to be sent to the Log Analytics Workspace by setting up the Diagnostic Settings using the portal.

Upload the application package:

```sh
az batch application package create \
  -n bafastbrains \
  -g rg-fastbrains \
  --application-name "molecular-analysis" \
  --package-file artifacts/run.zip \
  --version-name "1.0"

az batch application set \
  -n bafastbrains \
  -g rg-fastbrains \
  --application-name "molecular-analysis" \
  --default-version "1.0"
```

Set the application to the pool:

```sh
az batch pool set \
  --account-name bafastbrains \
  --pool-id dev \
  --application-package-references "molecular-analysis#1.0"
```

One option to easily interact with the CLI is to login to the Batch account:

```sh
az batch account login \
  --name bafastbrains \
  --resource-group rg-fastbrains \
  --shared-key-auth
```
Alternatively, if you need to use the keys, add `--shared-key-auth`.

Run a task:

```sh
az batch task create --task-id sciTask001 --command-line "echo task001" --job-id dev-job
```

View task status:

```sh
az batch task show \
  --job-id dev-job \
  --task-id sciTask001
```

View task output

```sh
az batch task file list \
  --job-id dev-job \
  --task-id sciTask001 \
  --output table
```

It is possible to create a task with the [`--json-file`](https://learn.microsoft.com/en-us/cli/azure/batch/task?view=azure-cli-latest#az-batch-task-create) option:

> The file containing the task(s) to create in JSON(formatted to match REST API request body). When submitting multiple tasks, accepts either an array of tasks or a TaskAddCollectionParamater. If this parameter is specified, all other parameters are ignored.

Additional functionality for the CLI is available through extensions:

```sh
az extension add --name azure-batch-cli-extensions
```

The Jumpbox already has System-Assigned Identity. To use it:

```sh
# Using the System-Assigned identity within the VM
az login --identity
```

This is not required if you use `az batch account login`, but another option to interact with a private endpoint Batch/pools using the Jumpbox:

```sh
export AZURE_BATCH_ACCOUNT=""
export AZURE_BATCH_ENDPOINT=""
export AZURE_BATCH_ACCESS_KEY=""
```

Now it is possible to use the private endpoints:

```
az batch pool list
```

## Quota increase

https://learn.microsoft.com/en-us/rest/api/support/quota-payload#azure-batch

```
Create a ticket to request Quota increase for Pools for a Batch account.
        az support tickets create \
          --contact-country "USA" \
          --contact-email "abc@contoso.com" \
          --contact-first-name "Foo" \
          --contact-language "en-US" \
          --contact-last-name "Bar" \
          --contact-method "email" \
          --contact-timezone "Pacific Standard Time" \
          --description "QuotaTicketDescription" \
          --problem-classification "/providers/Microsoft.Support/services/QuotaServiceNameGuid/probl
        emClassifications/BatchQuotaProblemClassificationNameGuid" \
          --severity "minimal" \
          --ticket-name "QuotaTestTicketName" \
          --title "QuotaTicketTitle" \
          --quota-change-payload "{\"AccountName\":\"test\", \"NewLimit\":200, \"Type\":\"Pools\"}"
        \
          --quota-change-regions "EastUS" \
          --quota-change-version "1.0" \
          --quota-change-subtype "Account"
```

## Reference

- [Azure Batch permissions](https://techcommunity.microsoft.com/t5/azure-paas-blog/the-usage-of-managed-identity-in-the-azure-batch-account-and/ba-p/3607014)
- [Private Endpoints + VM](https://learn.microsoft.com/en-us/troubleshoot/azure/general/azure-batch-pool-creation-failure#cause-1-public-network-access-is-disabled-but-batch-account-doesnt-have-private-endpoint)