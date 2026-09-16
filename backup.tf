FILE 7: phases/02-per-instance-per-cluster/main.tf
ADD after line 54 (after restore_target definition):

locals {
  is_restore_cluster = can(regex(".*-rst-.*", var.bfhaks_instance_cluster_name))
}
In kubernetes_resources module - ADD after line 113:

  is_restore_cluster = local.is_restore_cluster
