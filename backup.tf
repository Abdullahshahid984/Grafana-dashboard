locals {

  backup_instances = {
    for inst in lookup(local.conf, "backup_instance", []) :
    inst.aks_cluster => {

      aks_cluster   = inst.aks_cluster
      backup_policy = inst.backup_policy

      snapshot_rg_name = lookup(
        inst,
        "snapshot_resource_group_name",
        null
      )

      backup_vault = lookup(
        {
          for p in lookup(local.conf, "backup_policy", []) :
          p.name => p.backup_vault
        },
        inst.backup_policy,
        null
      )

      storage_account = lookup(
        {
          for ext in lookup(local.conf, "aks_backup_extension", []) :
          ext.aks_cluster => ext.storage_account
        },
        inst.aks_cluster,
        null
      )
    }
  }

}
