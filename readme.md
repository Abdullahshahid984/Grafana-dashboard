---

# **Step-by-Step: How to Implement AKS Backup in AKS**

---

# **1. Prerequisites**

1. Have an existing AKS Cluster.
2. Ensure you have **Owner** or **Contributor** permissions.
3. Register these providers (if not already contect cloud team):

```
Microsoft.ContainerService
Microsoft.DataProtection
```

---

# **2. Create a Backup Vault**

1. Go to **Azure Portal**
2. Search **“Backup Vault”**
3. Click **Create**
4. Choose:

   * Subscription
   * Resource Group
   * Vault Name
   * Region (eastus2 or cus)
5. Click **Review + Create → Create**

---

# **3. Enable Backup on AKS Cluster**

1. Open your **AKS cluster** in Azure Portal.
2. Go to **Backup (preview)** tab.
3. Click **Enable Backup**
4. Select the **Backup Vault** you created.
5. Choose **Backup Policy** (or create a new one).
6. Select which **namespaces** to protect:

   * All namespaces
   * Selected namespaces
   * Label selector
7. Click on create button

---

# **4. Create a Backup Policy (If not created earlier)**

1. In the **Backup Vault**, open **Backup Policies**
2. Create new policy:

   * Choose **Backup every 4H / 6H / 12H / Daily**
   * Choose **Retention** (days/weeks/months)
   * Select:

     * Snapshot backup
     * Vault backup (recommended)
3. Save policy.

---

# **5. Verify Backup Extension Installed**

Azure automatically deploys it.

To verify:

```
kubectl get pods -n <backupnamespace> 
```

You should see pods like:

```
dataprotection-microsoft-dpp-backup-agent
dataprotection-microsoft-dpp-data-mover
```

---

# **6. Run First Manual Backup**

1. Go to **Backup Vault**
2. Click **Backup Instances**
3. Select your AKS cluster instance
4. Click **Backup Now**
5. Monitor job under:

   * **Backup Jobs** inside Backup Vault
   * **Backup Center**

---

# **7. Schedule Automatic Backups**

If not set during enablement:

1. Go to **Backup Vault**
2. Open your **Backup Policy**
3. Attach policy to AKS Backup Instance.

---

# **8. Restore (Basic Steps)**

To restore:

1. Go to **Backup Vault**
2. Click **Backup Instances**
3. Select your AKS cluster backup
4. Click **Restore**
5. Choose restore type:

   * Namespace restore
   * Full cluster restore
   * Resources by label
   * PVC only
6. Select restore target:

   * Same AKS cluster
   * Another AKS cluster
7. Select:

   * Same namespace
   * New namespace
8. Choose conflict behavior (Skip / Overwrite)
9. Click **Restore**

---

# **9. Validate Restore**

After restore:

```
kubectl get pods -n <restored-namespace>
kubectl get pvc -n <restored-namespace>
kubectl get deploy -n <restored-namespace>
```

Confirm all objects and data are restored.

---

# **10. Monitor Backups & Compliance**

Use **Backup Center**:

1. Search **Backup Center** in Azure Portal.
2. View:

   * Backup success/failure
   * Non-protected namespaces
   * Alerts
   * Job details


