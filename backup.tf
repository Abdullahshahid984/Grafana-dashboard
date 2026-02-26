locals {
  aks_backup_policy_conf = lookup(local.conf, "aks_backup_policy", [])
  aks_backup_policies = {
    for policy in local.aks_backup_policy_conf : policy.name => {
      name                    = policy.name
      backup_vault_name       = azurerm_data_protection_backup_vault.backup_vault[policy.backup_vault].name
      resource_group_name     = local.conf.settings.resource_group_name
      excluded_namespaces     = lookup(policy, "excluded_namespaces", [])
      excluded_resource_types = lookup(policy, "excluded_resource_types", [])
      included_namespaces     = lookup(policy, "included_namespaces", ["*"])
      included_resource_types = lookup(policy, "included_resource_types", ["*"])
      label_selectors         = lookup(policy, "label_selectors", [])
    }
  }
}

# AKS Backup Policy resource
# Configures backup schedule and operational tier settings for AKS cluster protection
resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "aks_backup_policy" {
  for_each = local.aks_backup_policies

  name                = each.value.name
  vault_name          = each.value.backup_vault_name
  resource_group_name = each.value.resource_group_name

  # Backup schedule - every 4 hours starting at 04:00 UTC
  backup_repeating_time_intervals = ["R/2026-01-01T04:00:00+00:00/PT4H"]
  time_zone                       = "UTC"
  default_retention_duration      = "P30D"

  # Default retention rule for operational tier backups
  default_retention_rule {
    life_cycle {
      duration        = "P30D"
      data_store_type = "OperationalStore"
    }
  }

  depends_on = [
    azurerm_data_protection_backup_vault.backup_vault
  ]
}
