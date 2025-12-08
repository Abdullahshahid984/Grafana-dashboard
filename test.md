The api-profile-v1 application running in AKS needs to read/write to Azure Blob Storage as part of its core functionality.
Without appropriate firewall access, the application cannot establish a secure TLS connection to the storage account, causing failures in SIT and will block deployments in other environments as well.
This request ensures reliable connectivity for application functionality and supports ongoing testing, integration, and production rollout.
