# AWS Infrastructure - Terraform EC2 Deployment (Yunus)

This project contains Terraform code to provision foundational AWS compute infrastructure. This document specifically outlines the details of the standalone EC2 module structure and its underlying runtime configuration.

---

## 🏗️ Root Module Configuration

The root configuration initializes the global authentication aspects and invokes the EC2 module, passing explicit overrides for the virtual machine orchestration.

### Providers & Versions (`provider.tf` & `versions.tf`)

| Provider Focus | Value | Description |
|---|---|---|
| **Terraform Provider** | `hashicorp/aws` | The official HashiCorp AWS provider interface hook. |
| **Provider Version** | `6.39.0` | Verified constraints for precise module version limits. |
| **AWS Region** | *Dynamic* | Depends structurally on `var.aws_region` via inputs. |

### EC2 Root Variables (`variables.tf` & `terraform.tfvars`)

Focusing selectively on the EC2 computation bounds applied natively inside `terraform.tfvars`:

| Variable Name   | Type     | Current Value (`terraform.tfvars`) | Description |
|-----------------|----------|------------------------------------|-------------|
| `aws_region`    | `string` | `"ap-south-1"`                     | Overall execution region target constraints. |
| `instance_type` | `string` | `"t3.medium"`                      | Designated hardware compute frame allocation. |
| `key_name`      | `string` | `"yunus-key"`                      | Permitted SSH Keypair pointer name string. |
| `ami_id`        | `string` | `"ami-05d2d839d4f73aafb"`          | Amazon Machine Image identifier (Ubuntu variant). |

---

## 💻 EC2 Module Details (`./modules/ec2`)

This specifically scoped module structures the required security rules interface and instantiates the underlying EC2 compute system.

### Resources Orchestrated (`modules/ec2/main.tf`)

| Logical Component | Terraform AWS Provider Type | Resource Specifications / Attributes |
|---|---|---|
| **Security Group** | `aws_security_group.ec2_sg` | **Name**: `"Jhakaas-security-group"` <br> **VPC Matrix ID**: Receives binding via `var.vpc_id` <br> **Ingress Rule**: Allows SSH protocol (`TCP` port `22`) globally from `0.0.0.0/0` <br> **Egress Rule**: Open transmission matrix (`protocol="-1"`) to `0.0.0.0/0` |
| **EC2 Server Host** | `aws_instance.my_ec2` | **System AMI**: Binds directly to `var.ami_id` <br> **Hardware Matrix**: `var.instance_type` <br> **Auth Key**: Limits sign-in logic using `var.key_name` <br> **Network Span**: Deploys securely natively within `var.public_subnet_id` <br> **Security Rules**: Binds strictly to `aws_security_group.ec2_sg.id` <br> **Instance Tags**: `{ Name = "Yunus-Terraform-EC2" }` |

### Module Internal Variables (`modules/ec2/variables.tf`)

The programmatic interface strictly required to structure the EC2 container payload efficiently:

| Variable Identifier | Expected Data Structure | Description |
|---|---|---|
| `aws_region` | `string` | AWS target mapping boundary limits structural pointer. |
| `instance_type` | `string` | Machine computational limit requirements identifier. |
| `key_name` | `string` | Explicit key exchange struct index map string. |
| `ami_id` | `string` | Exact baseline disk image identifier payload identifier. |
| `vpc_id` | `string` | Top bound isolation environment ID boundary mapped directly for the Security Group. |
| `public_subnet_id` | `string` | Directly identifies exact placement for public network exposure mappings. |

*(Note: In structural composition, these configuration parameters expect explicit initialization limits and provide no internal module bounds default limits.)*

### Module Outputs (`modules/ec2/output.tf`)

Calculated operational artifacts provided out from the EC2 deployment cycle context map referencing:

| Output Binding Identifier | Generated Resource ID Context | Result Context Representation |
|---|---|---|
| `instance_id` | `aws_instance.my_ec2.id` | Returns the raw internal unique serial value assigned explicitly to this host string. |
| `public_ip` | `aws_instance.my_ec2.public_ip` | Binds uniquely the automatically yielded reachable public internet protocol IPv4 scalar target. |
| `public_dns` | `aws_instance.my_ec2.public_dns` | Translates specifically computed AWS domain namespaces logic matched explicitly to that allocated matrix limits IP. |
