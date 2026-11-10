# Dedicated snapshot resource group, created only when the name is set in conf.yaml
resource "azurerm_resource_group" "snapshot_rg" {
  count    = lookup(local.conf.settings, "backup_snapshot_resource_group_name", null) == null ? 0 : 1
  name     = local.conf.settings.backup_snapshot_resource_group_name
  location = local.conf.settings.location

  tags = merge(
    local.common_tags,
    {
      Role = "BFH AKS Platform: Backup Snapshot Resource Group"
    }
  )
}

# Resolves to the dedicated group when set, otherwise to the cluster resource group (as today)
data "azurerm_resource_group" "snapshot_rg" {
  name = lookup(local.conf.settings, "backup_snapshot_resource_group_name", local.conf.settings.resource_group_name)

  depends_on = [azurerm_resource_group.snapshot_rg]
}

  backup_policy_conf = lookup(local.conf, "backup_policy", [])
  backup_policies = {
    for policy in local.backup_policy_conf : policy.name => {
      vault_name     = policy.backup_vault
      interval_hours = policy.backup_interval_hours
      retention_days = policy.retention_days
    }
  }

