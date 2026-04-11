data "tls_certificate" "eks" {
  url = var.oidc_issuer_url
}

#OIDC Provider Creation (This is required even when auto mode is on while creating cluster)
resource "aws_iam_openid_connect_provider" "default" {
  url             = var.oidc_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

#IRSA Role for Pods (This is required even when auto mode is on while creating cluster)
resource "aws_iam_role" "irsa_role" {
  name = var.irsa_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.default.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${aws_iam_openid_connect_provider.default.url}:sub" = "system:serviceaccount:${var.namespace}:${var.irsa_service_account_name}"
          "${aws_iam_openid_connect_provider.default.url}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

#IRSA Pod IAM Policy (This is required even when auto mode is on while creating cluster)
resource "aws_iam_policy" "irsa_policy" {
  name = "irsa-policy-${var.namespace}-${var.irsa_service_account_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

#IRSA Policy attachment to IAM for Pods (This is required even when auto mode is on while creating cluster)
resource "aws_iam_role_policy_attachment" "irsa_attach" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.irsa_policy.arn
}

#EBS CSI IAM ROLE (Not required when using auto mode for node group creation)
resource "aws_iam_role" "ebs_iam_role" {
  count = var.enable_auto_mode ? 0 : 1
  name  = "${var.cluster_name}-ebs-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.default.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${aws_iam_openid_connect_provider.default.url}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count      = var.enable_auto_mode ? 0 : 1
  role       = aws_iam_role.ebs_iam_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

#Creating a Namespace
resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

#Kubernetes SA account creation for the pods to access S3 bucket and Secret Manager
resource "kubernetes_service_account" "serviceaccount" {
  metadata {
    name      = var.irsa_service_account_name
    namespace = kubernetes_namespace.this.name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.irsa_role.arn
    }
  }
}
