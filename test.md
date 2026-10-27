```
git grep -l -i "transactions" -- "*.api.template.json"

```
git grep -n -i '"path"' -- "*transactions*api.template.json"
```

```
git ls-files | Select-String -Pattern "transaction" -SimpleMatch | Select-Object -First 20
```
