
**1. See what files are inside:**
```powershell
Get-ChildItem "$HOME\Downloads\ReleaseLogs_25644\6_PERF" -Recurse -File | Select-Object FullName, Length
```

**2. Search the PERF logs for the error and the resources Terraform tried to create:**
```powershell
Select-String -Path "$HOME\Downloads\ReleaseLogs_25644\6_PERF\*" -Pattern "already exists|Error:" -Context 0,6 -Recurse
```

`Select-String` doesn't recurse by itself, so if step 1 shows nested folders, use this instead:
```powershell
Get-ChildItem "$HOME\Downloads\ReleaseLogs_25644\6_PERF" -Recurse -File | Select-String -Pattern "already exists|Error:" -Context 0,6
```

**3. List every resource it wanted to create, and the plan summary:**
```powershell
Get-ChildItem "$HOME\Downloads\ReleaseLogs_25644\6_PERF" -Recurse -File | Select-String -Pattern "will be created|^.*Plan:" | Select-Object -ExpandProperty Line
```

