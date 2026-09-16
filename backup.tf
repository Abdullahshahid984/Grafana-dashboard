  additional_cluster_oidc_issuer_urls = {
    for k, v in data.azurerm_kubernetes_cluster.additional_clusters : k => v.oidc_issuer_url
  }
