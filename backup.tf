        # Skip clusters in excluded_cluster_names list.
        # Used to prevent Prometheus alert rule group creation for
        # restore/validation clusters where Azure Backup has already
        # restored the same rule groups causing "resource already exists" conflict.
        # Zero impact when excluded_cluster_names is empty [].
        if !contains(var.excluded_cluster_names, cluster.name)
