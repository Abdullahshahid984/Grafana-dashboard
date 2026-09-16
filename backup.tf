locals {
  # Federated credential subject with cluster-specific suffix for RST clusters
  # Prevents Azure Workload Identity "subject already exists" (409) conflicts
  # when both primary and restore clusters use same managed identity
  #
  # Original dev: system:serviceaccount:api-pricing-v1:sa-api-pricing-v1
  # RST dev-rst:  system:serviceaccount:api-pricing-v1:sa-api-pricing-v1-aks-bfhaks-ihub-eus2-dev-rst-01
  #
  federated_credential_subject = { for k, v in local.computed_component_map : k =>
    var.is_restore_cluster ?
      join(":", [
        "system",
        "serviceaccount",
        kubernetes_namespace_v1.ns.metadata.0.name,
        "${kubernetes_service_account_v1.workload_identity[k].metadata.0.name}-${var.bfhaks_instance_cluster_name}"
      ])
    :
      join(":", [
        "system",
        "serviceaccount",
        kubernetes_namespace_v1.ns.metadata.0.name,
        kubernetes_service_account_v1.workload_identity[k].metadata.0.name
      ])
    if v.workload_identity == true
  }
}
