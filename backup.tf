data "azurerm_user_assigned_identity" "cluster_identity" {
  for_each = local.cluster_identity_ref

  name                = each.value
  resource_group_name = local.conf.settings.resource_group_name
}


  # ---------------------------------------------------------------------------
  # Map each cluster name to its cluster identity module ref
  # ---------------------------------------------------------------------------
  
  cluster_identity_ref = {
    for cluster in local.aks_clusters_conf :
    cluster.name => [
      for entry in lookup(lookup(cluster, "identity", {}), "identity_ids", []) :
      entry.ref
      if lookup(entry, "ref", null) != null
    ][0]
    if lookup(cluster, "identity", null) != null
  }



resource "azurerm_role_assignment" "vault_reader_on_snap_rg" {
  for_each = local.backup_instances

  scope                = data.azurerm_resource_group.snapshot_rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

# Disk Snapshot Contributor on snapshot resource group
resource "azurerm_role_assignment" "vault_snapshot_contributor" {
  for_each = local.backup_instances

  scope = data.azurerm_resource_group.snapshot_rg.id
  # scope                = azurerm_resource_group.snapshot_rg[each.key].id
  role_definition_name = "Disk Snapshot Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

# Data Operator for Managed Disks on snapshot resource group
resource "azurerm_role_assignment" "vault_data_operator" {
  for_each = local.backup_instances

  scope = data.azurerm_resource_group.snapshot_rg.id
  # scope                = azurerm_resource_group.snapshot_rg[each.key].id
  role_definition_name = "Data Operator for Managed Disks"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}


################################################################################
# RBAC - AKS CLUSTER IDENTITY ROLE ASSIGNMENTS
################################################################################

resource "azurerm_role_assignment" "cluster_contributor_on_snap_rg" {
  for_each = local.backup_instances

  scope                = data.azurerm_resource_group.snapshot_rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.cluster_identity[each.key].principal_id
}
