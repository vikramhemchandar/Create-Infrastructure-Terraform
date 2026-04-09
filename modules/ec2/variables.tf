variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "key_name" {
  description = "EC2 Key pair name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for EC2"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for EC2"
  type        = string
}