################################################################################
# DATA SOURCES
################################################################################

data "azurerm_resource_group" "snapshot_rg" {
  name = local.conf.settings.resource_group_name
}
