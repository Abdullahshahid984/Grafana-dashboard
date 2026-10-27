```
'madeOffer5xAks','prescreen5xAks','creditbureau','wcclientaccessAks' | ForEach-Object { "== $_"; (az deployment group show -g rg-ads-cus-entbusops-perf-ext-apim-001 -n $_ --subscription 8eaba5f3-47e8-4b82-82c4-b1877eca14c5 -o json | ConvertFrom-Json).properties.error | ConvertTo-Json -Depth 8 }
```

```
az deployment operation group list -g rg-ads-cus-entbusops-perf-ext-apim-001 -n madeOffer5xAks --subscription 8eaba5f3-47e8-4b82-82c4-b1877eca14c5 -o json | ConvertFrom-Json | Where-Object { $_.properties.provisioningState -eq 'Failed' } | ForEach-Object { $_.properties.statusMessage | ConvertTo-Json -Depth 8 }
```

```
Get-ChildItem "$HOME\Downloads\ReleaseLogs_25644\6_PERF" -Recurse -File -Filter "*Download artifact*" | Select-String -Pattern "Build|Version|branch|commit" | Select-Object -First 15 -ExpandProperty Line
```
