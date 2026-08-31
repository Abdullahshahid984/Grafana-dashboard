################################################################################
#                    Excluded Clusters (Prometheus Alert Rules)
#
# Purpose:
#   Accepts a list of AKS cluster names that should be excluded from
#   Prometheus alert rule group creation.
#
# Why this is needed:
#   Restore/validation clusters may already contain Prometheus alert rule
#   groups restored by Azure Backup. Without this exclusion, the app_alerts
#   module attempts to create the same rule groups again, resulting in an
#   Azure "resource already exists" conflict.
#
# Configuration:
#   The list is passed from phase 01 locals.tf and is intentionally kept
#   plan-time known so Terraform can correctly determine the resources to
#   create in the app_alerts module.
#
# Zero impact:
#   An empty list [] preserves the existing behavior and does not exclude
#   any clusters from Prometheus alert rule creation.
################################################################################

variable "excluded_cluster_names" {
  description = "List of AKS cluster names to exclude from Prometheus alert rule group creation. Used for restore or validation clusters where Azure Backup may have already restored the resources. An empty list means no clusters are excluded."
  type        = list(string)
  default     = []
}
