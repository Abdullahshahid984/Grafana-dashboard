# Adding this variable for 409 conflict in backup/rst
variable "bfhaks_instance_cluster_name" {
  type        = string
  description = "Name of the AKS cluster (used for unique federated credential naming on restore clusters)"
}
