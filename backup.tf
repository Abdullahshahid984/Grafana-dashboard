 cluster_identities = {
    for ci in lookup(local.conf, "cluster_identity", []) :
    ci.name => ci.name
  }

  aks_to_identity = {
    for aks in lookup(local.conf, "aks_cluster", []) :
    aks.name => aks.identity.identity_ids[0].ref
  } 

data "azurerm_user_assigned_identity" "aks_identity" {
  for_each = local.aks_to_identity

  name                = each.value
  resource_group_name = local.conf.settings.resource_group_name
}



resource "azurerm_role_assignment" "aks_contributor_on_snapshot_rg" {
  for_each = local.backup_instances

  scope                = data.azurerm_resource_group.snapshot_rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.aks_identity[each.key].principal_id
}
