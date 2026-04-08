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
