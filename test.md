```
(az rest --method get --url "https://management.azure.com/subscriptions/8eaba5f3-47e8-4b82-82c4-b1877eca14c5/resourceGroups/rg-ads-cus-entbusops-perf-ext-apim-001/providers/Microsoft.ApiManagement/service/apim-ads-cus-entbusops-perf-ext-apim-001/tags?api-version=2022-08-01" | ConvertFrom-Json).value | Where-Object { $_.name -match 'transaction' } | Select-Object name, @{n='displayName';e={$_.properties.displayName}}
```
