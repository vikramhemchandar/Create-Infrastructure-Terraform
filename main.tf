module "vpc" {
  source = "./modules/vpc"

  aws_region  = var.aws_region
  aws_profile = var.aws_profile

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
    iam_role = module.cluster-iam-role.output.iam_role_arn
    subnet_id = module.subnet1.subnet_id
}

module "cluster-iam-role"{
    source = "./modules/EKS/iam_role"
    iam_role_name = var.iam_role_name
}

module "policy-attachment"{
    source = "./modules/EKS/policy_attachment"
    policy_arn = var.policy_arn
    iam_role = module.cluster-iam-role.output.iam_role_name
}
