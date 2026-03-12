################################################################################
# AKS BACKUP
# Covers: Backup Extension, Backup Vault, Backup Policy, Backup Instance,
#         Snapshot Resource Group, and all required RBAC assignments.
################################################################################


################################################################################
# LOCALS
################################################################################

locals {
  # ---------------------------------------------------------------------------
  # Backup Extension
  # ---------------------------------------------------------------------------
  aks_backup_extension_conf = lookup(local.conf, "aks_backup_extension", [])
  aks_backup_extensions = {
    for backup in local.aks_backup_extension_conf : backup.aks_cluster => backup
  }

  # ---------------------------------------------------------------------------
  # Backup Vault
  # ---------------------------------------------------------------------------
  backup_vault_conf = lookup(local.conf, "backup_vault", [])
  backup_vaults = {
    for backup_vault in local.backup_vault_conf : backup_vault.name => backup_vault
  }

  # ---------------------------------------------------------------------------
  # Backup Policy
  # ---------------------------------------------------------------------------
  backup_policy_conf = lookup(local.conf, "backup_policy", [])
  retention_days     = local.conf.settings.environment == "prd" ? 90 : 7
  backup_policies = {
    for policy in local.backup_policy_conf : policy.backup_vault => {
      vault_name     = policy.backup_vault
      retention_days = local.retention_days
    }
  }

  # ---------------------------------------------------------------------------
  # Backup Instance
  # ---------------------------------------------------------------------------
  backup_instances = {
    for inst in lookup(local.conf, "backup_instance", []) :
    inst.aks_cluster => {
      aks_cluster   = inst.aks_cluster
      backup_policy = inst.backup_policy

      snapshot_rg_name = lookup(
        inst,
        "snapshot_resource_group_name",
        null
      )

      backup_vault = lookup(
        {
          for p in local.backup_policy_conf :
          p.name => p.backup_vault
        },
        inst.backup_policy,
        null
      )

      storage_account = lookup(
        {
          for ext in local.aks_backup_extension_conf :
          ext.aks_cluster => ext.storage_account
        },
        inst.aks_cluster,
        null
      )
    }
  }
}


################################################################################
# BACKUP EXTENSION
################################################################################

resource "azurerm_kubernetes_cluster_extension" "aks_backup" {
  for_each          = local.aks_backup_extensions
  name              = "azure-aks-backup"
  cluster_id        = module.aks_cluster[each.value.aks_cluster].id
  extension_type    = "microsoft.dataprotection.kubernetes"
  release_train     = "stable"
  release_namespace = "dataprotection-microsoft"

  configuration_settings = {
    "configuration.backupStorageLocation.bucket"                = each.value.storage_container
    "configuration.backupStorageLocation.config.resourceGroup"  = local.conf.settings.resource_group_name
    "configuration.backupStorageLocation.config.storageAccount" = each.value.storage_account
    "configuration.backupStorageLocation.config.subscriptionId" = local.conf.settings.subscription_id
    "credentials.tenantId"                                      = local.conf.settings.tenant_id
  }

  depends_on = [
    module.aks_cluster,
    azurerm_storage_account.storage_account,
    azurerm_storage_container.storage_container,
  ]
}


################################################################################
# BACKUP VAULT
################################################################################

resource "azurerm_data_protection_backup_vault" "backup_vault" {
  for_each            = local.backup_vaults
  name                = each.value.name
  resource_group_name = local.conf.settings.resource_group_name
  location            = local.conf.settings.location
  datastore_type      = "VaultStore"
  redundancy          = "ZoneRedundant"
  soft_delete         = "AlwaysOn"
  immutability        = "Locked"

  identity {
    type = "SystemAssigned"
  }

  tags = merge(
    local.common_tags,
    {
      Role = "BFH AKS Platform: Backup Vault"
    }
  )
}


################################################################################
# BACKUP POLICY
################################################################################

resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "aks_policy" {
  for_each = local.backup_policies

  name                = "aks-4hour-policy"
  resource_group_name = local.conf.settings.resource_group_name
  vault_name          = each.value.vault_name
  time_zone           = "UTC"

  # Every 4 hours
  backup_repeating_time_intervals = ["R/2026-01-01T00:00:00+00:00/PT4H"]

  default_retention_rule {
    life_cycle {
      duration        = "P${each.value.retention_days}D"
      data_store_type = "OperationalStore"
    }
  }
}


################################################################################
# SNAPSHOT RESOURCE GROUP
################################################################################

resource "azurerm_resource_group" "snapshot_rg" {
  for_each = {
    for k, v in local.backup_instances : k => v
    if v.snapshot_rg_name != null
  }

  name     = each.value.snapshot_rg_name
  location = local.conf.settings.location
}


################################################################################
# BACKUP INSTANCE
################################################################################

resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "aks_backup_instance" {
  for_each = local.backup_instances

  name                         = "bi-${each.key}"
  location                     = local.conf.settings.location
  vault_id                     = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].id
  kubernetes_cluster_id        = module.aks_cluster[each.key].id
  snapshot_resource_group_name = azurerm_resource_group.snapshot_rg[each.key].name
  backup_policy_id             = azurerm_data_protection_backup_policy_kubernetes_cluster.aks_policy[each.value.backup_vault].id

  backup_datasource_parameters {
    cluster_scoped_resources_enabled = true
    volume_snapshot_enabled          = true
    included_namespaces              = []
    excluded_namespaces              = []
    included_resource_types          = []
    excluded_resource_types          = []
    label_selectors                  = []
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.aks_backup,
  ]
}


################################################################################
# RBAC - TRUSTED ACCESS BINDING (Vault -> AKS)
################################################################################

resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "aks_trusted_access" {
  for_each = local.backup_instances

  name                  = "backup-${each.key}"
  kubernetes_cluster_id = module.aks_cluster[each.key].id
  roles                 = ["Microsoft.DataProtection/backupVaults/backup-operator"]
  source_resource_id    = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].id
}


################################################################################
# RBAC - VAULT MSI ROLE ASSIGNMENTS
################################################################################

# Reader on AKS cluster
resource "azurerm_role_assignment" "vault_reader_on_cluster" {
  for_each = local.backup_instances

  scope                = module.aks_cluster[each.key].id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

# Disk Snapshot Contributor on snapshot resource group
resource "azurerm_role_assignment" "vault_snapshot_contributor" {
  for_each = local.backup_instances

  scope                = azurerm_resource_group.snapshot_rg[each.key].id
  role_definition_name = "Disk Snapshot Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

# Data Operator for Managed Disks on snapshot resource group
resource "azurerm_role_assignment" "vault_data_operator" {
  for_each = local.backup_instances

  scope                = azurerm_resource_group.snapshot_rg[each.key].id
  role_definition_name = "Data Operator for Managed Disks"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

# Storage Blob Data Contributor on storage account
resource "azurerm_role_assignment" "vault_blob_data_contributor" {
  for_each = local.backup_instances

  scope                = azurerm_storage_account.storage_account[each.value.storage_account].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}


################################################################################
# RBAC - BACKUP EXTENSION IDENTITY ROLE ASSIGNMENTS
################################################################################

# Storage Account Contributor on storage account
resource "azurerm_role_assignment" "extension_storage_contributor" {
  for_each = local.backup_instances

  scope                = azurerm_storage_account.storage_account[each.value.storage_account].id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_kubernetes_cluster_extension.aks_backup[each.key].aks_assigned_identity[0].principal_id
}
