# Only works with API or API_AND_CONFIG_MAP authentication mode

# Standard access entry for node role (automatically grants EC2 nodes cluster access)

resource "aws_eks_access_entry" "node_role" {
  count = var.enable_iam_access_entries && var.create_standard_access_entries && !var.enable_auto_mode ? 1 : 0

  cluster_name  = var.cluster_name
  principal_arn = var.node_role_arn
  type          = "EC2_LINUX"


}

# Custom access entries defined by user
resource "aws_eks_access_entry" "this" {
  for_each = var.enable_iam_access_entries ? var.access_entries : {}

  cluster_name      = var.cluster_name
  principal_arn     = each.key
  kubernetes_groups = each.value.kubernetes_groups
  type              = each.value.type


  depends_on = [var.cluster_name]
}

# Policy associations for access entries
resource "aws_eks_access_policy_association" "this" {
  for_each = var.enable_iam_access_entries ? var.access_entry_policy_associations : {}

  cluster_name  = var.cluster_name
  principal_arn = each.value.principal_arn
  policy_arn    = each.value.policy_arn

  access_scope {
    type       = each.value.access_scope.type
    namespaces = each.value.access_scope.type == "namespace" ? each.value.access_scope.namespaces : []
  }

  depends_on = [
    aws_eks_access_entry.this,
    aws_eks_access_entry.node_role
  ]
}