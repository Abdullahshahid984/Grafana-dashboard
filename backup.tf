  # Pass excluded cluster names to skip Prometheus alert rule group creation
  # for restore/validation clusters. Hardcoded in locals.tf.
  # Zero impact when list is empty [].
  excluded_cluster_names = local.excluded_cluster_names
