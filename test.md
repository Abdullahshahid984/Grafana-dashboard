Yesterday, while deploying a Storage Account to the ihub-poc-eus2 POC AKS cluster, the Terraform stage completed successfully. However, the cluster deployment failed during the cert-manager installation with the following error:

Error: requested access to the resource is denied  
Error parsing HTTP 401 response body  
script failed with exit code: 125


During the investigation, we identified a cluster-wide ImagePullBackOff issue that has been impacting all pods for approximately 48 days.

Impacted Components

All components pulling images from the private Azure Container Registry (ACR)
acrbfhakshubeus2poc01.azurecr.io are failing, including:

cert-manager (all components)

falcon-system (CrowdStrike)

Wiz connector

Application workloads (e.g., hello-flask)

Any workload requiring images from the private ACR

What Is Working / Already Verified

Kubelet Managed Identity

mi-bfhaks-ihub-kubelet-eus2-poc01 has the AcrPull role assigned on the ACR

AKS Cluster Configuration

The cluster is using the correct kubelet identity

No identity mismatch has been detected

Networking and DNS

ACR resolves correctly via Private DNS
acrbfhakshubeus2poc01.azurecr.io → 10.41.239.58

Network connectivity to the ACR private endpoint is functional

External Registry Access

Pods can successfully pull images from mcr.microsoft.com

Key Observation

Previously, I had access to view and deploy images from the ACR repositories.

Currently, I no longer have permission to view images in the ACR, indicating a potential access control or configuration change.
