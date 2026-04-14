# Get AKS cluster user-assigned identity
data "azurerm_user_assigned_identity" "aks_identity" {
  for_each = local.backup_instances

  name                = "mi-bfhaks-ihub_cluster-eus2-poc-01"
  resource_group_name = local.conf.settings.resource_group_name
}

# Give AKS identity Contributor on snapshot RG
resource "azurerm_role_assignment" "aks_contributor_on_snapshot_rg" {
  for_each = local.backup_instances

  scope                = data.azurerm_resource_group.snapshot_rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.aks_identity[each.key].principal_id
}
