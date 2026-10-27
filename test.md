
**1. When and by whom were the 10 deployments created?** The Azure Activity Log keeps this for 90 days.
```powershell
az monitor activity-log list --resource-group rg-ads-cus-entbusops-perf-ext-apim-001 --subscription 8eaba5f3-47e8-4b82-82c4-b1877eca14c5 --offset 30d -o json | ConvertFrom-Json | Where-Object { $_.resourceId -match 'deployments/(madeOffer5xAks|madeOffer6xAks|prescreen5xAks|prescreen6xAks|prescreen6r2Aks|prescreenAcceptance6xAks|prescreenAcceptance7xAks|prescreenAcceptance7xr2Aks|wcclientaccessAks|creditbureau)$' } | Select-Object eventTimestamp, caller, @{n='op';e={$_.operationName.value}}, @{n='status';e={$_.status.value}}, @{n='deployment';e={($_.resourceId -split '/')[-1]}} | Sort-Object eventTimestamp | Format-Table -AutoSize
```
- **The `caller` is the release's service principal and the times match an earlier attempt today:** an earlier run created them and didn't save the state.
- **The `caller` is a person or a different principal:** someone created them outside this pipeline.
- **Nothing returned:** they're older than 30 days, so rerun with `--offset 90d`.

**2. Did an earlier attempt create them?** The `6_PERF` folder you downloaded has only `Attempt2`. In the release, open the PERF stage and download the logs for **Attempt 1** too. Then:
```powershell
Get-ChildItem "<attempt 1 folder>" -Recurse -File -Filter "*apply*.log" | Select-String -Pattern "madeOffer5xAks|creditbureau" | Select-Object -ExpandProperty Line
```
`Creation complete` for these names, followed by an error or cancellation near the end, would confirm that Attempt 1 created them and the run died before state was saved.

**3. Is the state backend what you expect?**
```powershell
Get-ChildItem "$HOME\Downloads\ReleaseLogs_25644\6_PERF" -Recurse -File -Filter "*init*.log" | Select-String -Pattern "Initializing the backend|Successfully configured" | Select-Object -ExpandProperty Line
```
Don't paste more of the init log than this, because it can contain storage or backend details.

**4. When were these entries added to the config?**
```powershell
git log --oneline -S"madeOffer5xAks" -- "*.tfvars"
```
This shows whether the PERF config gained these entries recently while the deployments already existed.

Send me the results of 1 and 2 at least. Until then, "missing from the state, cause not yet established" is the only claim we can support.
