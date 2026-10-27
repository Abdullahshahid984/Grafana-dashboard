```
az apim api list --resource-group rg-ads-cus-entbusops-perf-ext-apim-001 --service-name apim-ads-cus-entbusops-perf-ext-apim-001 --subscription 8eaba5f3-47e8-4b82-82c4-b1877eca14c5 -o table
```

```
az deployment group list --resource-group rg-ads-cus-entbusops-perf-ext-apim-001 --subscription 8eaba5f3-47e8-4b82-82c4-b1877eca14c5 -o json | ConvertFrom-Json | Where-Object { $_.name -match 'transaction' } | Select-Object name, @{n='state';e={$_.properties.provisioningState}}, @{n='time';e={$_.properties.timestamp}}
```

```
git grep -n -i "transactions" -- "*.api.template.json" | head
```
