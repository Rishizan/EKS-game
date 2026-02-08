#!/bin/bash

###############################################################################
# EKS Cluster Setup Script
# Author: Rishi
# Description: Automated EKS cluster creation and configuration
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
CLUSTER_NAME="game-platform-eks"
REGION="us-east-1"
NODE_TYPE="t3.medium"
NODE_COUNT=2

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
    
    if ! command -v eksctl &> /dev/null; then
        echo "eksctl not found. Installing..."
        # Installation instructions
        echo "Please install eksctl from: https://eksctl.io/installation/"
        exit 1
    fi
    print_success "eksctl is installed"
    
    if ! command -v kubectl &> /dev/null; then
        echo "kubectl not found. Please install kubectl."
        exit 1
    fi
    print_success "kubectl is installed"
    
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Please install AWS CLI."
        exit 1
    fi
    print_success "AWS CLI is installed"
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "AWS credentials not configured. Please run 'aws configure'."
        exit 1
    fi
    print_success "AWS credentials configured"
    echo ""
}

# Create EKS cluster
create_cluster() {
    print_header "Creating EKS Cluster"
    print_info "Cluster Name: $CLUSTER_NAME"
    print_info "Region: $REGION"
    print_info "Node Type: $NODE_TYPE"
    print_info "Node Count: $NODE_COUNT"
    echo ""
    
    print_info "This will take approximately 15-20 minutes..."
    
    eksctl create cluster \
        --name $CLUSTER_NAME \
        --region $REGION \
        --nodegroup-name game-platform-nodes \
        --node-type $NODE_TYPE \
        --nodes $NODE_COUNT \
        --nodes-min 1 \
        --nodes-max 4 \
        --managed \
        --with-oidc \
        --ssh-access \
        --ssh-public-key ~/.ssh/id_rsa.pub \
        --full-ecr-access
    
    print_success "EKS cluster created successfully!"
    echo ""
}

# Configure kubectl
configure_kubectl() {
    print_header "Configuring kubectl"
    
    aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
    
    print_success "kubectl configured for cluster: $CLUSTER_NAME"
    echo ""
}

# Install AWS Load Balancer Controller
install_lb_controller() {
    print_header "Installing AWS Load Balancer Controller"
    
    # Create IAM policy
    curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.7/docs/install/iam_policy.json
    
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam_policy.json \
        --region $REGION || true
    
    # Create service account
    eksctl create iamserviceaccount \
        --cluster=$CLUSTER_NAME \
        --namespace=kube-system \
        --name=aws-load-balancer-controller \
        --role-name AmazonEKSLoadBalancerControllerRole \
        --attach-policy-arn=arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/AWSLoadBalancerControllerIAMPolicy \
        --approve \
        --region=$REGION || true
    
    # Install controller using Helm
    helm repo add eks https://aws.github.io/eks-charts
    helm repo update
    
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
        -n kube-system \
        --set clusterName=$CLUSTER_NAME \
        --set serviceAccount.create=false \
        --set serviceAccount.name=aws-load-balancer-controller
    
    print_success "AWS Load Balancer Controller installed"
    echo ""
}

# Install metrics server for HPA
install_metrics_server() {
    print_header "Installing Metrics Server"
    
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    print_success "Metrics Server installed"
    echo ""
}

# Display cluster info
display_cluster_info() {
    print_header "Cluster Information"
    
    echo "Cluster Name: $CLUSTER_NAME"
    echo "Region: $REGION"
    echo ""
    
    kubectl get nodes
    echo ""
    
    print_success "EKS cluster is ready for deployment!"
    echo ""
    print_info "Next steps:"
    echo "  1. cd ../scripts"
    echo "  2. ./deploy.sh"
    echo ""
}

# Main setup flow
main() {
    clear
    print_header "EKS Cluster Setup for Game Platform"
    
    check_prerequisites
    create_cluster
    configure_kubectl
    install_metrics_server
    # install_lb_controller  # Uncomment if using ALB Ingress
    display_cluster_info
    
    print_header "Setup Complete! 🎉"
}

main
