################################################################################
# AKS BACKUP
# Covers: Backup Extension, Backup Vault, Backup Policy, Backup Instance,
#         Snapshot Resource Group, and all required RBAC assignments.
################################################################################

################################################################################
# DATA SOURCES
################################################################################

# Dedicated snapshot resource group, created only when its name is set in conf.yaml
resource "azurerm_resource_group" "snapshot_rg" {
  count    = lookup(local.conf.settings, "backup_snapshot_resource_group_name", null) == null ? 0 : 1
  name     = local.conf.settings.backup_snapshot_resource_group_name
  location = local.conf.settings.location

  tags = merge(
    local.common_tags,
    {
      Role = "BFH AKS Platform: Backup Snapshot Resource Group"
    }
  )
}

# Resolves to the dedicated group when set, otherwise to the cluster resource group (as before)
data "azurerm_resource_group" "snapshot_rg" {
  name = lookup(local.conf.settings, "backup_snapshot_resource_group_name", local.conf.settings.resource_group_name)

  depends_on = [azurerm_resource_group.snapshot_rg]
}

data "azurerm_user_assigned_identity" "cluster_identity" {
  for_each = local.backup_instances

  name                = [
    for c in local.aks_clusters_conf :
    c.identity.identity_ids[0].ref
    if c.name == each.key
  ][0]
  resource_group_name = local.conf.settings.resource_group_name
}

################################################################################
# LOCALS
################################################################################

locals {
    
  # ---------------------------------------------------------------------------
  # STORAGE ACCOUNT
  # ---------------------------------------------------------------------------
  storage_account_conf = lookup(local.conf, "storage_account", [])
  storage_accounts = {
    for storage_account in local.storage_account_conf : storage_account.name => storage_account
  }

  # ---------------------------------------------------------------------------
  # STORAGE CONTAINER
  # ---------------------------------------------------------------------------
  storage_accounts_with_containers = {
   for sa_name, sa_config in local.storage_accounts :
   sa_name => sa_config
   if lookup(sa_config, "container", null) != null
  } 

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
  retention_days     = local.conf.settings.environment == "prd" ? 14 : 7
  backup_policies = {
    for policy in local.backup_policy_conf : policy.name => {
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
# Storgage Account
################################################################################
resource "azurerm_storage_account" "storage_account" {
  for_each            = local.storage_accounts
  resource_group_name = local.conf.settings.resource_group_name
  location            = local.conf.settings.location
  name                = each.value.name

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  access_tier              = "Cool"

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  shared_access_key_enabled       = true
  is_hns_enabled                  = false
  allowed_copy_scope              = "AAD"

  routing {
    publish_internet_endpoints  = false
    publish_microsoft_endpoints = false
    choice                      = "MicrosoftRouting"
  }

  blob_properties {
    versioning_enabled       = true
    change_feed_enabled      = true
    last_access_time_enabled = false

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  tags = merge(
    local.common_tags,
    {
      Role = "BFH AKS Platform: Storage Account - Archive and Backup"
    }
  )
}


################################################################################
# STORAGE CONTAINER
################################################################################

# Blob Container for Storage Account
resource "azurerm_storage_container" "storage_container" {
  for_each              = local.storage_accounts_with_containers
  name                  = each.value.container
  storage_account_id    = azurerm_storage_account.storage_account[each.key].id
  container_access_type = "private"
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
# BACKUP VAULT LOCK
################################################################################

resource "azurerm_management_lock" "backup_vault_lock" {
  for_each = azurerm_data_protection_backup_vault.backup_vault

  name       = "lock-${each.key}"
  scope      = each.value.id
  lock_level = "CanNotDelete"
  notes      = "Backup vault lock — deletion requires explicit lock removal."
}

################################################################################
# BACKUP POLICY
################################################################################

resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "aks_policy" {
  for_each = local.backup_policies

  name                = "bp-${each.key}"
  resource_group_name = local.conf.settings.resource_group_name
  vault_name          = azurerm_data_protection_backup_vault.backup_vault[each.value.vault_name].name
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
# BACKUP INSTANCE
################################################################################

# The previous instance (aks_backup_instance) lives in an immutable vault and cannot be
# deleted until its recovery points expire. Terraform forgets it without deleting it.
removed {
  from = azurerm_data_protection_backup_instance_kubernetes_cluster.aks_backup_instance

  lifecycle {
    destroy = false
  }
}

resource "azurerm_data_protection_backup_instance_kubernetes_cluster" "aks_backup_instance_v2" {
  for_each = local.backup_instances

  name                         = "bi-${each.key}-snap"
  location                     = local.conf.settings.location
  vault_id                     = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].id
  kubernetes_cluster_id        = module.aks_cluster[each.key].id
  snapshot_resource_group_name = data.azurerm_resource_group.snapshot_rg.name
  backup_policy_id             = azurerm_data_protection_backup_policy_kubernetes_cluster.aks_policy[each.value.backup_policy].id

  backup_datasource_parameters {
    cluster_scoped_resources_enabled = true
    included_namespaces              = []
    excluded_namespaces              = []
    included_resource_types          = []
    excluded_resource_types          = []
    label_selectors                  = []
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.aks_backup,
    azurerm_role_assignment.vault_snapshot_contributor,
    azurerm_role_assignment.vault_data_operator,
    azurerm_role_assignment.vault_reader_on_snapshot_rg,
    azurerm_role_assignment.cluster_contributor_on_snap_rg,
  ]
}


################################################################################
# RBAC - TRUSTED ACCESS BINDING (Vault -> AKS)
################################################################################

resource "azurerm_kubernetes_cluster_trusted_access_role_binding" "aks_trusted_access" {
  for_each = local.backup_instances

  name                  = "tarb-${element(split("-", each.key), 1)}-${element(split("-", each.key), 3)}-${element(split("-", each.key), 4)}"
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

# Storage Blob Data Contributor on storage account
resource "azurerm_role_assignment" "vault_blob_data_contributor" {
  for_each = local.backup_instances

  scope                = azurerm_storage_account.storage_account[each.value.storage_account].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

# Disk Snapshot Contributor on snapshot resource group
resource "azurerm_role_assignment" "vault_snapshot_contributor" {
  for_each = local.backup_instances

  scope                = data.azurerm_resource_group.snapshot_rg.id
  role_definition_name = "Disk Snapshot Contributor"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

# Data Operator for Managed Disks on snapshot resource group
resource "azurerm_role_assignment" "vault_data_operator" {
  for_each = local.backup_instances

  scope                = data.azurerm_resource_group.snapshot_rg.id
  role_definition_name = "Data Operator for Managed Disks"
  principal_id         = azurerm_data_protection_backup_vault.backup_vault[each.value.backup_vault].identity[0].principal_id
}

# Reader on snapshot RG — required by Backup Vault managed identity
resource "azurerm_role_assignment" "vault_reader_on_snapshot_rg" {
  for_each = local.backup_instances

  scope                = data.azurerm_resource_group.snapshot_rg.id
  role_definition_name = "Reader"
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

################################################################################
# RBAC - AKS CLUSTER IDENTITY ROLE ASSIGNMENTS
################################################################################

resource "azurerm_role_assignment" "cluster_contributor_on_snap_rg" {
  for_each = local.backup_instances

  scope                = data.azurerm_resource_group.snapshot_rg.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_user_assigned_identity.cluster_identity[each.key].principal_id
}
