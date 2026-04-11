variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1" # Mumbai — closest to Hyderabad
}

variable "aws_profile" {
  description = "AWS profile to be used"
  type        = string
}

variable "project_name" {
  description = "Prefix used for all resource names"
  type        = string
  default     = "shopnow"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr2" {
  description = "CIDR block for the private subnet 2"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone" {
  description = "Availability zone for both subnets"
  type        = string
  default     = "ap-south-1a"
}

variable "availability_zone2" {
  description = "Availability zone 2 for 2nd private subnet"
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project     = "ShopNow"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Vikram"
  }
}
