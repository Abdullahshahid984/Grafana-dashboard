```
az apim api list --resource-group rg-ads-cus-entbusops-perf-ext-apim-001 --service-name apim-ads-cus-entbusops-perf-ext-apim-001 --subscription 8eaba5f3-47e8-4b82-82c4-b1877eca14c5 -o json | ConvertFrom-Json | Where-Object { $_.displayName -match 'transaction' } | Select-Object name, displayName, path
```

```
az apim show --name apim-ads-cus-entbusops-perf-ext-apim-001 --resource-group rg-ads-cus-entbusops-perf-ext-apim-001 --subscription 8eaba5f3-47e8-4b82-82c4-b1877eca14c5 --query gatewayUrl -o tsv
```
