provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "kubernetes" {
  host                   = module.eks-cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks-cluster.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token",
      "--cluster-name", module.eks-cluster.eks_cluster_name,
    "--region", var.aws_region]
  }
}
