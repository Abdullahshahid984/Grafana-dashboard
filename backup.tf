################################################################################
#   Identity: Federated Credential (Additional Clusters)
#
# Purpose:
#   Creates one Workload Identity federated credential per workload component
#   per additional cluster. Allows workloads to authenticate to Azure services
#   (Key Vault, Storage etc.) using Workload Identity when running on a cluster
#   other than the primary cluster.
#
# Why this is needed:
#   Each AKS cluster has a unique OIDC issuer URL. Entra ID validates the
#   OIDC issuer in the token against registered federated credentials on the
#   Managed Identity. If the issuer does not match, Entra ID rejects the token
#   exchange with AADSTS700211 and pods get stuck in Init state because CSI
#   Secret Store cannot mount Key Vault secrets.
#
# Supported scenarios:
#   - DEV    to POC-02       (backup/restore validation)
#   - SIT    to new SIT      (cluster migration)
#   - UAT    to new UAT      (cluster migration)
#   - PERF   to new PERF     (cluster migration)
#   - PROD EUS2 to new PROD  (DR/migration)
#   - PRD CUS   to new PRD   (DR/migration)
#
# How it works:
#   Flattens additional_cluster_oidc_issuer_urls x computed_component_map
#   into a single for_each map. Each combination of cluster and workload
#   component gets its own federated credential resource.
#
#   Key format:      "<cluster-key>-<component-key>"  ensures uniqueness
#   Credential name: "<sa-name>-<cluster-key>"        easy identification
#
#   Only creates credentials for components where workload_identity = true.
#   No resources created when additional_cluster_oidc_issuer_urls is empty {}.
#   Does not affect the original cluster federated credential in any way.
#
# Cleanup:
#   Remove cluster from additional_clusters in HCP Terraform workspace
#   and re-apply. Terraform destroys all related federated credentials
#   cleanly without touching the primary cluster federated credential.
################################################################################

resource "azurerm_federated_identity_credential" "workload_identity_additional" {
  for_each = {
    for pair in flatten([
      for cluster_key, oidc_url in var.additional_cluster_oidc_issuer_urls : [
        for k, v in local.computed_component_map : {
          key           = "${cluster_key}-${k}"  # unique key per cluster+component
          cluster_key   = cluster_key
          oidc_url      = oidc_url
          component_key = k
        }
        if v.workload_identity == true  # only workload identity enabled components
      ]
    ]) : pair.key => pair
  }

  resource_group_name = var.managed_identity_resource_group_name
  # Format: "<sa-name>-<cluster-key>" e.g. "sa-api-customerlookup-v1-poc-02"
  name      = "${kubernetes_service_account_v1.workload_identity[each.value.component_key].metadata.0.name}-${each.value.cluster_key}"
  parent_id = local.workload_identity_map[each.value.component_key].workload_identity.id
  audience  = ["api://AzureADTokenExchange"]
  issuer    = each.value.oidc_url  # additional cluster OIDC issuer URL
  subject   = local.federated_credential_subject[each.value.component_key]
}
