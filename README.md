# Azure Batch

> You might need to increase your Batch quotas when first creating accounts and pools

Create the account:

```sh
terraform init
terraform apply -auto-approve
```

Configure your Bath account logs to be sent to the Log Analytics Workspace by setting up the Diagnostic Settings using the portal.

Upload the application package:

```sh
az batch application package create \
  -n bafastbrains \
  -g rg-fastbrains \
  --application-name "molecular-analysis" \
  --package-file run.zip \
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

## Reference

- [Azure Batch permissions](https://techcommunity.microsoft.com/t5/azure-paas-blog/the-usage-of-managed-identity-in-the-azure-batch-account-and/ba-p/3607014)
