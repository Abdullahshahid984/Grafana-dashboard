```
git show origin/develop:APIM/diagnostics/applicationinsights/diagnosticConfig.yaml | Select-String -Pattern "^\s{0,6}[A-Za-z_-]+:\s*\S*$" | Where-Object { $_.Line -notmatch "headers_to_log" } | ForEach-Object { "$($_.LineNumber): $($_.Line)" }
```

```
git grep -n -i "diagnosticConfig" origin/develop
```
