#!/bin/bash

###############################################################################
# AKS Cluster Setup Script
# Author: Rishi
# Description: Automated AKS cluster creation and configuration
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
RESOURCE_GROUP="game-platform-rg"
CLUSTER_NAME="game-platform-aks"
LOCATION="eastus"
NODE_COUNT=2
NODE_VM_SIZE="Standard_D2s_v3"
KUBERNETES_VERSION="1.28"

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    if ! command -v az &> /dev/null; then
        echo "Azure CLI not found. Installing..."
        echo "Please install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    print_success "Azure CLI is installed"
    
    if ! command -v kubectl &> /dev/null; then
        echo "kubectl not found. Please install kubectl."
        exit 1
    fi
    print_success "kubectl is installed"
    
    # Check Azure login
    if ! az account show &> /dev/null; then
        echo "Not logged in to Azure. Please run 'az login'."
        exit 1
    fi
    print_success "Logged in to Azure"
    
    # Display current subscription
    SUBSCRIPTION=$(az account show --query name -o tsv)
    print_info "Using subscription: $SUBSCRIPTION"
    echo ""
}

# Create resource group
create_resource_group() {
    print_header "Creating Resource Group"
    
    az group create \
        --name $RESOURCE_GROUP \
        --location $LOCATION \
        --tags Environment=production Project=AKS-Game-Platform Owner=Rishi
    
    print_success "Resource group created: $RESOURCE_GROUP"
    echo ""
}

# Create AKS cluster
create_aks_cluster() {
    print_header "Creating AKS Cluster"
    print_info "Cluster Name: $CLUSTER_NAME"
    print_info "Location: $LOCATION"
    print_info "Node VM Size: $NODE_VM_SIZE"
    print_info "Node Count: $NODE_COUNT"
    print_info "Kubernetes Version: $KUBERNETES_VERSION"
    echo ""
    
    print_info "This will take approximately 10-15 minutes..."
    
    az aks create \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --location $LOCATION \
        --node-count $NODE_COUNT \
        --node-vm-size $NODE_VM_SIZE \
        --kubernetes-version $KUBERNETES_VERSION \
        --enable-managed-identity \
        --enable-addons monitoring \
        --enable-cluster-autoscaler \
        --min-count 1 \
        --max-count 4 \
        --network-plugin azure \
        --load-balancer-sku standard \
        --generate-ssh-keys \
        --tags Environment=production Project=AKS-Game-Platform
    
    print_success "AKS cluster created successfully!"
    echo ""
}

# Configure kubectl
configure_kubectl() {
    print_header "Configuring kubectl"
    
    az aks get-credentials \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --overwrite-existing
    
    print_success "kubectl configured for cluster: $CLUSTER_NAME"
    echo ""
}

# Install metrics server
install_metrics_server() {
    print_header "Installing Metrics Server"
    
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    print_success "Metrics Server installed"
    echo ""
}

# Display cluster info
display_cluster_info() {
    print_header "Cluster Information"
    
    echo "Resource Group: $RESOURCE_GROUP"
    echo "Cluster Name: $CLUSTER_NAME"
    echo "Location: $LOCATION"
    echo ""
    
    print_info "Getting node information..."
    kubectl get nodes
    echo ""
    
    print_info "Cluster details:"
    az aks show \
        --resource-group $RESOURCE_GROUP \
        --name $CLUSTER_NAME \
        --query "{fqdn:fqdn, kubernetesVersion:kubernetesVersion, nodeResourceGroup:nodeResourceGroup}" \
        --output table
    echo ""
    
    print_success "AKS cluster is ready for deployment!"
    echo ""
    print_info "Next steps:"
    echo "  1. cd ../scripts"
    echo "  2. ./deploy.sh"
    echo ""
}

# Main setup flow
main() {
    clear
    print_header "AKS Cluster Setup for Game Platform"
    
    check_prerequisites
    create_resource_group
    create_aks_cluster
    configure_kubectl
    install_metrics_server
    display_cluster_info
    
    print_header "Setup Complete! 🎉"
}

main
