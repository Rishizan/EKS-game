#!/bin/bash

###############################################################################
# EKS Game Platform - Automated Deployment Script
# Author: Rishi
# Description: One-command deployment for the multi-game Kubernetes platform
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    print_success "kubectl is installed"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    print_success "AWS CLI is installed"
    
    # Check cluster connection
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Please configure kubectl."
        exit 1
    fi
    print_success "Connected to Kubernetes cluster"
    
    echo ""
}

# Deploy namespace
deploy_namespace() {
    print_header "Creating Namespace"
    kubectl apply -f ../k8s/namespace.yaml
    print_success "Namespace created"
    echo ""
}

# Deploy ConfigMap
deploy_configmap() {
    print_header "Creating ConfigMap"
    kubectl apply -f ../k8s/configmap.yaml
    print_success "ConfigMap created"
    echo ""
}

# Deploy applications
deploy_applications() {
    print_header "Deploying Game Applications"
    
    print_info "Deploying 2048 game..."
    kubectl apply -f ../k8s/2048-deployment.yaml
    
    print_info "Deploying Tetris game..."
    kubectl apply -f ../k8s/tetris-deployment.yaml
    
    print_info "Deploying Snake game..."
    kubectl apply -f ../k8s/snake-deployment.yaml
    
    print_success "All game deployments created"
    echo ""
}

# Deploy services
deploy_services() {
    print_header "Creating Services"
    kubectl apply -f ../k8s/services.yaml
    print_success "All services created"
    echo ""
}

# Deploy HPA
deploy_hpa() {
    print_header "Creating Horizontal Pod Autoscalers"
    kubectl apply -f ../k8s/hpa.yaml
    print_success "HPA configurations created"
    echo ""
}

# Wait for pods to be ready
wait_for_pods() {
    print_header "Waiting for Pods to be Ready"
    
    print_info "Waiting for 2048 pods..."
    kubectl wait --for=condition=ready pod -l app=game-2048 -n game-platform --timeout=300s
    
    print_info "Waiting for Tetris pods..."
    kubectl wait --for=condition=ready pod -l app=game-tetris -n game-platform --timeout=300s
    
    print_info "Waiting for Snake pods..."
    kubectl wait --for=condition=ready pod -l app=game-snake -n game-platform --timeout=300s
    
    print_success "All pods are ready!"
    echo ""
}

# Display deployment info
display_info() {
    print_header "Deployment Information"
    
    echo -e "${YELLOW}Pods Status:${NC}"
    kubectl get pods -n game-platform
    echo ""
    
    echo -e "${YELLOW}Services:${NC}"
    kubectl get svc -n game-platform
    echo ""
    
    echo -e "${YELLOW}HPA Status:${NC}"
    kubectl get hpa -n game-platform
    echo ""
    
    print_header "Access Your Games"
    
    # Get LoadBalancer URLs
    LB_2048=$(kubectl get svc game-2048-svc -n game-platform -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending...")
    LB_TETRIS=$(kubectl get svc game-tetris-svc -n game-platform -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending...")
    LB_SNAKE=$(kubectl get svc game-snake-svc -n game-platform -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "pending...")
    
    echo -e "${GREEN}🎮 2048 Game:${NC}"
    echo -e "   http://$LB_2048"
    echo ""
    
    echo -e "${GREEN}🎮 Tetris Game:${NC}"
    echo -e "   http://$LB_TETRIS"
    echo ""
    
    echo -e "${GREEN}🎮 Snake Game:${NC}"
    echo -e "   http://$LB_SNAKE"
    echo ""
    
    if [[ "$LB_2048" == "pending..." ]]; then
        print_info "LoadBalancers are being provisioned. Run 'kubectl get svc -n game-platform' to check status."
        print_info "It may take 2-3 minutes for the LoadBalancers to be ready."
    fi
}

# Main deployment flow
main() {
    clear
    print_header "EKS Game Platform Deployment"
    echo -e "${YELLOW}Starting automated deployment...${NC}"
    echo ""
    
    check_prerequisites
    deploy_namespace
    deploy_configmap
    deploy_applications
    deploy_services
    deploy_hpa
    wait_for_pods
    display_info
    
    print_header "Deployment Complete! 🎉"
    print_success "Your multi-game platform is now running on EKS!"
    echo ""
}

# Run main function
main
