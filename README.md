# AWS Infrastructure - Terraform EKS Deployment (Kaveri)

This document deeply illustrates the Elastic Kubernetes Service (EKS) infrastructure layout defined across several specialized submodules inside `modules/EKS`. The architecture spans across strict IAM privilege boundaries, highly available Node Groups, Pod-level Security (IRSA), managed Addons, and modern IAM Access Entries.

---

## 🏗️ Root Module Configuration

### EKS Root Variables (`terraform.tfvars`)

Focusing selectively on the variables established centrally in `terraform.tfvars` that act as the boundaries for the EKS modules:

| Variable Name | Value | Description |
|---|---|---|
| `cluster_name` | `"jhakkas-cluster"` | Global identifier assigned to the EKS cluster logic. |
| `cluster_version` | `"1.34"` | The Kubernetes control plane software version. |
| `enable_auto_mode` | `false` | Disables EKS Auto mode, using manual node group orchestration. |
| `authentication_mode` | `"API_AND_CONFIG_MAP"` | Employs both EKS IAM Access entries (API) alongside the legacy `aws-auth` ConfigMap. |
| `enable_private_access` | `true` | Allows private subnet resolution to the cluster endpoint. |
| `enable_public_access` | `true` | Allows kubectl commands from over the public internet to reach the cluster. |
| `nodegroup_desired_size` | `3` | Base baseline scale target for worker nodes. |
| `nodegroup_max_size` | `4` | Absolute ceiling limits for the ASG logic. |
| `nodegroup_min_size` | `2` | Floor threshold guaranteeing minimum cluster availability. |
| `node_group_instance_types` | `["t3.medium"]` | Allocated VM hardware matrices. |
| `irsa_role_name` | `"custom-sa-irsa-role"` | IAM Role bounded specifically for secure Pod execution. |
| `namespace` | `"default"` | Logical Kubernetes logical segregation matrix namespace. |

---

## ☸️ EKS Submodules Breakdown & Resource Mapping

The EKS architecture is decoupled into 7 singular micro-modules nested within `modules/EKS`. Here is the complete breakdown of each component interacting, the resources instantiated, and the exported IDs utilized securely downstream.

### 1️⃣ Cluster Core (`./modules/EKS/cluster`)
Governs the Kubernetes Central Control Plane.

- **Resources Created:**
  - `aws_eks_cluster.jhakkas-cluster`: The core EKS Control plane entity configuring network logic mapping, auth structures, and API visibility rules.
- **Injected Parameters & Dependencies:**
  - `iam_role_arn`: Fetches precisely from `module.cluster-iam-role.iam_role_arn`. 
  - `subnet_id`: Fetches dynamically from `module.vpc.private_subnet_id` and `module.vpc.private_subnet_id2`.
  - `nodegroup_iam_arn`: Required dependency tracking fetched from `module.eks-node-group-iam-role.nodegroup_iam_arn`.
- **Exported Output IDs:**
  - `eks_cluster_name`: Feeds into addons, Node Groups, and Access Entries.
  - `eks_oidc_issuer_url`: Extremely vital for the IRSA logic to build Pod identity trusts.

### 2️⃣ Cluster IAM Role (`./modules/EKS/cluster_iam_role`)
Manages the Identity assumptions empowering the control plane itself.

- **Resources Created:**
  - `aws_iam_role.cluster_iam_role`: Trust bounds yielding `eks.amazonaws.com` assumes role privileges.
  - *Attachments*: Yields `AmazonEKSClusterPolicy` and `AmazonEKSVPCResourceController`.
- **Exported Output IDs:**
  - `iam_role_arn`: Output explicitly routed cleanly into the Cluster core mapping.

### 3️⃣ Node IAM Role (`./modules/EKS/node_iam_role`)
Administers what the underlying worker EC2 instances within EKS are intrinsically allowed to do in AWS.

- **Resources Created:**
  - `aws_iam_role.nodegroup-iam-role`: Yields assumption to `ec2.amazonaws.com`.
  - *Attachments*: Hooks `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`.
- **Exported Output IDs:**
  - `nodegroup_iam_arn`: Forwarded heavily to `module.eks-node-group` and `module.eks_access_entries`.

### 4️⃣ EKS Node Group (`./modules/EKS/node_group`)
Spawns and autoscales the physical EC2 hosts processing the Kubernetes workload pods.

- **Resources Created:**
  - `aws_eks_node_group.example`: Assembles the compute matrices matching EC2 pools strictly to the Cluster endpoint.
- **Injected Parameters & Dependencies:**
  - `cluster_name`: Supplied entirely via `module.eks-cluster.eks_cluster_name`.
  - `iam_role_arn`: Supplied directly from `module.node_iam_role`.
  - Scalability parameters bound directly via Root logic mapping variables (min: `2`, max: `4`, desired: `3`, type: `ON_DEMAND`, volume: `20` GB).

### 5️⃣ IRSA - IAM Roles for Service Accounts (`./modules/EKS/IRSA`)
Constructs exact least-privilege Zero-Trust identity hooks for microservices inside Kubernetes to naturally interact with AWS resources natively.

- **Resources Created:**
  - `aws_iam_openid_connect_provider.default`: The core certificate OIDC trust between EKS and AWS IAM.
  - `aws_iam_role.irsa_role` & `aws_iam_policy.irsa_policy`: Explicit IAM permissions bounding pods to SecretsManager read abilities and S3 bucket bounds (`s3:GetObject` mapping fetched exactly from the S3 submodule identifier).
  - `kubernetes_service_account.serviceaccount`: The K8s-side object binding annotations to the AWS side object.
  - `aws_iam_role.ebs_iam_role`: A dedicated CSI role bound specifically allowing dynamic EBS block tracking.
- **Injected Parameters & Dependencies:**
  - `oidc_issuer_url`: Provided seamlessly via `module.eks-cluster.eks_oidc_issuer_url`.
  - `bucket_name`: Integrated smoothly binding from `module.s3-bucket.bucket_name` isolating storage matrix limits limits exclusively to this namespace.
- **Exported Output IDs:**
  - `ebs_csi_arn` & `ebs_csi_policy_attachment`: Output directly into `module.eks-addons`.

### 6️⃣ EKS Addons (`./modules/EKS/addons`)
Leverages built-in EKS cluster tooling logic.

- **Resources Created:**
  - `aws_eks_addon.vpc_cni`: Orchestrates network routing logic directly.
  - `aws_eks_addon.ebs_csi`: Enforces block-store lifecycle hooks logic.
- **Injected Parameters & Dependencies:**
  - `ebs_sa_role_arn` & `ebs_csi_policy_attachment`: Derived completely from dependencies output by `module.eks-irsa`.

### 7️⃣ EKS Access Entries (`./modules/EKS/eks-access-entries`)
Deploys modern AWS native replacements enforcing Cluster mappings devoid of modifying `aws-auth` mapping maps.

- **Resources Created:**
  - `aws_eks_access_entry.node_role`: Integrates natively `EC2_LINUX` nodes seamlessly joining mapped identity boundaries seamlessly.
  - `aws_eks_access_entry.this` & `aws_eks_access_policy_association.this`: Extensible blocks for granular IAM user maps logic bindings injected externally.
- **Injected Parameters & Dependencies:**
  - `cluster_name`: Maps mapping dynamically from `module.eks-cluster`.
  - `node_role_arn`: Fed logically from `module.node_iam_role`.
