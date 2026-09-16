---

**CHANGE 1 - Line 40 (app_team_principal_at_namespace):**

**FROM:**
```hcl
for_each = local.app_team_principals_final
```

**TO:**
```hcl
for_each = var.is_restore_cluster ? local.app_team_principals_final : local.app_team_principals_for_this_instance
```

---

**CHANGE 2 - Line 50 (app_team_principal_all_namespace):**

**FROM:**
```hcl
for_each = local.app_team_principal_all_namespace_final
```

**TO:**
```hcl
for_each = var.is_restore_cluster ? local.app_team_principal_all_namespace_final : local.app_team_principal_all_namespace_for_this_instance
```

---

**CHANGE 3 - Line 60 (devops_pipeline_credential_at_namespace):**

**FROM:**
```hcl
for_each = local.devops_pipeline_credentials_final[local.matching_platform_instance_data.devops_pipeline_credential.type]
```

**TO:**
```hcl
for_each = var.is_restore_cluster ? local.devops_pipeline_credentials_final[local.matching_platform_instance_data.devops_pipeline_credential.type] : local.devops_pipeline_credentials_for_this_instance[local.matching_platform_instance_data.devops_pipeline_credential.type]
```



**Should I make these 3 changes?**
