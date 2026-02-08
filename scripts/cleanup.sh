#!/bin/bash

###############################################################################
# EKS Game Platform - Cleanup Script
# Author: Rishi
# Description: Safely removes all deployed resources
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Confirmation prompt
confirm_cleanup() {
    print_header "Cleanup Confirmation"
    echo -e "${YELLOW}This will delete all resources in the game-platform namespace.${NC}"
    echo -e "${YELLOW}This action cannot be undone!${NC}"
    echo ""
    read -p "Are you sure you want to continue? (yes/no): " confirmation
    
    if [[ "$confirmation" != "yes" ]]; then
        echo -e "${RED}Cleanup cancelled.${NC}"
        exit 0
    fi
    echo ""
}

# Delete resources
cleanup_resources() {
    print_header "Removing Resources"
    
    print_warning "Deleting HPA configurations..."
    kubectl delete -f ../k8s/hpa.yaml --ignore-not-found=true
    
    print_warning "Deleting services..."
    kubectl delete -f ../k8s/services.yaml --ignore-not-found=true
    
    print_warning "Deleting deployments..."
    kubectl delete -f ../k8s/2048-deployment.yaml --ignore-not-found=true
    kubectl delete -f ../k8s/tetris-deployment.yaml --ignore-not-found=true
    kubectl delete -f ../k8s/snake-deployment.yaml --ignore-not-found=true
    
    print_warning "Deleting ConfigMap..."
    kubectl delete -f ../k8s/configmap.yaml --ignore-not-found=true
    
    print_warning "Deleting namespace..."
    kubectl delete -f ../k8s/namespace.yaml --ignore-not-found=true
    
    print_success "All resources deleted successfully!"
    echo ""
}

# Verify cleanup
verify_cleanup() {
    print_header "Verifying Cleanup"
    
    if kubectl get namespace game-platform &> /dev/null; then
        print_warning "Namespace still exists (may take a moment to fully delete)"
    else
        print_success "Namespace completely removed"
    fi
    echo ""
}

# Main cleanup flow
main() {
    clear
    print_header "EKS Game Platform Cleanup"
    
    confirm_cleanup
    cleanup_resources
    verify_cleanup
    
    print_header "Cleanup Complete! ✓"
    echo -e "${GREEN}All game platform resources have been removed.${NC}"
    echo ""
}

main
