################################################################################
#                    Phase 2 Cluster Processing - NEW
#
# Purpose:
#   Phase 1 filters out RST clusters to prevent instance-level alert conflicts.
#   However, Phase 2 needs to process ALL clusters (including RST) for workload
#   onboarding. This output provides the complete cluster list to Phase 2.
#
# Why separate from aks_cluster_names:
#   - aks_cluster_names: Used by Phase 1, excludes RST (for alert creation)
#   - aks_cluster_names_all: Used by Phase 2, includes RST (for all clusters)
#
# RST Cluster Processing Flow:
#   Phase 1 output → aks_cluster_names_all (all clusters)
#   ↓
#   Phase 2 PowerShell reads output
#   ↓
#   For each cluster (including dev-rst):
#     - Sets var.bfhaks_instance_cluster_name = full cluster name
#     - Detects RST pattern via is_restore_cluster regex
#     - Creates cluster-specific RBAC/federated credentials
#     - Routes to original environment's TFC workspace
#
################################################################################

output "aks_cluster_names_all" {
  description = "All AKS cluster names including restore/validation clusters for Phase 2 processing"
  value       = [for cluster in local.aks_clusters : cluster.name]
}
