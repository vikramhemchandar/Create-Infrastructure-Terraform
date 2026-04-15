aws_region  = "ap-south-1"
aws_profile = "herovired"

project_name         = "jhakkas"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidr   = "10.0.1.0/24"
private_subnet_cidr  = "10.0.2.0/24"
private_subnet_cidr2 = "10.0.3.0/24"
availability_zone    = "ap-south-1a"
availability_zone2   = "ap-south-1b"

common_tags = {
  Project     = "Jhakkas"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "Vikram Hem Chandar"
}
