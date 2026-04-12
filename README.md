# AWS Infrastructure - Terraform Project (Jhakkas)

This project contains Terraform code to provision foundational AWS Infrastructure consisting of a VPC, public and private subnets, NAT Gateway, Internet Gateway, and an S3 Gateway Endpoint.

---

## 🏗️ Root Module Configuration

The root configuration acts as the entry point for the Terraform execution and sets up the providers alongside calling the underlying VPC module.

### Providers & Versions (`provider.tf` & `versions.tf`)

| Provider Focus | Value | Description |
|---|---|---|
| **Terraform Provider** | `hashicorp/aws` | The official HashiCorp AWS provider block used for resource provisioning. |
| **Provider Version** | `6.39.0` | Exact version constraint specified in the `required_providers` block. |
| **AWS Region** | *Dynamic* | Depends on `aws_region` fed into the profile, mapping AWS authentication constraints. |

### Root Variables (`variables.tf` & `terraform.tfvars`)

The infrastructure configuration relies on variables initialized natively inside `terraform.tfvars`. Below is the detailed breakdown:

| Variable Name         | Type          | Current Value (`terraform.tfvars`) | Description |
|-----------------------|---------------|------------------------------------|-------------|
| `aws_region`          | `string`      | `"ap-south-1"`                     | Target AWS region for deployments (Mumbai). |
| `aws_profile`         | `string`      | `"herovired"`                      | The AWS CLI profile utilized for authentication. |
| `project_name`        | `string`      | `"jhakkas"`                        | Prefix string utilized for naming all AWS resources. |
| `vpc_cidr`            | `string`      | `"10.0.0.0/16"`                    | IP CIDR block allocated for the entire VPC. |
| `public_subnet_cidr`  | `string`      | `"10.0.1.0/24"`                    | Subnet CIDR block dedicated for the public subnet. |
| `private_subnet_cidr` | `string`      | `"10.0.2.0/24"`                    | Subnet CIDR block dedicated for the private subnet. |
| `availability_zone`   | `string`      | `"ap-south-1a"`                    | Logical Availability Zone assigned to the subnets. |
| `common_tags`         | `map(string)` | `{ Project = "Jhakkas", Environment = "dev", ManagedBy = "Terraform", Owner = "Vikram Hem Chandar" }`     | Common tag definitions for automated management. |

---

## 📦 VPC Module Details (`./modules/vpc`)

A reusable module structure specifically implemented for deploying a secure and optimized standard AWS VPC pattern.

### Resources Orchestrated (`modules/vpc/main.tf`)

| Logical Resource | Terraform AWS Provider Type | Resource Specifications / Attributes |
|---|---|---|
| **VPC** | `aws_vpc.main` | **CIDR**: `var.vpc_cidr` <br> **DNS Support**: `true` <br> **DNS Hostnames**: `true` |
| **Internet Gateway** | `aws_internet_gateway.igw` | **VPC ID**: Attached mapped to `aws_vpc.main.id` |
| **Public Subnet** | `aws_subnet.public` | **CIDR**: `var.public_subnet_cidr` <br> **AZ**: `var.availability_zone` <br> **Public IP on Launch**: `true` |
| **Private Subnet** | `aws_subnet.private` | **CIDR**: `var.private_subnet_cidr` <br> **AZ**: `var.availability_zone` |
| **Elastic IP** | `aws_eip.nat` | **Domain**: `"vpc"`, Depends on the IGW initialization. |
| **NAT Gateway** | `aws_nat_gateway.nat` | **Subnet ID**: Created inside the Public Subnet `aws_subnet.public.id` <br> **Allocation ID**: Attached to `aws_eip.nat.id` |
| **Route Table (Public)** | `aws_route_table.public` | **Route Rule**: `0.0.0.0/0` -> Targets the Internet Gateway |
| **RT Association (Public)** | `aws_route_table_association.public` | Explicitly associates Public Route Table to the Public Subnet |
| **Route Table (Private)** | `aws_route_table.private` | **Route Rule**: `0.0.0.0/0` -> Targets outbound specifically to NAT Gateway |
| **RT Association (Private)** | `aws_route_table_association.private` | Explicitly associates Private Route Table to the Private Subnet |
| **VPC Endpoint (S3)** | `aws_vpc_endpoint.s3` | **Type**: `Gateway` <br> **Service Filter**: `com.amazonaws.${var.aws_region}.s3` <br> **Route Tables**: Configured automatically to *both* Public & Private Route Tables. <br> **Policy JSON**: Allows universal API actions (`s3:*`) |

### Module Variables (`modules/vpc/variables.tf`)

These variable declarations match the root module inputs, providing an autonomous default fallback mechanism directly at the module boundary limit:

| Variable | Default Value in Module | Description |
|---|---|---|
| `aws_region` | `"ap-south-1"` | AWS deployment region parameter scope. |
| `aws_profile` | *(No default, required)* | Required AWS profile name argument. |
| `project_name` | `"shopnow"` | Default prefix name (overwritten structurally by `jhakkas`). |
| `vpc_cidr` | `"10.0.0.0/16"` | Default CIDR IP range limit for the module testing. |
| `public_subnet_cidr` | `"10.0.1.0/24"` | Default structural limits for the public subnetwork block. |
| `private_subnet_cidr` | `"10.0.2.0/24"` | Default structural limits for the private subnetwork block. |
| `availability_zone` | `"ap-south-1a"` | Pre-computed AZ structural preference. |
| `common_tags` | `{ Project = "ShopNow", Environment = "dev", ManagedBy = "Terraform", Owner = "Vikram" }` | Auto-defined tags payload. |

### Module Outputs (`modules/vpc/output.tf`)

After a successful `terraform apply`, this module yields several vital identifiers usable implicitly as referential strings across wider deployment dependencies:

| Output Identifier | Sourced Resource State | Output Description |
|---|---|---|
| `vpc_id` | `aws_vpc.main.id` | The unique ID of the compiled Virtual Private Cloud. |
| `vpc_cidr` | `aws_vpc.main.cidr_block` | Computed explicit CIDR configuration block string. |
| `public_subnet_id` | `aws_subnet.public.id` | Dynamic ID for configuring resources in the public topology. |
| `private_subnet_id` | `aws_subnet.private.id` | Dynamic ID for configuring resources in the private isolation. |
| `internet_gateway_id` | `aws_internet_gateway.igw.id` | Exposes IGW bindings logic ID index. |
| `nat_gateway_id` | `aws_nat_gateway.nat.id` | ID allocated to NAT traffic routing rules interface. |
| `nat_eip_public_ip` | `aws_eip.nat.public_ip` | Egress verified static IP Address allocated globally over AWS. |
| `s3_endpoint_id` | `aws_vpc_endpoint.s3.id` | Internal regional DNS ID representing the S3 Gateway endpoint rules. |
| `public_route_table_id` | `aws_route_table.public.id` | Represents public zone logic map IDs. |
| `private_route_table_id` | `aws_route_table.private.id` | Represents private zone core outbound logic map IDs. |
