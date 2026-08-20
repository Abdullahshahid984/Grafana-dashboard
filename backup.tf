################################################################################
#                    Additional Clusters (Restore Target)
#
# PURPOSE:
#   Automatically create federated credentials on the restore target cluster
#   so that restored workloads can authenticate to Azure (Workload Identity).
#
# CURRENT MAPPINGS:
#   - DEV to POC2: Backup/restore validation (active)
#
# FUTURE MAPPINGS (add when clusters are created):
#   - PRD EUS2 to DR EUS2: Disaster recovery
#   - PRD CUS to DR CUS: Disaster recovery
#
# TO ADD NEW RESTORE MAPPING:
#   1. When DR clusters are created, add entry here
#   2. Key: environment name (prd-eus2, prd-cus, sit, uat, perf)
#   3. Value: cluster key, name, resource group
#   4. Redeploy Terraform
#
# DEPLOYMENT FLOW:
#   Pipeline runs for dev stage
#   → Detects environment = "dev"
#   → restore_target = POC2 cluster config
#   → Data source queries POC2 OIDC issuer
#   → kubernetes_resources module creates federated credentials
#   → Restored workloads can authenticate to Azure
################################################################################

locals {
  # Restore cluster mapping by environment
  # Only includes clusters that EXIST
  # Add new entries when new restore clusters are provisioned
  restore_cluster_mapping = {
    "dev" = {
      cluster_key         = "poc-02"
      cluster_name        = "aks-bfhaks-ihub-eus2-poc-02"
      resource_group_name = "rg-bfhaks-ihub-poc-eus2-dev-01"
    }
  }

  # Current environment (from conf.yaml)
  current_env = local.bfhaks_instance_conf.settings.environment

  # Get restore target cluster config for current environment
  # If environment not in mapping, restore_target = {} (no additional clusters)
  restore_target = contains(keys(local.restore_cluster_mapping), local.current_env) ? {
    (local.restore_cluster_mapping[local.current_env].cluster_key) = {
      name                = local.restore_cluster_mapping[local.current_env].cluster_name
      resource_group_name = local.restore_cluster_mapping[local.current_env].resource_group_name
    }
  } : {}
}

# Data source: Query Azure for restore target cluster details
# Returns the cluster's OIDC issuer URL
# Only executes if restore_target map is not empty
data "azurerm_kubernetes_cluster" "additional_clusters" {
  for_each = local.restore_target

  resource_group_name = each.value.resource_group_name
  name                = each.value.name
}
