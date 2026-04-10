aws_region  = "ap-south-1"
#aws_profile = "herovired"

project_name        = "jhakkas"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
availability_zone   = "ap-south-1a"

common_tags = {
  Project     = "Jhakkas"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "Vikram Hem Chandar"
}

# EC2 Variables
#aws_region    = "us-west-1"
instance_type = "t3.medium"
key_name      = "yunus-key"
ami_id        = "ami-05d2d839d4f73aafb"  # Amazon Ubuntu (example)

#S3 variables
bucket_name = "jhakkas-tf-s3"

