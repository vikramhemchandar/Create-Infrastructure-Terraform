variable "create_iam_roles"{
    type = bool
    description = "This is to decide whether IAM Role for cluster should be created"
    default = false
}

variable "cluster_name" {
    type = string
    description = "Name of the EKS Cluster"
}

