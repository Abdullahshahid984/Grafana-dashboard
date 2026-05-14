data "azurerm_user_assigned_identity" "cluster_identity" {
  for_each = local.backup_instances

  name                = [
    for c in local.aks_clusters_conf :
    c.identity.identity_ids[0].ref
    if c.name == each.key
  ][0]
  resource_group_name = local.conf.settings.resource_group_name
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
