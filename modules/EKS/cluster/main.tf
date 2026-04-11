resource "aws_eks_cluster" "jhakkas-cluster" {
  name = var.eks_cluster_name
  
  # Access configuration - Required for Auto Mode
  access_config {
    authentication_mode                         = var.enable_auto_mode ? "API_AND_CONFIG_MAP" : var.authentication_mode
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = var.iam_role_arn
  version  = var.cluster_version


  vpc_config {
    subnet_ids = var.subnet_id
    endpoint_private_access = var.enable_private_access
    endpoint_public_access  = var.enable_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
    //security_group_ids      = [local.cluster_security_group_id_effective]
  }

  # Bootstrap configuration - Must be false for Auto Mode
  bootstrap_self_managed_addons = var.enable_auto_mode ? false : true

  dynamic "compute_config" {
      for_each = var.enable_auto_mode ? [1] : []
      content {
        enabled       = true
        node_pools    = ["general-purpose", "system"]
        node_role_arn = var.nodegroup_iam_arn
      }
    }

  dynamic "kubernetes_network_config" {
    for_each = var.enable_auto_mode ? [1] : []
    content {
      elastic_load_balancing {
        enabled = true
      }
    }
  }

  dynamic "storage_config" {
    for_each = var.enable_auto_mode ? [1] : []
    content {
      block_storage {
        enabled = true
      }
    }
  }

  dynamic "encryption_config" {
    for_each = var.kms_key_arn != "" ? [1] : []
    content {
      resources = ["secrets"]

      provider {
        key_arn = var.kms_key_arn
      }
    }
  }
  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.

}
