# Contributor on snapshot RG — required by AKS cluster managed identity
resource "azurerm_role_assignment" "aks_cluster_contributor_on_snapshot_rg" {
  for_each = local.backup_instances

  scope                = data.azurerm_resource_group.snapshot_rg.id
  role_definition_name = "Contributor"
  principal_id         = module.aks_cluster[each.key].identity[0].principal_id
}

# Reader on snapshot RG — required by Backup Vault managed identity
resource "azurerm_role_assignment" "vault_reader_on_snapshot_rg" {
  for_each = local.backup_instances

  scope                = data.azurerm_resource_group.snapshot_rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}
