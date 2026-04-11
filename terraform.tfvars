aws_region  = "ap-south-1"
aws_profile = "herovired"

project_name         = "jhakkas"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidr   = "10.0.1.0/24"
private_subnet_cidr  = "10.0.2.0/24"
private_subnet_cidr2 = "10.0.3.0/24"
availability_zone    = "ap-south-1a"
availability_zone2   = "ap-south-1b"

common_tags = {
  Project     = "Jhakkas"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "Vikram Hem Chandar"
}

cluster_name = "jhakkas-cluster"
# iam_role_name                        = "cluster_iam_role"
enable_auto_mode                     = false
authentication_mode                  = "API_AND_CONFIG_MAP"
cluster_version                      = "1.34"
enable_private_access                = true
enable_public_access                 = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
kms_key_arn                          = ""
nodegroup_desired_size               = 3
nodegroup_max_size                   = 4
nodegroup_min_size                   = 2
node_group_instance_types            = ["t3.medium"]
node_group_capacity_type             = "ON_DEMAND"
node_group_disk_size                 = 20
irsa_role_name                       = "custom-sa-irsa-role"
namespace                            = "default"
irsa_service_account_name            = "custom-sa-account"
bucket_name                          = "jhakkas-s3-bucket"
enable_iam_access_entries            = true
create_standard_access_entries       = true

# access_entries = {
#   "arn:aws:iam::975050024946:user/vikramhemchandar@gmail.com" = {
#     kubernetes_groups = ["system:masters"]
#     type              = "STANDARD"
#   }

#   "arn:aws:iam::975050024946:role/dev-role" = {
#     kubernetes_groups = ["developers"]
#   }
# }

# access_entry_policy_associations = {
#   "admin-access" = {
#     principal_arn = "arn:aws:iam::975050024946:user/vikramhemchandar@gmail.com"
#     policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

#     access_scope = {
#       type = "cluster"
#     }
#   }
# }
