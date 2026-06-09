################################################################################
#                      Restore Clusters (Backup & Restore)
#
# Optional: provide a list of clusters to automatically create federated
# credentials for all workloads. This is needed because each AKS cluster has
# a unique OIDC issuer URL. When workloads are restored to a new cluster via
# Azure Backup, the existing federated credentials only cover the original
# cluster. Adding clusters here ensures Entra ID accepts token exchange
# requests, allowing pods to mount Key Vault secrets and start successfully.
#
# The variable name "restore_clusters" is the source of truth — any cluster
# listed here will get federated credentials, regardless of its name.
#
# Usage:
#   - Add cluster(s) before restore validation, remove after.
#   - Supports multiple clusters simultaneously.
#   - Leave as empty list [] when not in use. Zero impact on existing behavior.
#
# Example:
#   restore_clusters = [
#     {
#       name                = "aks-bfhaks-ihub-eus2-dev-rst-01"
#       resource_group_name = "rg-bfhaks-ihub-eus2-dev-01"
#       purpose             = "restore"
#     }
#   ]
################################################################################

variable "restore_clusters" {
  description = "List of clusters for backup/restore validation. Leave empty if not applicable."
  type = list(object({
    name                = string
    resource_group_name = optional(string, "")
    purpose             = optional(string, "restore") # e.g. restore, dr, backup, test
  }))
  default = []
}
