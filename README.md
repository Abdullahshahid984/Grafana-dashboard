# **AKS Backup – Deep Technical Overview**

This document explains **Azure AKS Backup** — what it does, why it matters, how it works internally, and why Kubernetes requires a dedicated backup strategy beyond GitOps, YAMLs, or pipelines.

Most engineers assume “containers are stateless,” but modern Kubernetes clusters have become **highly stateful**. As a result, backing up runtime state, configuration, and storage is now essential.

---

# **1. Why Back Up Kubernetes Workloads?**

## **1.1 Stateful Workloads Are Increasing in AKS**

AKS now hosts mission-critical applications that rely heavily on persistent data.

### **Databases & Storage**

* PostgreSQL
* MySQL
* MongoDB
* ElasticSearch
* Redis (persistent mode)

These run as **StatefulSets** backed by **PVCs**.

### **Message Queues**

* RabbitMQ
* Kafka
* NATS

These require strict state consistency.

### **Persistent Volumes**

PVCs backed by:

* Azure Managed Disks
* Azure Files
* Azure Premium/Ultra Disks

### **Operators & CRDs**

Applications often ship CRDs + controllers.
If removed, the application may break **even if YAML exists**.

### **Cluster Configuration**

Stored inside the cluster, NOT Git:

* ConfigMaps
* Secrets
* RBAC
* ServiceAccounts
* NetworkPolicies
* Ingress rules
* Helm metadata

### **Conclusion**

Even if the *container image* is stateless, the **cluster itself becomes stateful**.

YAML + GitOps ≠ Full Recovery.

---

## **1.2 Even “Stateless” Apps Drift from Git**

Real-world engineering introduces **configuration drift**:

* `kubectl edit` quick fixes
* Manual secret rotation
* Live ConfigMap changes
* Accidental namespace deletion
* CronJobs mutating resources
* Partial Helm deployments
* Broken pipelines
* Operators modifying resources at runtime

If you restore from Git alone:

You won’t get the exact working cluster state back.
Secrets, PV data, CRDs, runtime mutations are lost.

**AKS Backup solves this gap.**

---

## **1.3 GitOps = Seatbelt, Backup = Airbag**

GitOps keeps desired state aligned.
But it cannot protect you from:

* Bad rollouts
* Faulty commits
* Namespace deletion
* Corrupted PVs
* RBAC changes
* Ransomware

Backups = **airbags when disasters happen**.

---

# **2. How AKS Backup Works Internally**

AKS Backup has two components:

1. **AKS Backup Extension** (in-cluster)
2. **Backup Vault** (control plane)

They work together to detect resources, snapshot volumes, and manage restore workflows.

---

## **2.1 AKS Backup Extension (In-Cluster Engine)**

Installed inside the AKS cluster under:

```
data-protection-microsoft
```

### **Responsibilities**

* Reads resources via Kubernetes API
* Discovers namespaces, PVCs, CRDs
* Takes volume snapshots
* Applies backup policies
* Runs backup/restore hooks
* Sends metadata to the vault

The extension is **lightweight**, impacting performance only during snapshot operations.

---

## **2.2 Azure Portal Integration**

AKS now has a **native Backup tab**:

* Enable backup with one click
* Define schedules
* Trigger restores
* Full visualization — no CLI required

Azure now treats Kubernetes as a first-class backup workload.

---

# **3. Backup Vault — The Control Plane**

The Backup Vault manages:

* Schedules
* Retention
* Snapshot lifecycle
* Metadata catalog
* Restore orchestration
* Encryption & security
* Compliance reports

Supports:
Public AKS
Private AKS
Restrictive outbound IP clusters

---

# **4. Backup Policies**

### **Backup Frequency**

Common options based on RPO:

* Every 4 hours (production)
* Every 6–12 hours
* Daily (non-critical)

### **Retention**

* Snapshots: 2–7 days
* Vault copies: 30–120 days
* Long-term retention for compliance

Azure automatically enforces cleanup.

---

# **5. Storage Options: Snapshot vs Vault**

## **5.1 Snapshot Backup (Local Subscription)**

✔ Fast
✔ Cheap
✔ Perfect for short-term recovery

But:
❌ Can be deleted if subscription is compromised
❌ Not ransomware-protected
❌ No tenant-level isolation

---

## **5.2 Vault Backup (Offsite, Isolated)**

Stored in a **Microsoft-owned tenant**:

* Immutable
* Ransomware-resistant
* Survives subscription deletion
* True offsite protection

Equivalent to enterprise-grade DR.

---

# **6. Selective & Granular Protection**

You can protect:

* Entire clusters
* Specific namespaces
* Specific resource types
* Label-based selections
* PVCs
* Secrets
* CRDs
* Cluster-wide resources

Perfect for multi-team shared clusters.

---

## **6.1 Auto-Protect Future Namespaces**

Enable once → all future namespaces are automatically backed up.

---

# **7. Backup Hooks (Application-Consistent Backups)**

Two modes:

* Crash-consistent
* Application-consistent

Databases require **application-consistent** backups.

### Example (PostgreSQL):

1. Run freeze command
2. Take snapshot
3. Unfreeze

Ensures **no corrupted DB data** after restore.

---

# **8. Restore Scenarios**

Supports restore across:

* Same cluster
* Different cluster
* Different subscription
* Compatible Kubernetes versions
* Dev → Test → Prod migrations

---

## **8.1 Granular Restore**

Restore:

* Entire namespace
* Single deployment
* Single pod
* ConfigMaps
* Secrets
* PVCs
* CRDs
* Label-selected items

---

## **8.2 Restore Into a New Namespace**

Example:

```
ecommerce  →  shopping-cart
```

Restore directly without rewriting YAML or Helm values.

---

## **8.3 Conflict Handling**

* **Skip** existing resources
* **Override** with backup version

---

## **8.4 Restore Hooks**

Automate:

* Validation
* Migrations
* Service restarts
* Post-restore checks

---

# **9. Pre-Restore Validation**

Azure checks:

* AKS version compatibility
* RBAC permissions
* Resource groups
* Storage classes
* PV availability
* Conflicts

Prevents most restore failures before they occur.

---

# **10. Backup Center — Centralized View**

Provides full enterprise visibility:

* Protection status
* Non-protected clusters
* Policy compliance
* Failures & alerts
* Storage usage
* Historical logs
* Multi-region monitoring

---

# **11. What This Means for Our Team**

## **Operational**

* Fast restore from accidental deletions
* Partial or full rollbacks
* Easy migrations
* Reduced MTTR

## **Security**

* Ransomware-resistant backups
* Offsite immutable copies
* Protection against insider threats
* Secrets backup

## **DevOps & SRE**

* Guaranteed reproducible state
* Reliable rollbacks
* Full cluster reconstruction

## **Architecture**

* Ideal for multi-team clusters
* Database consistency support
* Auto-scalable with application growth

---

# **Final Summary — Why AKS Backup Matters**

AKS Backup answers the key production question:

> **“Can we restore EXACTLY what was running — including data, secrets, CRDs, and configuration?”**

With AKS Backup, we gain:

* Reliability
* Full cluster state protection
* Ransomware safety
* DR readiness
* Cross-cluster portability
* Granular restores
* Compliance support

**GitOps = Desired State
AKS Backup = Actual State**

Together, they form a complete safety and recovery strategy.


Just tell me!
