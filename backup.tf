  backup_policy_conf = lookup(local.conf, "backup_policy", [])
  backup_policies = {
    for policy in local.backup_policy_conf : policy.name => {
      vault_name     = policy.backup_vault
      interval_hours = policy.backup_interval_hours
      retention_days = policy.retention_days
    }
  }
