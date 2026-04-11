resource "aws_eks_addon" "vpc_cni" {
  count = var.enable_auto_mode ? 0 : 1

  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  
}

resource "aws_eks_addon" "ebs_csi" {
  count = var.enable_auto_mode ? 0 : 1

  cluster_name             = var.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi[0].arn/var.ebs_sa_role_arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi[0]/var.ebs_csi_policy_attachment
  ]
}