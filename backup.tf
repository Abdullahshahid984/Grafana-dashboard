
################################################################################
#                    RBAC Keys: Conditional by Cluster Type - NEW
#
# IF is_restore_cluster = true:  Use cluster-specific keys (prevent conflicts)
# IF is_restore_cluster = false: Use original keys (backward compatible)
################################################################################

locals {
  # Extract cluster name from Azure resource ID
  # Format: /subscriptions/.../providers/Microsoft.ContainerService/managedClusters/aks-cluster-name
  cluster_name = reverse(split("/", var.kubernetes_cluster_id))[0]

  # Conditional RBAC keys based on cluster type
  app_team_principals_final = var.is_restore_cluster ? {
    for principal_name, principal_config in local.app_team_principals_for_this_instance :
    "${principal_name}__${local.cluster_name}" => principal_config
  } : local.app_team_principals_for_this_instance

  app_team_principal_all_namespace_final = var.is_restore_cluster ? {
    for principal_name, principal_config in local.app_team_principal_all_namespace_for_this_instance :
    "${principal_name}__${local.cluster_name}" => principal_config
  } : local.app_team_principal_all_namespace_for_this_instance

  devops_pipeline_credentials_final = var.is_restore_cluster ? {
    none = {}
    custom = {
      for i in lookup(local.matching_platform_instance_data.devops_pipeline_credential, "custom", null) :
      "${i.name}__${local.cluster_name}" => i
    }
    instance_default = {
      for i in var.default_devops_pipeline_credential :
      "${i.name}__${local.cluster_name}" => i
    }
  } : local.devops_pipeline_credentials_for_this_instance
}
