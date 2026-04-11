module "vpc" {
  source = "./modules/vpc"

  aws_region  = var.aws_region
  aws_profile = var.aws_profile

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  availability_zone2  = var.availability_zone2

  common_tags = var.common_tags
}

module "eks-cluster" {
  source                               = "./modules/EKS/cluster"
  eks_cluster_name                     = var.cluster_name
  enable_auto_mode                     = var.enable_auto_mode
  authentication_mode                  = var.authentication_mode
  iam_role_arn                         = module.cluster-iam-role.iam_role_arn
  subnet_id                            = [module.vpc.private_subnet_id, module.vpc.private_subnet_id2]
  cluster_version                      = var.cluster_version
  enable_private_access                = var.enable_private_access
  enable_public_access                 = var.enable_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  nodegroup_iam_arn                    = module.eks-node-group-iam-role.nodegroup_iam_arn
  kms_key_arn                          = var.kms_key_arn

}

module "cluster-iam-role" {
  source       = "./modules/EKS/cluster_iam_role"
  cluster_name = var.cluster_name
}

module "eks-node-group-iam-role" {
  source       = "./modules/EKS/node_iam_role"
  cluster_name = var.cluster_name
}

module "eks-node-group" {
  source                    = "./modules/EKS/node_group"
  enable_auto_mode          = var.enable_auto_mode
  cluster_name              = module.eks-cluster.eks_cluster_name
  iam_role_arn              = module.eks-node-group-iam-role.nodegroup_iam_arn
  subnet_ids                = [module.vpc.private_subnet_id]
  nodegroup_desired_size    = var.nodegroup_desired_size
  nodegroup_max_size        = var.nodegroup_max_size
  nodegroup_min_size        = var.nodegroup_min_size
  node_group_instance_types = var.node_group_instance_types
  node_group_capacity_type  = var.node_group_capacity_type
  node_group_disk_size      = var.node_group_disk_size

}

module "eks-irsa" {
  source                    = "./modules/EKS/IRSA"
  oidc_issuer_url           = module.eks-cluster.eks_oidc_issuer_url
  irsa_role_name            = var.irsa_role_name
  namespace                 = var.namespace
  irsa_service_account_name = var.irsa_service_account_name
  bucket_name               = module.s3-bucket.bucket_name
  cluster_name              = module.eks-cluster.eks_cluster_name
  enable_auto_mode          = var.enable_auto_mode

  depends_on = [module.eks-cluster]
}

module "eks-addons" {
  source                    = "./modules/EKS/addons"
  enable_auto_mode          = var.enable_auto_mode
  cluster_name              = module.eks-cluster.eks_cluster_name
  ebs_sa_role_arn           = module.eks-irsa.ebs_csi_arn
  ebs_csi_policy_attachment = [module.eks-irsa.ebs_csi_policy_attachment]

}

module "eks_access_entries" {
  source                           = "./modules/EKS/eks-access-entries"
  enable_iam_access_entries        = var.enable_iam_access_entries
  create_standard_access_entries   = var.create_standard_access_entries
  enable_auto_mode                 = var.enable_auto_mode
  access_entries                   = var.access_entries
  cluster_name                     = module.eks-cluster.eks_cluster_name
  access_entry_policy_associations = var.access_entry_policy_associations
  node_role_arn                    = module.eks-node-group-iam-role.nodegroup_iam_arn
}

module "s3-bucket" {
  source = "./modules/s3-bucket"

  bucket_name     = var.bucket_name
  vpc_endpoint_id = module.vpc.s3_endpoint_id
}




