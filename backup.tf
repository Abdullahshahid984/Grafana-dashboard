################################################################################
#                      Additional Clusters (OIDC)
#
# Purpose:
#   Reads the OIDC issuer URL for each additional cluster provided in the
#   additional_clusters variable. The OIDC issuer URL is unique per cluster
#   and is required to create the federated credential on the Managed Identity.
#   Only created when additional_clusters is non-empty.
#   Results are passed to the kubernetes_resources module as a map of
#   cluster key => OIDC issuer URL.
################################################################################

data "azurerm_kubernetes_cluster" "additional_clusters" {
  for_each            = var.additional_clusters
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}
