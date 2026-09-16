################################################################################
#                    Restore/Validation Cluster Detection - NEW
#
# When true: Uses cluster-specific RBAC keys (e.g., principal__cluster-name)
# When false: Uses original keys (backward compatible)
################################################################################

variable "is_restore_cluster" {
  type        = bool
  description = "Set to true for restore/validation clusters (e.g., dev-rst). Enables cluster-specific RBAC naming."
  default     = false
}
