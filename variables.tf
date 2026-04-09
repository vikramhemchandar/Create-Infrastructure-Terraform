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

variable "availability_zone" {
  description = "Availability zone for both subnets"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "cluster_name"{
    type = string
}

variable "iam_role_name"{
    type = string
}


variable "eks_node_group_name" {
    type = string
}

variable "nodegroup_iam_role" {
    type = string
}

variable "irsa_role_name" {
    type = string
}

variable "namespace" {
    type = string
}

variable "service_account_name" {
    type = string
}

