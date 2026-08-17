################################################################################
#                      Additional Clusters (OIDC)
#
# Purpose:
#   Accepts a map of cluster key => OIDC issuer URL for additional clusters
#   that need Workload Identity federated credentials. Passed from phase 02
#   after reading the additional cluster data sources.
#
#   When empty {} no additional federated credentials are created and
#   existing behavior is completely unchanged.
#
#   Credential naming format: "<sa-name>-<cluster-key>"
#   Example: "sa-api-customerlookup-v1-poc-02"
################################################################################

variable "additional_cluster_oidc_issuer_urls" {
  type        = map(string)
  description = "Map of cluster key => OIDC issuer URL for additional clusters that need federated credentials. Empty map if not applicable."
  default     = {}
}
