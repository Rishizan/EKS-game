# Terraform AKS Game Platform

This directory contains Terraform configurations to provision an Azure Kubernetes Service (AKS) cluster for the game platform.

## Prerequisites

- Terraform >= 1.0
- Azure CLI configured with appropriate credentials
- Azure subscription with permissions to create AKS, VNet, and resource groups

## Quick Start

```bash
# Login to Azure
az login

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Configure kubectl
az aks get-credentials --resource-group game-platform-rg --name game-platform-aks
```

## Configuration

### Variables

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
azure_location      = "eastus"
resource_group_name = "my-game-platform-rg"
cluster_name        = "my-game-platform-aks"
environment         = "production"
node_vm_size        = "Standard_D2s_v3"
node_count          = 2
node_min_count      = 1
node_max_count      = 4
```

### Remote State (Optional)

To use Azure Storage backend for state management, uncomment and configure the backend block in `provider.tf`:

```hcl
backend "azurerm" {
  resource_group_name  = "terraform-state-rg"
  storage_account_name = "tfstategameplatform"
  container_name       = "tfstate"
  key                  = "aks-game-platform.tfstate"
}
```

## Resources Created

- **Resource Group** for organizing all resources
- **Virtual Network (VNet)** with subnet for AKS
- **AKS Cluster** with managed node pool and autoscaling
- **Managed Identity** for cluster authentication
- **Log Analytics Workspace** for Azure Monitor
- **Container Insights** for monitoring

## Outputs

After applying, you'll get:
- Cluster FQDN and ID
- kubectl configuration command
- VNet and subnet IDs
- Managed identity details

## Cost Estimation

Approximate monthly costs (East US):
- **AKS Control Plane**: Free (managed by Azure)
- **Worker Nodes** (2x Standard_D2s_v3): ~$140
- **Load Balancers** (3x Standard): ~$54
- **Log Analytics**: ~$10
- **Total**: ~$204/month

### Cost Optimization Tips
- Use **Azure Spot VMs** for worker nodes (70% savings)
- Enable **autoscaling** to scale down during low usage
- Use **Reserved Instances** for 1-3 year commitments
- Monitor and optimize with **Azure Cost Management**

## Cleanup

```bash
# Destroy all resources
terraform destroy
```

**Important:** Make sure to delete all Kubernetes LoadBalancer services before destroying Terraform resources to avoid orphaned Azure resources.

## Differences from AWS

| Feature | AWS EKS | Azure AKS |
|---------|---------|-----------|
| Control Plane Cost | $73/month | Free |
| Network | VPC | Virtual Network (VNet) |
| Load Balancer | NLB/ALB | Azure Load Balancer |
| Identity | IAM Roles | Managed Identity |
| Monitoring | CloudWatch | Azure Monitor |
| CLI Tool | aws, eksctl | az |
