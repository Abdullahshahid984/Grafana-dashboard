I have already created Terraform code for the following Azure resources:

* AKS Backup Extension
* Azure Storage Account
* Azure Blob Container

Now I need to extend the implementation with **Azure Backup for AKS**.

#### **Requirements**

1. **Terraform – Backup Policy**

   * Create an AKS backup policy using Terraform.
   * Backup frequency: **every 4 hours**.
   * Retention should follow Azure best practices (hourly, daily, and weekly retention where applicable).
   * Policy must be compatible with AKS backup extension.

2. **Terraform – Backup Instance**

   * Create a backup instance that:

     * Protects **all namespaces** in the AKS cluster.
     * Includes **Kubernetes secrets**.
     * Includes all required Kubernetes resources for full cluster recovery (configmaps, persistent volumes if applicable).
   * Ensure the backup instance references:

     * The backup policy
     * Storage account & container
     * AKS cluster resource ID
     * Backup vault

3. **Terraform Parent (Root) Module**

   * Create parent/root Terraform file** that:

     * create the backup policy.tf
     * create the backup instance.tf
     * Passes required variables (AKS cluster ID, vault ID, storage account, environment, location, etc.)
   * Follow Terraform best practices:
     * Clear variable definitions
     * Environment-based naming

4. **Configuration Files**

   * Update the following YAML files specifically for the **dev environment**:

     * `instance_conf.yaml`
     * `conf.yaml`
   * These files should include:

     * Environment: `dev`
     * Backup schedule (4-hour interval)
     * Namespace selector: all namespaces
     * Resource inclusion settings (secrets enabled)
     * Storage container and backup vault references

5. **General Expectations**

   * Use **clean, production-grade Terraform code**.
   * Follow Azure naming conventions.
   * Use variables instead of hardcoded values.
   * Add comments explaining important sections.
   * Assume this will be deployed via CI/CD pipeline.

#### **Deliverables**

* Terraform code for:

  * Backup policy
  * Backup instance
  * Parent/root module
* Updated `instance_conf.yaml` and `conf.yaml` for **dev**
* Brief explanation of how the policy and instance are linked


Just tell me 👍
