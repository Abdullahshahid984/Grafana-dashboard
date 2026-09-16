CODE CHANGES (2 files):
1. Phase 1 outputs.tf - Line 13

value = local.this_instance_cluster_names
2. Phase 2 PowerShell - Line 40

$cluster_names_json = terraform output -json aks_cluster_names_all
