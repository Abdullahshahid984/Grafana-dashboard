# phases/01-per-instance/locals.tf

# line 22

locals {
  aks_clusters = [
    for k, v in data.azurerm_kubernetes_cluster.aks : {
      name = v.name
      id   = v.id
    }
  ]

  # Automatically derive excluded cluster names from conf.yaml.
  # Clusters with exclude_prometheus_alerts: true will be skipped
  # in Prometheus alert rule creation. Used for restore/validation clusters.
  excluded_cluster_names = [
    for c in local.bfhaks_instance_conf.aks_cluster : c.name
    if try(c.exclude_prometheus_alerts, false) == true
  ]
}

# phases/01-per-instance/main.tf
# Add one line inside existing module "app_alerts" block:

 excluded_cluster_names = local.excluded_cluster_names 

```
# modules/app_alerts/variables.tf
# Add at the bottom

```
################################################################################
#                      Excluded Clusters (Restore/Validation)
#
# List of AKS cluster names to exclude from Prometheus alert rule creation.
# Derived from conf.yaml clusters with exclude_prometheus_alerts: true.
# Leave empty [] for normal operation — zero impact on existing behavior.
################################################################################

variable "excluded_cluster_names" {
  description = "List of AKS cluster names to exclude from Prometheus alert rule creation."
  type        = list(string)
  default     = []
}

# modules/app_alerts/main.tf
# Add if !contains(var.excluded_cluster_names, cluster.name) — only one line added inside the inner for loop:

if !contains(var.excluded_cluster_names, cluster.name)


