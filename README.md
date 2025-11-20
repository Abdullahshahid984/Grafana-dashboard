AKS Backup Pricing Analysis – Operational Tier vs Vault Tier (East US 2)

This document summarizes the estimated monthly cost of Azure AKS Backup using both Operational Tier and Vault Tier configurations.

---

## 1. Operational Tier – Cost Summary

### Configuration

* Backup Policy Type: Operational Tier
* 6 AKS Clusters
* 46 Namespaces
* Storage: Standard GPv2, Hot Tier, ZRS
* Storage operations + capacity: $24.73/month

### Cost Breakdown

| Component                           | Monthly Cost |
| ----------------------------------- | ------------ |
| Namespace Backup (46 × $12)         | $3,312.00    |
| Storage Account (1 TB + operations) | $24.73       |
| Total Monthly Cost                  | $3,336.73    |

---

## 2. Vault Tier – Cost Summary

### Configuration

* Backup Policy Type: Vault Tier
* Retention: 182 daily backups
* Cluster Size: 500 GB
* Daily Data Churn: Moderate
* Redundancy: ZRS
* Storage Account: $24.73/month

### Cost Breakdown

| Component                                 | Monthly Cost |
| ----------------------------------------- | ------------ |
| Namespace Backup (46 × $12)               | $3,312.00    |
| Backup Storage (approx. 2,652.5 GB/month) | $74.27       |
| Storage Account (1 TB + operations)       | $24.73       |
| Total Monthly Cost                        | $3,386.27    |

---

## 3. Comparison Summary

| Aspect                    | Operational Tier | Vault Tier |
| ------------------------- | ---------------- | ---------- |
| Namespace Backup          | $3,312.00        | $3,312.00  |
| Additional Backup Storage | $0.00            | $74.27     |
| Storage Account Cost      | $24.73           | $24.73     |
| Total Monthly Cost        | $3,336.73        | $3,386.27  |

---

## Difference

Vault Tier is approximately **$49.54/month** more expensive due to additional retained backup data (around 2.6 TB per month).

