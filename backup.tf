locals {
  aks_backup_instance_conf = lookup(local.conf, "aks_backup_instance", [])
  aks_backup_instances = {
    for instance in local.aks_backup_instance_conf : instance.aks_cluster => {
      aks_cluster                   = instance.aks_cluster
      backup_vault_id               = azurerm_data_protection_backup_vault.backup_vault[instance.backup_vault].id
      backup_policy_id              = azurerm_data_protection_backup_policy_kubernetes_cluster.aks_backup_policy[instance.backup_policy].id
      snapshot_resource_group_name  = lookup(instance, "snapshot_resource_group_name", local.conf.settings.resource_group_name)
      excluded_namespaces           = lookup(instance, "excluded_namespaces", [])
      excluded_resource_types       = lookup(instance, "excluded_resource_types", [])
      included_namespaces           = lookup(instance, "included_namespaces", ["*"])
      included_resource_types       = lookup(instance, "included_resource_types", ["*"])
      label_selectors               = lookup(instance, "label_selectors", [])
      cluster_scoped_resources      = lookup(instance, "cluster_scoped_resources_enabled", true)
      volume_snapshot_enabled       = lookup(instance, "volume_snapshot_enabled", true)
    }
  }
}

# AKS Backup Instance resource
# Defines which AKS cluster is protected by which backup policy
resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "aks_backup_instance" {
  for_each = local.aks_backup_instances

  name                        = "bi-${each.value.aks_cluster}"
  location                    = local.conf.settings.location
  vault_id                    = each.value.backup_vault_id
  kubernetes_cluster_id       = module.aks_cluster[each.value.aks_cluster].id
  backup_policy_id            = each.value.backup_policy_id
  snapshot_resource_group_name = each.value.snapshot_resource_group_name
  

  backup_datasource_parameters {
    excluded_namespaces           = each.value.excluded_namespaces
    excluded_resource_types       = each.value.excluded_resource_types
    included_namespaces           = each.value.included_namespaces
    included_resource_types       = each.value.included_resource_types
    label_selectors               = each.value.label_selectors
    cluster_scoped_resources_enabled = each.value.cluster_scoped_resources
    volume_snapshot_enabled       = each.value.volume_snapshot_enabled
  }

  depends_on = [
    module.aks_cluster,
    azurerm_data_protection_backup_vault.backup_vault,
    azurerm_data_protection_backup_policy_kubernetes_cluster.aks_backup_policy,
    azurerm_kubernetes_cluster_extension.aks_backup
  ]
}
