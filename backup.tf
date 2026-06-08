################################################################################
#                      Restore Clusters (Backup & Restore)
#
# Map of restore cluster name => OIDC issuer URL.
# Passed in from phase 02 after reading restore cluster data sources.
# Empty map {} means no restore federated credentials will be created.
################################################################################

variable "restore_cluster_oidc_issuer_urls" {
  type        = map(string)
  description = "Map of restore cluster name => OIDC issuer URL. Empty map if no restore clusters are needed."
  default     = {}
}
