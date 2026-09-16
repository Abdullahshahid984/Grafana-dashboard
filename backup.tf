locals {
  restore_target_cluster_names = [
    for c in local.bfhaks_instance_conf.aks_cluster : c.name
    if can(regex(".*-rst-.*", c.name))
  ]

  restore_target = {
    for name in local.restore_target_cluster_names : name => {
      name                = name
      resource_group_name = local.bfhaks_instance_conf.settings.resource_group_name
    }
  }
}
