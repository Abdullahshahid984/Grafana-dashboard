resource "azurerm_resource_group" "snapshot_rg" {
  for_each = {
    for k, v in local.backup_instances :
    k => v
    if v.snapshot_rg_name != null
  }

  name     = each.value.snapshot_rg_name
  location = local.conf.settings.location
}
