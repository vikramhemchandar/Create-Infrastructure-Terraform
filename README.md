# AWS Infrastructure - Terraform S3 Deployment (Anasuya)

This project contains Terraform code to provision foundational AWS cloud infrastructure. This document specifically focuses on the integration and structural configuration of the private S3 Bucket via VPC Endpoints and restrictive security policies.

---

## 🏗️ Root Module Configuration

The root configuration initializes global variables and calls the S3 bucket module, inherently binding it to the pre-existing networking bounds securely without traversing the public internet.

### Providers & Versions (`provider.tf` & `versions.tf`)

| Provider Focus | Value | Description |
|---|---|---|
| **Terraform Provider** | `hashicorp/aws` | Core HashiCorp AWS provider utilized for resource mapping. |
| **Provider Version** | `6.39.0` | Exact strict version constraint mapping mapping. |

### S3 Root Variables (`variables.tf` & `terraform.tfvars`)

Focusing on the variables shaping the storage solution passed from `terraform.tfvars`:

| Variable Name   | Type     | Current Value (`terraform.tfvars`) | Description |
|-----------------|----------|------------------------------------|-------------|
| `aws_region`    | `string` | `"ap-south-1"`                     | Execution region target constraints (Mumbai). |
| `bucket_name`   | `string` | `"jhakkas-tf-s3"`                  | The globally unique name established for the AWS S3 Bucket storage container. |

---

## 📦 S3 Storage Module Details (`./modules/s3-bucket`)

This carefully constructed module orchestrates an AWS Simple Storage Service (S3) bucket. Its primary architectural feature is the implementation of zero-trust public access, enforcing that all data communication occurs privately within the Amazon network by bounding the bucket tightly to a distinct **VPC Endpoint**.

### Resources Orchestrated (`modules/s3-bucket/main.tf`)

| Component | Terraform Resource Type | Resource Specifications / Attributes |
|---|---|---|
| **S3 Storage Bucket** | `aws_s3_bucket.this` | **Bucket Name**: Bound statically to `var.bucket_name` (`"jhakkas-tf-s3"`) |
| **Bucket Versioning** | `aws_s3_bucket_versioning.this` | **Status**: `"Enabled"` <br> Validates that data object revisions are persisted safely. Protects against accidental deletes and overwrites. |

### 🛡️ Deep Dive: S3 Bucket Policy & VPC Endpoints Integration

To align with stringent enterprise security frameworks, the S3 bucket does not sit unprotected. The module specifically constructs an inline JSON policy via `aws_s3_bucket_policy.this` which mandates the following restrictive bounds:

#### **Condition Restrictions: The VPC Endpoint Gateway**
The policy enforces a strict `Condition`: 
```json
"Condition": {
    "StringEquals": {
        "aws:SourceVpce": var.vpc_endpoint_id
    }
}
```
**What does this mean?**
The `var.vpc_endpoint_id` maps straight to the S3 Target Gateway Endpoint created in the accompanying VPC module (`module.vpc.s3_endpoint_id`). This completely rejects **all** traffic—regardless of who the Principal is—unless the request physically traverses from inside the internal AWS VPC via that explicit Gateway Endpoint structure. Traffic generated over the public internet is outright dropped.

#### **Permitted API Actions**
While filtering by the precise VPC point of origin, the policy securely authorizes the specific CRUD API commands essential for regular operations within the ecosystem:
- `s3:ListBucket` (To read what is inside the directory).
- `s3:GetObject` (To download files internally to EC2/EKS).
- `s3:PutObject` (To push internal backups/data).
- `s3:DeleteObject` (To clear up stored structure).

#### **Resource Target Scope**
The policy acts over: 
- `aws_s3_bucket.this.arn` (The parent bucket logical container)
- `${aws_s3_bucket.this.arn}/*` (All recursive data objects stored within)

---

### Module Variables (`modules/s3-bucket/variables.tf`)

Variables utilized locally inside the scoped parameter limits of the S3 creation frame:

| Variable Identifier | Expected Data Structure | Description |
|---|---|---|
| `bucket_name` | `string` | Payload identifier bound functionally to create the globally distinct storage namespace. |
| `vpc_endpoint_id` | `string` | Core Network ID mapping of the internal S3 Gateway interface. Injected locally from `module.vpc.s3_endpoint_id`. |

### Module Outputs (`modules/s3-bucket/outputs.tf`)

Identifiable matrix state bounds exported dynamically mapping out for deeper integrations string constraints (like Kubernetes IAM Roles for Service Accounts - IRSA context):

| Output Binding Identifier | Generated Resource ID Context | Output Description |
|---|---|---|
| `bucket_arn` | `aws_s3_bucket.this.arn` | Returns the universally unique Amazon Resource Name for the generated storage system. |
