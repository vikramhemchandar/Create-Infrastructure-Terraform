module "vpc" {
  source = "./modules/vpc"

  aws_region  = var.aws_region
  #aws_profile = var.aws_profile

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone

  common_tags = var.common_tags
}

module "eks-cluster"{
    source = "./modules/EKS/cluster"
    eks_cluster_name = var.cluster_name
    iam_role_arn = module.cluster-iam-role.output.iam_role_arn
    subnet_id = module.vpc.private_subnet_id
}

module "cluster-iam-role"{
    source = "./modules/EKS/cluster_iam_role"
    iam_role_name = var.iam_role_name
}

module "eks-node-group-iam-role" {
  source = "./modules/EKS/node_iam_role"
  nodegroup_iam_role = var.nodegroup_iam_role
}

module "eks-node-group" {
  source = "./modules/EKS/node_group"
  cluster_name = module.eks-cluster.eks_cluster_name
  node_group_name = var.eks_node_group_name
  iam_role_arn = module.eks-node-group-iam-role.output.nodegroup_iam_arn
  subnet_ids = var.private_subnet_cidr
}

module "eks-irsa" {
  source = "./modules/EKS/IRSA"
  oidc_issuer_url = module.eks-cluster.output.eks_oidc_issuer_url
  irsa_role_name = var.irsa_role_name
  namespace = var.namespace
  service_account_name = var.service_account_name
  bucket_name = module.s3-bucket.bucket_arn
}

module "ec2" {
  source = "./modules/ec2"

  aws_region    = var.aws_region
  instance_type = var.instance_type
  key_name      = var.key_name
  ami_id        = var.ami_id
  vpc_id        = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
}

module "s3-bucket" {
  source = "./modules/s3-bucket"

  bucket_name     = var.bucket_name
  vpc_endpoint_id = module.vpc.s3_endpoint_id
}