# AWS Infrastructure - VPC Module Deployment (Vikram)

This document maps out the Terraform orchestration designed for provisioning foundational AWS Networking. The architecture yields a standard, highly available Virtual Private Cloud (VPC) featuring public/private subnet logic, resilient NAT Gateways, and isolated S3 connectivity endpoints.

---

## 🏗️ Root Execution Context

The root `main.tf` defines the entry orchestration logic. It parses the provider block constraints and injects environment-specific bounds dynamically into the submodules.

### Terraform Providers

| Provider Profile | Declared Version | Configuration Map |
|---|---|---|
| **`hashicorp/aws`** | `6.39.0` | Assumes identity implicitly via the `aws_profile` variable definition. |

### Global Input Parameters (`terraform.tfvars`)

These bounds are injected globally from the root tracking directly into the underlying networking module:

| Parameter Key | Data Type | Assigned Value | Target Function |
|---|---|---|---|
| `aws_region` | `string` | `"ap-south-1"` | AWS data center mapping (Mumbai). |
| `aws_profile` | `string` | `"herovired"` | CLI token mapping limit identity. |
| `project_name` | `string` | `"jhakkas"` | The naming prefix bound across all VPC module resources. |
| `vpc_cidr` | `string` | `"10.0.0.0/16"` | Total IPv4 scope limit of the target internal cloud network. |
| `public_subnet_cidr` | `string` | `"10.0.1.0/24"` | Network chunk sliced strictly for internet gateway routing. |
| `private_subnet_cidr` | `string` | `"10.0.2.0/24"` | Network chunk mathematically sliced for isolated outbound-only logic. |
| `availability_zone` | `string` | `"ap-south-1a"` | Target physical isolation data center location slice for both subsets. |
| `common_tags` | `map(string)` | `{ Project="Jhakkas", Environment="dev", ManagedBy="Terraform", Owner="Vikram Hem Chandar" }` | Universally appended identity labels enforcing resource billing grouping. |

---

## 🖧 VPC Submodule Internals (`./modules/vpc`)

The core module `vpc` encapsulates complex Amazon AWS explicit networking constructs logic. 

### Instantiated Resources & Parameter Consumption

The module consumes the parameters above directly without local duplication, leveraging them to provision the following AWS primitives natively:

| Terraform AWS Resource | Resource Representation | Internal Logic & Parameter Mapping |
|---|---|---|
| `aws_vpc.main` | **Virtual Private Cloud** | Instantiates basic layout bounds. consumes logically `var.vpc_cidr`. Forces `enable_dns_support` and `enable_dns_hostnames` to `true`. |
| `aws_internet_gateway.igw` | **Internet Gateway** | Native border gateway dynamically attached into `aws_vpc.main.id`. |
| `aws_subnet.public` | **Public Subnet** | Bounded using limit `var.public_subnet_cidr` upon `var.availability_zone`. Triggers automated mapping `map_public_ip_on_launch = true`. |
| `aws_subnet.private` | **Private Subnet** | Bounded strictly by logic `var.private_subnet_cidr` securely upon `var.availability_zone`. |
| `aws_eip.nat` | **NAT Elastic IP** | Static IP tracking explicitly requesting `domain = "vpc"`. Relies upon Gateway init (`depends_on`). |
| `aws_nat_gateway.nat` | **NAT Gateway** | Translates internal traffic bounds bounds mapped precisely over `aws_subnet.public.id` bound inside `aws_eip.nat.id`. |
| `aws_route_table.public` | **Public Route Matrix** | Implements the routing tracking explicitly routing internet `0.0.0.0/0` natively to the `aws_internet_gateway.igw.id`. |
| `aws_route_table.private` | **Private Route Matrix** | Forces egress security routing logic pushing bounds `0.0.0.0/0` safely out via `aws_nat_gateway.nat.id`. | 
| `aws_vpc_endpoint.s3` | **S3 Gateway Endpoint** | Deploys natively `com.amazonaws.${var.aws_region}.s3` gateway endpoint natively locking policy JSON logic to wide `s3:*` rights mapping securely spanning both Public and Private Route Maps IDs natively. |

### 🚀 Exported IDs for External Module Integrations

A crucial element of the `vpc` submodule is rendering output dependency arrays safely so that secondary scaling modules (Compute/S3/Databases) successfully locate the correct network interfaces limits without manual hard-coding.

The following unique IDs are yielded outwards dynamically mapping bounds into sibling roots logic tracks:

| Generated ID Export Key | Target Mapped Value Reference | Downstream Module Use Case |
|---|---|---|
| `vpc_id` | `aws_vpc.main.id` | Used heavily to bound EC2 System Security Group isolation and EKS constraints. |
| `vpc_cidr` | `aws_vpc.main.cidr_block` | Applied broadly if calculating overlapping peer matrix networks or strict IP firewalling. |
| `public_subnet_id` | `aws_subnet.public.id` | Tracks structural placement targets mapping for DMZ applications (like EC2 bastion hosts, Load balancers). |
| `private_subnet_id` | `aws_subnet.private.id` | Explicit boundary limits mapped internally scaling EKS Nodes scaling tracking inside the core VPC isolating bounds limit. |
| `internet_gateway_id` | `aws_internet_gateway.igw.id` | Can be mapped mapping tracking peering gateway logic bounds bounds. |
| `nat_gateway_id` | `aws_nat_gateway.nat.id` | Bound track mapping egress matrix logical limitations dynamically. |
| `nat_eip_public_ip` | `aws_eip.nat.public_ip` | Required bound limits natively white-listing corporate VPNs or SAAS APIs logically tracking originating data points strictly. |
| `s3_endpoint_id` | `aws_vpc_endpoint.s3.id` | Strictly consumed mapping bounds exclusively deployed for `modules/s3-bucket` IAM Policy logic matrices dynamically. |
| `public_route_table_id` | `aws_route_table.public.id` | Enables secondary integrations structurally binding limits like AWS VPN peering or Transit Gateway mappings inside the public DMZ block. |
| `private_route_table_id` | `aws_route_table.private.id` | Used actively for secondary integrations logic requiring deep isolated connectivity inside the tracking block limit bound mapping limitations. |
