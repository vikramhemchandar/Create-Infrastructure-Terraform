variable "cluster_name"{
    type = string
}

variable "subnet_ids"{
    type = list(string)
}

variable "iam_role_arn"{
    type = string
}

variable "enable_auto_mode"{
    type = bool
}
variable "nodegroup_desired_size"{
    type = string
}
variable "nodegroup_max_size"{
    type = string
}
variable "nodegroup_min_size"{
    type = string
}
variable "node_group_instance_types"{
    type = list(string)
}
variable "node_group_capacity_type"{
    type = string
}
variable "node_group_disk_size"{
    type = string
}