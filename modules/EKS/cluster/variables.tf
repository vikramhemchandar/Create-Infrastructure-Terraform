variable "eks_cluster_name"{
    type = string
}

variable "subnet_id"{
    type = list(string)
}

variable "iam_role_arn"{
    type = string
}

variable "enable_private_access"{
    type = bool
}
variable "enable_public_access"{
    type = bool
}
variable "cluster_endpoint_public_access_cidrs"{
    type = list(string)
}
variable "enable_auto_mode" {
    type = bool
}
variable "authentication_mode"{
    type = string
}
variable "cluster_version" {
    type = string
}
variable "kms_key_arn"{
    type = string
}
variable "nodegroup_iam_arn"{
    type = string
}
