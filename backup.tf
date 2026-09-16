################################################################################
#                    Restore/Validation Cluster Detection - NEW
#
# When true: Alert rule names include cluster name (prevent conflicts)
# When false: Original alert rule names (backward compatible)
################################################################################

variable "is_restore_cluster" {
  type        = bool
  description = "Set to true for restore/validation clusters (e.g., dev-rst). Adds cluster name to alert rule names."
  default     = false
}
