locals {
  federated_credential_subject = { for k, v in local.computed_component_map : k =>
    join(":", [
      "system",
      "serviceaccount",
      kubernetes_namespace_v1.ns.metadata.0.name,
      kubernetes_service_account_v1.workload_identity[k].metadata.0.name
    ])
    if v.workload_identity == true
  }
}
