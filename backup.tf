# Pass additional cluster OIDC issuer URLs as a map (cluster key => oidc url).
  # The kubernetes_resources module uses this to create federated credentials
  # for each workload component on each additional cluster.
  # Empty map {} when no additional clusters are defined — zero impact.
  additional_cluster_oidc_issuer_urls = {
    for k, v in data.azurerm_kubernetes_cluster.additional_clusters : k => v.oidc_issuer_url
  }
