variable "is_restore_cluster" {
  type        = bool
  description = "Set to true for restore/validation clusters (e.g., dev-rst). Enables cluster-specific RBAC naming."
  default     = false
}
