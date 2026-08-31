################################################################################
#                    Excluded Clusters (Prometheus Alert Rules)
#
# Purpose:
#   Defines AKS clusters that should be excluded from Prometheus alert rule
#   group creation by the app_alerts module.
#
# Why this is needed:
#   Restore or validation clusters may already contain Prometheus alert rule
#   groups restored by Azure Backup. Attempting to create the same resources
#   again through Terraform results in an Azure "resource already exists"
#   conflict.
#
# Configuration:
#   The exclusion list is provided by phase 01 and is used by the app_alerts
#   module to skip Prometheus alert rule group creation for the specified
#   clusters.
#
# Default behavior:
#   An empty list [] excludes no clusters and preserves the existing behavior.
################################################################################

variable "excluded_cluster_names" {
  description = "List of AKS cluster names to exclude from Prometheus alert rule group creation. Used for restore or validation clusters where the resources may already exist due to Azure Backup. An empty list means no clusters are excluded."
  type        = list(string)
  default     = []
}
