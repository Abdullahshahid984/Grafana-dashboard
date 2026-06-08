################################################################################
#   Identity: Federated Credential (Restore Clusters)
#
# Creates one federated credential per workload component per restore cluster.
#
# Why this is needed:
#   Each AKS cluster has a unique OIDC issuer URL. When workloads are restored
#   to a new cluster via Azure Backup, the existing federated credential on the
#   Managed Identity only covers the original cluster's OIDC issuer. Entra ID
#   rejects token exchange requests from any unregistered issuer, causing the
#   CSI Secret Store to fail mounting Key Vault secrets and leaving pods stuck
#   in Init state (AADSTS700211).
#
# How it works:
#   - Flattens restore_cluster_oidc_issuer_urls x computed_component_map
#     into a single map so Terraform can for_each over all combinations.
#   - Key format: "<cluster-name>-<component-key>" ensures uniqueness.
#   - Credential name: "<sa-name>-<cluster-name>" for easy identification.
#   - Only runs for components where workload_identity = true.
#   - No resources created when restore_cluster_oidc_issuer_urls is empty {}.
#   - Safe to apply/destroy independently — does not affect the original
#     DEV cluster federated credential.
#
# Cleanup:
#   Set restore_clusters = [] in phase 02 variables and re-apply.
#   Terraform will destroy all restore federated credentials cleanly.
################################################################################

resource "azurerm_federated_identity_credential" "workload_identity_restore" {
  for_each = {
    for pair in flatten([
      for cluster_name, oidc_url in var.restore_cluster_oidc_issuer_urls : [
        for k, v in local.computed_component_map : {
          key           = "${cluster_name}-${k}"
          cluster_name  = cluster_name
          oidc_url      = oidc_url
          component     = v
          component_key = k
        }
        if v.workload_identity == true
      ]
    ]) : pair.key => pair
  }

  resource_group_name = var.managed_identity_resource_group_name
  # Format: "<sa-name>-<cluster-name>" e.g. "sa-api-customerlookup-v1-aks-bfhaks-ihub-eus2-dev-rst-01"
  name      = "${kubernetes_service_account_v1.workload_identity[each.value.component_key].metadata.0.name}-${each.value.cluster_name}"
  parent_id = local.workload_identity_map[each.value.component_key].workload_identity.id
  audience  = ["api://AzureADTokenExchange"]
  issuer    = each.value.oidc_url
  subject   = local.federated_credential_subject[each.value.component_key]
}
