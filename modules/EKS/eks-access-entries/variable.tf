variable "cluster_name" {
    type = string
}


variable "enable_auto_mode" {
    type = bool
}
variable "node_role_arn" {
    type = string
}
variable "enable_iam_access_entries" {
  description = "Enable IAM access entries for EKS cluster. Only works with API or API_AND_CONFIG_MAP authentication mode."
  type        = bool
  default     = true
}

variable "access_entries" {
  description = <<-EOT
    Map of IAM access entries to create for the cluster.
    Key is the principal ARN (IAM role/user), value is configuration object.
    
    Example:
    {
      "arn:aws:iam::0123456789012:role/DevRole" = {
        kubernetes_groups = ["developers"]
        type             = "STANDARD"  # STANDARD, FARGATE_LINUX, or EC2_LINUX
      }
      "arn:aws:iam::0123456789012:role/AdminRole" = {
        kubernetes_groups = []
        type             = "STANDARD"
      }
    }
  EOT
  type = map(object({
    kubernetes_groups = optional(list(string), [])
    type              = optional(string, "STANDARD")
  }))
  default = {}
}

variable "access_entry_policy_associations" {
  description = <<-EOT
    Map of IAM access entry policy associations.
    Key is a unique identifier, value is configuration object.
    
    Available policy ARNs:
    - AmazonEKSClusterAdminPolicy
    - AmazonEKSAdminPolicy
    - AmazonEKSEditPolicy
    - AmazonEKSViewPolicy
    
    Example:
    {
      "admin-role-cluster-admin" = {
        principal_arn = "arn:aws:iam::0123456789012:role/AdminRole"
        policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        access_scope = {
          type = "cluster"  # cluster or namespace
        }
      }
      "dev-role-namespace-edit" = {
        principal_arn = "arn:aws:iam::0123456789012:role/DevRole"
        policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
        access_scope = {
          type       = "namespace"
          namespaces = ["development", "staging"]
        }
      }
    }
  EOT
  type = map(object({
    principal_arn = string
    policy_arn    = string
    access_scope = object({
      type       = string
      namespaces = optional(list(string), [])
    })
  }))
  default = {}
}

variable "create_standard_access_entries" {
  description = "Automatically create standard access entries for cluster creator and node role"
  type        = bool
  default     = true
}