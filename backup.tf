
  # AKS clusters that must be excluded from Prometheus alert rule-group
  # creation because the resources may already exist after an Azure Backup
  # restore. The list is intentionally static so Terraform can determine
  # the app_alerts for_each keys during plan.
  excluded_cluster_names = [
    "aks-bfhaks-ihub-eus2-dev-rst-01"
  ]
}
