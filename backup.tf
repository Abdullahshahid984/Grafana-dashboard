resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "aks_backup_instance" {
  for_each = local.backup_instances

  name                         = "bi-${each.key}"
  location                     = local.conf.settings.location
  vault_id                     = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].id
  kubernetes_cluster_id        = module.aks_cluster[each.key].id
  snapshot_resource_group_name = data.azurerm_resource_group.snapshot_rg.name
  backup_policy_id             = azurerm_data_protection_backup_policy_kubernetes_cluster.aks_policy[each.value.backup_policy].id

  backup_datasource_parameters {
    cluster_scoped_resources_enabled = true
    volume_snapshot_enabled          = each.value.volume_snapshot_enabled
    included_namespaces              = []
    excluded_namespaces              = []
    included_resource_types          = []
    excluded_resource_types          = []
    label_selectors                  = []
  }

  # Azure Disk volumes can hold at most 500 snapshots, so keep a margin below that
  lifecycle {
    precondition {
      condition = (
        !each.value.volume_snapshot_enabled ||
        (local.backup_policies[each.value.backup_policy].retention_days * 24 / local.backup_policies[each.value.backup_policy].interval_hours) <= 480
      )
      error_message = "Volume snapshots are enabled but the policy would keep more than 480 snapshots per volume (retention_days x 24 / backup_interval_hours). Azure allows 500. Reduce retention_days or increase backup_interval_hours."
    }
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.aks_backup,
    azurerm_kubernetes_cluster_trusted_access_role_binding.aks_trusted_access,
    azurerm_role_assignment.vault_reader_on_cluster,
    azurerm_role_assignment.vault_blob_data_contributor,
    azurerm_role_assignment.vault_snapshot_contributor,
    azurerm_role_assignment.vault_data_operator,
    azurerm_role_assignment.vault_reader_on_snapshot_rg,
    azurerm_role_assignment.extension_storage_contributor,
    azurerm_role_assignment.cluster_contributor_on_snap_rg,
  ]
}
