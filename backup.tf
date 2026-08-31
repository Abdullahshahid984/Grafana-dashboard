locals {
  aks_clusters = [
    for k, v in data.azurerm_kubernetes_cluster.aks : {
      name = v.name
      id   = v.id
    }
  ]

  ################################################################################
  #                    Excluded Clusters (Prometheus Alert Rules)
  #
  # Purpose:
  #   Hardcoded list of AKS cluster names to exclude from Prometheus alert rule
  #   group creation in the app_alerts module.
  #
  # Why hardcoded and not read from conf.yaml:
  #   Reading from conf.yaml dynamically causes the value to be "known after
  #   apply" at Terraform plan time because it depends on data sources. This
  #   means the for_each keys in app_alerts cannot be determined during plan
  #   causing the filter to have no effect. Hardcoding ensures the value is
  #   always known at plan time.
  #
  # Why this is needed:
  #   When a restore/validation cluster is added to conf.yaml under aks_cluster,
  #   the app_alerts module creates Prometheus alert rule groups for every
  #   workload on that cluster. Azure Backup has already restored those same
  #   rule groups into the same resource group with identical names. When
  #   Terraform tries to create them Azure rejects it with "resource already
  #   exists" error breaking the shared pipeline.
  #
  # How to use:
  #   Add restore/validation cluster name to this list before running pipeline.
  #   Remove it after restore validation is complete.
  #   Zero impact when list is empty [].
  ################################################################################

  excluded_cluster_names = [
    "aks-bfhaks-ihub-eus2-dev-rst-01"
  ]
}
