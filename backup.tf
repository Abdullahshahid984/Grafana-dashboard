################################################################################
#                      Restore Clusters (Backup & Restore)
#
# Dynamically reads OIDC issuer URLs for each restore cluster provided.
# The for_each converts the restore_clusters list into a map keyed by
# cluster name so Terraform can manage each cluster independently.
# No resources are created when restore_clusters is empty [].
################################################################################

data "azurerm_kubernetes_cluster" "restore_clusters" {
  for_each            = { for c in var.restore_clusters : c.name => c }
  name                = each.value.name
  resource_group_name = each.value.resource_group_name != "" ? each.value.resource_group_name : local.bfhaks_instance_conf.settings.resource_group_name
}


# Pass restore cluster OIDC issuer URLs as a map (cluster name => oidc url).
# Empty map {} when no restore clusters are defined.
  restore_cluster_oidc_issuer_urls = { for k, v in data.azurerm_kubernetes_cluster.restore_clusters : k => v.oidc_issuer_url }
