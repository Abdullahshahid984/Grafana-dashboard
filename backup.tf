_auto_gateway_hosts = [
    for k, v in local.workloads_that_target_this_instance :
    "${k}/${k}.${coalesce(local.istio_ingress_subdomain, "skipped-ingress-validation")}"
  ]
