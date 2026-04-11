output "eks_cluster_name" {
  value       = aws_eks_cluster.jhakkas-cluster.name
  description = "Cluster IAM ARN"
}

output "eks_oidc_issuer_url" {
  value = aws_eks_cluster.jhakkas-cluster.identity[0].oidc[0].issuer
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.jhakkas-cluster.endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.jhakkas-cluster.certificate_authority[0].data
}
