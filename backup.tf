variable "excluded_cluster_names" {
  description = "List of AKS cluster names to exclude from Prometheus alert rule group creation."
  type        = list(string)
  default     = []
}
