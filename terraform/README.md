# Terraform EKS Game Platform

This directory contains Terraform configurations to provision an Amazon EKS cluster for the game platform.

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create EKS, VPC, and IAM resources

## Quick Start

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name game-platform-eks
```

## Configuration

### Variables

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
aws_region         = "us-east-1"
cluster_name       = "my-game-platform"
environment        = "production"
node_instance_type = "t3.medium"
node_desired_size  = 2
node_min_size      = 1
node_max_size      = 4
```

### Remote State (Optional)

To use S3 backend for state management, uncomment and configure the backend block in `provider.tf`:

```hcl
backend "s3" {
  bucket = "your-terraform-state-bucket"
  key    = "eks-game-platform/terraform.tfstate"
  region = "us-east-1"
}
```

## Resources Created

- **VPC** with public and private subnets across 3 availability zones
- **EKS Cluster** with managed node group
- **IAM Roles** for cluster and nodes
- **Security Groups** for cluster and node communication
- **NAT Gateway** for private subnet internet access

## Outputs

After applying, you'll get:
- Cluster endpoint
- kubectl configuration command
- VPC and subnet IDs
- IAM role ARNs

## Cost Estimation

Approximate monthly costs (us-east-1):
- EKS Cluster: ~$73
- EC2 Nodes (2x t3.medium): ~$60
- NAT Gateway: ~$32
- **Total: ~$165/month**

## Cleanup

```bash
# Destroy all resources
terraform destroy
```

**Important:** Make sure to delete all Kubernetes LoadBalancer services before destroying Terraform resources to avoid orphaned AWS resources.
