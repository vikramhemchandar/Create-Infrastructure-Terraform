resource "aws_eks_node_group" "example" {
  count = var.enable_auto_mode ? 0 : 1
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-ng-default"
  node_role_arn   = var.iam_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.nodegroup_desired_size
    max_size     = var.nodegroup_max_size
    min_size     = var.nodegroup_min_size
  }

  instance_types = var.node_group_instance_types
  capacity_type  = var.node_group_capacity_type
  disk_size      = var.node_group_disk_size

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    create_before_destroy = true
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.

}