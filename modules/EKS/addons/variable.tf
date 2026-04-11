variable "enable_auto_mode" {
    type = bool
}
variable "cluster_name" {
    type = string
}

variable "ebs_sa_role_arn" {
    type = string
}

variable "ebs_csi_policy_attachment" {
    type = list(string)
}