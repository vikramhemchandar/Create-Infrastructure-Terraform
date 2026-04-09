output "nodegroup_iam_arn"{
    value = aws_iam_role.nodegroup-iam-role.arn
    description = "Node IAM ARN"
}