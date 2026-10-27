```
$names = 'madeOffer5xAks','madeOffer6xAks','prescreen5xAks','prescreen6xAks','prescreen6r2Aks','prescreenAcceptance6xAks','prescreenAcceptance7xAks','prescreenAcceptance7xr2Aks','wcclientaccessAks','creditbureau'
foreach ($n in $names) { az deployment operation group list -g rg-ads-cus-entbusops-perf-ext-apim-001 -n $n --subscription 8eaba5f3-47e8-4b82-82c4-b1877eca14c5 -o json | ConvertFrom-Json | Where-Object { $_.properties.provisioningState -eq 'Failed' } | ForEach-Object { [pscustomobject]@{ deployment = $n; message = (($_.properties.statusMessage.error.details | ForEach-Object { $_.message }) -join ' | ') } } } | Format-List
```
