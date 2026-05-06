_auto_gateway_hosts = [
    for k, v in local.workloads_that_target_this_instance :
    "${k}/${k}.${local.istio_ingress_subdomain}"
  ]

  # Custom hosts declared per-workload, filtered to this instance only
  _extra_gateway_hosts = flatten([
    for k, v in local.workloads_that_target_this_instance :
    try(
      [
        for entry in v.istio.extra_gateway_hosts :
        entry.hosts
        if entry.instance == var.bfhaks_instance_name
      ],
      []
    )
  ])
  
  istio_gateway_hosts = concat(local._auto_gateway_hosts, local._extra_gateway_hosts)
