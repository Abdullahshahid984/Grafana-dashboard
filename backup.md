Thanks for calling this out. You’re right that a complete AKS backup setup includes Trusted Access, a backup policy, and a backup instance.

This PR is intentionally scoped to only provision the Backup Vault and install the AKS Backup Extension. At this stage, no backups are being configured or scheduled, so Trusted Access, the backup policy, and the backup instance are not required yet.

Trusted Access is only needed when creating the backup instance, which is when Azure Backup actually begins accessing the cluster. These components will be added in a follow-up PR once the baseline resources are in place.

Regarding the config field, backup_vault is currently forward-looking and is not consumed by azurerm_kubernetes_cluster_extension. It will be used when the backup policy and backup instance are introduced, or can be removed from this PR if preferred.
