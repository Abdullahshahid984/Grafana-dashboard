locals {
  aks_backup_rbac_conf = lookup(local.conf, "aks_backup_rbac", {})
  
  # Determine if RBAC should be configured
  configure_backup_rbac = lookup(local.aks_backup_rbac_conf, "enabled", true)
  
  # Build a map of backup instances with their associated storage account for easy lookup
  backup_instance_storage_map = {
    for instance in local.aks_backup_instance_conf : instance.aks_cluster => {
      storage_account = instance.storage_account
      backup_vault    = instance.backup_vault
    }
  }
}

# ==================================================================================
# 1. TRUSTED ACCESS BINDING - Backup Vault to AKS Cluster
# ==================================================================================
# Allows the Backup Vault to operate on the AKS cluster without explicit role assignments
# Grant: Backup Vault -> AKS Cluster
# Role: Microsoft.DataProtection/backupVaults/backup-operator

resource "azurerm_role_assignment" "backup_vault_to_aks_backup_operator" {
  for_each = local.configure_backup_rbac ? local.aks_backup_instances : {}

  scope              = module.aks_cluster[each.value.aks_cluster].id
  role_definition_name = "Kubernetes Cluster - Azure Backup Operator"
  principal_id       = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.backup_vault,
    module.aks_cluster
  ]
}

# ==================================================================================
# 2. AKS BACKUP EXTENSION PERMISSIONS
# ==================================================================================
# Grant the AKS Backup Extension identity permissions to write to storage account

resource "azurerm_role_assignment" "backup_extension_storage_account_contributor" {
  for_each = local.configure_backup_rbac ? local.aks_backup_extensions : {}

  scope              = azurerm_storage_account.storage_account[each.value.storage_account].id
  role_definition_name = "Storage Account Contributor"
  principal_id       = azurerm_kubernetes_cluster_extension.aks_backup[each.key].identity[0].principal_id

  depends_on = [
    azurerm_kubernetes_cluster_extension.aks_backup,
    azurerm_storage_account.storage_account
  ]
}

# ==================================================================================
# 3. BACKUP VAULT MANAGED IDENTITY PERMISSIONS
# ==================================================================================

# 3.1 Reader role on AKS Cluster
# Allows the Backup Vault to read cluster metadata
resource "azurerm_role_assignment" "backup_vault_aks_reader" {
  for_each = local.configure_backup_rbac ? local.aks_backup_instances : {}

  scope              = module.aks_cluster[each.value.aks_cluster].id
  role_definition_name = "Reader"
  principal_id       = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.backup_vault,
    module.aks_cluster
  ]
}

# 3.2 Reader role on Snapshot Resource Group
# Allows the Backup Vault to read snapshot resource group
resource "azurerm_role_assignment" "backup_vault_snapshot_rg_reader" {
  for_each = local.configure_backup_rbac ? local.aks_backup_instances : {}

  scope              = "/subscriptions/${local.conf.settings.subscription_id}/resourceGroups/${each.value.snapshot_resource_group_name}"
  role_definition_name = "Reader"
  principal_id       = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.backup_vault
  ]
}

# 3.3 Disk Snapshot Contributor role on Snapshot Resource Group
# Allows the Backup Vault to create and manage disk snapshots
resource "azurerm_role_assignment" "backup_vault_snapshot_contributor" {
  for_each = local.configure_backup_rbac ? local.aks_backup_instances : {}

  scope              = "/subscriptions/${local.conf.settings.subscription_id}/resourceGroups/${each.value.snapshot_resource_group_name}"
  role_definition_name = "Disk Snapshot Contributor"
  principal_id       = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.backup_vault
  ]
}

# 3.4 Data Operator for Managed Disks role on Snapshot Resource Group
# Allows the Backup Vault to operate on managed disks during snapshot operations
resource "azurerm_role_assignment" "backup_vault_disk_operator" {
  for_each = local.configure_backup_rbac ? local.aks_backup_instances : {}

  scope              = "/subscriptions/${local.conf.settings.subscription_id}/resourceGroups/${each.value.snapshot_resource_group_name}"
  role_definition_name = "Data Operator for Managed Disks"
  principal_id       = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.backup_vault
  ]
}

# 3.5 Storage Blob Data Contributor role on Storage Account
# Allows the Backup Vault to write backup data to blob storage
resource "azurerm_role_assignment" "backup_vault_storage_blob_contributor" {
  for_each = local.configure_backup_rbac ? local.aks_backup_instances : {}

  scope              = azurerm_storage_account.storage_account[local.backup_instance_storage_map[each.value.aks_cluster].storage_account].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id       = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id

  depends_on = [
    azurerm_data_protection_backup_vault.backup_vault,
    azurerm_storage_account.storage_account
  ]
}

# ==================================================================================
# 4. AKS CLUSTER MANAGED IDENTITY PERMISSIONS
# ==================================================================================
# Grant the AKS Cluster managed identity permissions to manage snapshot lifecycle

resource "azurerm_role_assignment" "aks_cluster_snapshot_rg_contributor" {
  for_each = local.configure_backup_rbac ? local.aks_backup_instances : {}

  scope              = "/subscriptions/${local.conf.settings.subscription_id}/resourceGroups/${each.value.snapshot_resource_group_name}"
  role_definition_name = "Contributor"
  principal_id       = module.aks_cluster[each.value.aks_cluster].kubelet_identity[0].object_id

  depends_on = [
    module.aks_cluster
  ]
}
