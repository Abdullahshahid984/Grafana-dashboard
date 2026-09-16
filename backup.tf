################################################################################
#                    Restore Cluster Detection - NEW
#
# Automatically detects RST clusters by name pattern and applies
# cluster-specific RBAC and alert naming
################################################################################

locals {
  # Detect if this is a restore/validation cluster by checking cluster name pattern
  # Pattern: *-rst-* (e.g., dev-rst, sit-rst, uat-rst)
  is_restore_cluster = can(regex(".*-rst-.*", var.bfhaks_instance_cluster_name))
}
