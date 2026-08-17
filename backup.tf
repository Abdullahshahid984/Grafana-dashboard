################################################################################
#                      Additional Clusters (OIDC)
#
# Purpose:
#   Allows the workload onboarding pipeline to automatically create Workload
#   Identity federated credentials for workloads on additional clusters beyond
#   the primary cluster.
#
# When to use:
#   - Backup and restore validation (DEV to POC-02)
#   - Cluster migration (SIT to new SIT, UAT to new UAT etc.)
#   - Disaster recovery (PROD EUS2 to new PROD EUS2)
#
# Why this is needed:
#   Each AKS cluster has a unique OIDC issuer URL. Without a federated
#   credential for the target cluster's OIDC issuer, Entra ID will reject
#   token exchange requests with AADSTS700211, causing pods to get stuck
#   in Init state and CSI Secret Store to fail mounting Key Vault secrets.
#
# How to use:
#   Set this variable in the HCP Terraform workspace before running the
#   pipeline. Remove after work is complete to clean up federated credentials.
#   Zero impact on existing behavior when left as empty map {}.
#
# Example:
#   additional_clusters = {
#     "poc-02" = {
#       name                = "aks-bfhaks-ihub-eus2-poc-02"
#       resource_group_name = "rg-bfhaks-ihub-poc-eus2-dev-01"
#     }
#   }
################################################################################

variable "additional_clusters" {
  description = "Map of additional clusters to create federated credentials for. Key is a short identifier (e.g. poc-02), value is the cluster name and resource group."
  type = map(object({
    name                = string
    resource_group_name = string
  }))
  default = {}
}
