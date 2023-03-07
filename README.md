

https://techcommunity.microsoft.com/t5/azure-paas-blog/the-usage-of-managed-identity-in-the-azure-batch-account-and/ba-p/3607014


```
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
