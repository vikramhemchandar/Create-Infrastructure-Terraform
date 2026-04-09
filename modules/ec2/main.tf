# Get default subnet
#data "aws_subnet_ids" "default" {
#  vpc_id = data.aws_vpc.default.id
#}

# Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "Jhakaas-security-group"
  description = "Allow SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "my_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "Yunus-Terraform-EC2"
  }
}