variable "grafana_major_version" {
  type = string
  
  validation {
    condition     = contains(["10", "11", "12", "13"], var.grafana_major_version)
    error_message = "Grafana major version must be 10, 11, 12, or 13."
  }
}
