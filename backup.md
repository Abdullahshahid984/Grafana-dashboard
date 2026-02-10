Good question. You’re correct that backup_vault is not referenced by azurerm_kubernetes_cluster_extension, and it is not required for creating the extension itself.

The backup_vault field is used by the Backup Vault resource (azurerm_data_protection_backup_vault) defined in this module and is intentionally part of the shared config. It is included here to keep the configuration consistent and to support the upcoming backup policy and backup instance, which will consume the vault when backups are enabled.

At this stage, the extension and the vault are being provisioned independently as baseline resources.
