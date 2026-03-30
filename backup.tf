################################################################################
# BACKUP VAULT LOCK
################################################################################

resource "azurerm_management_lock" "backup_vault_lock" {
  for_each = azurerm_data_protection_backup_vault.backup_vault

  name       = "lock-${each.key}"
  scope      = each.value.id
  lock_level = "CanNotDelete"
  notes      = "Backup vault lock — deletion requires explicit lock removal."
}
