FILE 4: kubernetes-resources/main.tf
Line 40 - CHANGE:

# FROM: for_each = local.app_team_principals_for_this_instance
# TO:
  for_each = local.app_team_principals_final
Line 50 - CHANGE:

# FROM: for_each = local.app_team_principal_all_namespace_for_this_instance
# TO:
  for_each = local.app_team_principal_all_namespace_final
Line 60 - CHANGE:

# FROM: for_each = local.devops_pipeline_credentials_for_this_instance[local.matching_platform_instance_data.devops_pipeline_credential.type]
# TO:
  for_each = local.devops_pipeline_credentials_final[local.matching_platform_instance_data.devops_pipeline_credential.type]
