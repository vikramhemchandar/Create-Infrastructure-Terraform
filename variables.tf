variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile to be used"
  type        = string
}

variable "project_name" {
  description = "Project name used for all resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "private_subnet_cidr2" {
  description = "CIDR block for the private subnet 2"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for both subnets"
  type        = string
}

variable "availability_zone2" {
  description = "Availability zone 2 for 2nd private subnet"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "cluster_name" {
  type = string
}

variable "irsa_role_name" {
  type = string
}

variable "namespace" {
  type = string
}

variable "irsa_service_account_name" {
  type = string
}
variable "enable_auto_mode" {
  type = bool
}
variable "authentication_mode" {
  type = string
}
variable "cluster_version" {
  type = string
}
variable "enable_private_access" {
  type = bool
}
variable "enable_public_access" {
  type = bool
}
variable "cluster_endpoint_public_access_cidrs" {
  type = list(string)
}
# variable "nodegroup_iam_arn" {
#   type = string
# }
variable "kms_key_arn" {
  type = string
}
# variable "create_iam_roles" {
#   type = bool
# }
# variable "create_node_role" {
#   type = bool
# }
variable "nodegroup_desired_size" {
  type = number
}
variable "nodegroup_max_size" {
  type = number
}
variable "nodegroup_min_size" {
  type = number
}
variable "node_group_instance_types" {
  type = list(string)
}
variable "node_group_capacity_type" {
  type = string
}
variable "node_group_disk_size" {
  type = number
}

# variable "enable_auto_mode" {
#   type = bool
# }
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

variable "bucket_name" {
  type = string
}

