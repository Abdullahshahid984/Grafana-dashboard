resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "aks_backup_instance" {
  for_each = local.backup_instances

  name                         = "bi-${each.key}"
  location                     = local.conf.settings.location
  vault_id                     = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].id
  kubernetes_cluster_id        = module.aks_cluster[each.key].id
  snapshot_resource_group_name = azurerm_resource_group.snapshot_rg[each.key].name
  backup_policy_id             = azurerm_data_protection_backup_policy_kubernetes_cluster.aks_policy[each.value.backup_vault].id

  backup_datasource_parameters {
    cluster_scoped_resources_enabled = true
    volume_snapshot_enabled          = true

    # FULL CLUSTER PROTECTION 
    included_namespaces     = []
    excluded_namespaces     = []
    included_resource_types = []
    excluded_resource_types = []
    label_selectors         = []
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.aks_backup
  ]
}
