locals {
  # Filter AKS clusters to exclude restore/validation clusters (those with -rst- in name)
  # RST clusters will have Prometheus alert rules restored by Azure Backup,
  # so we skip creating them in Phase 1 to avoid "resource already exists" conflicts.
  # Alert rules are created per-cluster in Phase 2 with conditional naming based on is_restore_cluster.
  aks_clusters = [
    for k, v in data.azurerm_kubernetes_cluster.aks : {
      name = v.name
      id   = v.id
    }
    if !can(regex(".*-rst-.*", v.name))
  ]
}
