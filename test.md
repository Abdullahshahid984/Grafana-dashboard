```
git show origin/develop:APIM/terraform/diagnostics.tf | Select-Object -First 130
```

```
git show origin/develop:APIM/diagnostics/applicationinsights/diagnosticConfig.yaml | Select-Object -Skip 521 -First 60
```
