locals {
  aks_clusters = [
    for k, v in data.azurerm_kubernetes_cluster.aks : {
      name = v.name
      id   = v.id
    }
  ]

  # AKS clusters that must be excluded from Prometheus alert rule-group
  # creation because the resources may already exist after an Azure Backup
  # restore. The list is intentionally static so Terraform can determine
  # the app_alerts for_each keys during plan.
  excluded_cluster_names = [
    "aks-bfhaks-ihub-eus2-dev-rst-01"
  ]
}
