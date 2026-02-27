############################################################
# Trusted Access Binding (Vault -> AKS)
############################################################

resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "aks_trusted_access" {
  for_each = local.backup_instances

  name                  = "backup-${each.key}"
  kubernetes_cluster_id = module.aks_cluster[each.key].id
  roles                 = ["Microsoft.DataProtection/backupVaults/backup-operator"]
  source_resource_id    = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].id
}

############################################################
# Vault MSI -> Reader on AKS Cluster
############################################################

resource "azurerm_role_assignment" "vault_reader_on_cluster" {
  for_each = local.backup_instances

  scope                = module.aks_cluster[each.key].id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

############################################################
# Vault MSI -> Disk Snapshot Contributor (Node RG)
############################################################

resource "azurerm_role_assignment" "vault_snapshot_contributor" {
  for_each = local.backup_instances

  scope                = azurerm_resource_group.snapshot_rg[each.key].id
  role_definition_name = "Disk Snapshot Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

############################################################
# Vault MSI -> Data Operator for Managed Disks (Node RG)
############################################################

resource "azurerm_role_assignment" "vault_data_operator" {
  for_each = local.backup_instances

  scope                = azurerm_resource_group.snapshot_rg[each.key].id
  role_definition_name = "Data Operator for Managed Disks"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

############################################################
# Vault MSI -> Storage Blob Data Contributor
############################################################

resource "azurerm_role_assignment" "vault_blob_data_contributor" {
  for_each = local.backup_instances

  scope                = azurerm_storage_account.storage_account[each.value.storage_account].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

############################################################
# AKS Backup Extension Identity -> Storage Account Contributor
############################################################

resource "azurerm_role_assignment" "extension_storage_contributor" {
  for_each = local.backup_instances

  scope                = azurerm_storage_account.storage_account[each.value.storage_account].id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_kubernetes_cluster_extension.aks_backup[each.key].aks_assigned_identity[0].principal_id
}
