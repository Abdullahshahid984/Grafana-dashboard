AKS Backup Cost Summary (Operational vs Vault Tier) – East US 2
1. Operational Tier (Current Estimation)

Configuration:

6 AKS Clusters

46 Namespaces

Backup Policy Type: Operational Tier

Storage Account: Standard GPv2, Hot tier, ZRS, 1 TB

Operations cost for Storage Account: $24.73/month

Cost Breakdown:

Backup Cost: 46 namespaces × $12 = $3,312.00/month

Storage Account Cost: $24.73/month

Total Monthly Cost: $3,336.73

2. Vault Tier (With Retention + Data Churn Considerations)

Configuration:

6 AKS Clusters

46 Namespaces

Backup Policy Type: Vault Tier

Retention: 182 daily backups

Cluster Size: 500 GB

Average Daily Churn: Moderate

Redundancy: ZRS

Storage Account (same 1 TB Hot ZRS): $24.73/month

Cost Breakdown:

Backup Cost: 46 namespaces × $12 = $3,312.00/month

Backup Storage (Standard tier): ~2,652.5 GB per month = $74.27/month

Storage Account Cost: $24.73/month

Total Monthly Cost: $3,386.27

High-Level Comparison
Item	Operational Tier	Vault Tier
Namespace Backup Cost	$3,312.00	$3,312.00
Policy/Storage Cost	$24.73	$24.73
Vault Storage Add-on	–	$74.27
Total Monthly Cost	$3,336.73	$3,386.27
Summary

Operational Tier: ~$3,336.73/month

Vault Tier: ~$3,386.27/month

Difference: Vault Tier is ~$49.54/month more expensive due to additional protected backup data (~2.6 TB/month) created by retention + churn.
