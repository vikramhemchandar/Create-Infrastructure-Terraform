output "ebs_csi_arn" {
   value = aws_iam_role.ebs_iam_role[0].arn
}

output "ebs_csi_policy_attachment" {
    value = aws_iam_role_policy_attachment.ebs_csi[0]
}