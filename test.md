

1. **Timestamps straight from the deployments.** This is the most direct check and needs no log paging.
   ```powershell
   'madeOffer5xAks','madeOffer6xAks','prescreen5xAks','prescreen6xAks','prescreen6r2Aks','prescreenAcceptance6xAks','prescreenAcceptance7xAks','prescreenAcceptance7xr2Aks','wcclientaccessAks','creditbureau' | ForEach-Object { az deployment group show -g rg-ads-cus-entbusops-perf-ext-apim-001 -n $_ --subscription 8eaba5f3-47e8-4b82-82c4-b1877eca14c5 -o json | ConvertFrom-Json | Select-Object name, @{n='state';e={$_.properties.provisioningState}}, @{n='time';e={$_.properties.timestamp}} }
   ```
2. **Who created them** (fixed version).
   ```powershell
   az monitor activity-log list --resource-group rg-ads-cus-entbusops-perf-ext-apim-001 --subscription 8eaba5f3-47e8-4b82-82c4-b1877eca14c5 --offset 90d --max-events 5000 -o json | ConvertFrom-Json | Where-Object { $_.resourceId -match 'deployments/(madeOffer5xAks|prescreen5xAks|creditbureau|wcclientaccessAks)$' } | Select-Object eventTimestamp, caller, @{n='op';e={$_.operationName.value}}, @{n='status';e={$_.status.value}}, @{n='deployment';e={($_.resourceId -split '/')[-1]}} | Sort-Object eventTimestamp | Format-Table -AutoSize
   ```
3. **What that commit changed.**
   ```powershell
   git show --stat --format="%h | %an | %ad | %s" --date=short 7ee22fb3
   ```
   ```powershell
   git branch -r --contains 7ee22fb3
   ```
