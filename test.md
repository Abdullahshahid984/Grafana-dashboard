```
az apim api operation list --resource-group rg-ads-cus-entbusops-prd-ext-apim-001 --service-name apim-ads-cus-entbusops-prd-ext-apim-001 --api-id VirtualAssistantAPI --subscription cf7e12f8-ce8c-43c8-a1c0-1287d71499ca -o json | ConvertFrom-Json | Select-Object method, urlTemplate, displayName | Format-Table -AutoSize
```
