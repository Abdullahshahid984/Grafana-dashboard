# FROM:
$cluster_names_json = terraform output -json aks_cluster_names

# TO:
$cluster_names_json = terraform output -json aks_cluster_names_all
