```
Get-ChildItem "$HOME\Downloads\ReleaseLogs_25644\6_PERF" -Recurse -File -Filter "*apply*.log" | Select-String -Pattern "Creation complete|Modifications complete|Apply complete" | Select-Object -ExpandProperty Line
```
