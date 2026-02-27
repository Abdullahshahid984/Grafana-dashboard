locals {
  backup_policies = {
    for vault_key, vault in azurerm_data_protection_backup_vault.backup_vault :
    vault_key => {
      vault_name = vault.name
    }
  }
}

resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "aks_policy" {
  for_each = local.backup_policies

  name                = "aks-4hour-policy"
  resource_group_name = local.conf.settings.resource_group_name
  vault_name          = each.value.vault_name

  # Every 4 hours
  backup_repeating_time_intervals = [
    "R/2025-01-01T00:00:00+00:00/PT4H"
  ]
  time_zone                  = "UTC"

  default_retention_rule {
    life_cycle {
      duration        = "P30D"
      data_store_type = "OperationalStore"
    }
  }
}
