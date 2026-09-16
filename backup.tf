**Replace the entire `aks_clusters` block (lines 23-29) with:**

```hcl
locals {
  # ALL clusters - used for Phase 2
  aks_clusters_all = [
    for k, v in data.azurerm_kubernetes_cluster.aks : {
      name = v.name
      id   = v.id
    }
  ]

  # Filtered - without RST - used for Phase 1 alerts
  aks_clusters = [
    for cluster in local.aks_clusters_all :
    cluster if !can(regex(".*-rst-.*", cluster.name))
  ]
}
```

**In outputs.tf, use:**
```hcl
value = [for cluster in local.aks_clusters_all : cluster.name]
```


Understand?
