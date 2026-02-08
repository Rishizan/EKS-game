# Architecture Documentation

## System Overview

The EKS Game Platform is a cloud-native application platform built on Amazon EKS (Elastic Kubernetes Service) that demonstrates production-ready Kubernetes deployment patterns.

## Components

### 1. Infrastructure Layer (AWS)

#### VPC Architecture
- **CIDR Block**: 10.0.0.0/16
- **Availability Zones**: 3 (for high availability)
- **Public Subnets**: 3 (10.0.101.0/24, 10.0.102.0/24, 10.0.103.0/24)
  - Host NAT Gateways
  - Host Network Load Balancers
- **Private Subnets**: 3 (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
  - Host EKS worker nodes
  - No direct internet access (via NAT Gateway)

#### EKS Cluster
- **Control Plane**: Managed by AWS
- **Worker Nodes**: Managed Node Group
  - Instance Type: t3.medium (2 vCPU, 4 GiB RAM)
  - Desired: 2 nodes
  - Min: 1 node
  - Max: 4 nodes
- **Networking**: AWS VPC CNI plugin
- **Add-ons**: CoreDNS, kube-proxy, VPC CNI, EBS CSI Driver

### 2. Kubernetes Layer

#### Namespace: game-platform
Isolated environment for all game-related resources with resource quotas.

#### Deployments
Each game runs as a separate Deployment:

**2048 Deployment**
- Replicas: 3
- Image: alexwhen/docker-2048
- Resources: 100m CPU / 128Mi RAM (request), 200m CPU / 256Mi RAM (limit)
- Health Checks: HTTP GET on / every 10s

**Tetris Deployment**
- Replicas: 2
- Image: bsord/tetris
- Resources: Same as 2048
- Health Checks: HTTP GET on / every 10s

**Snake Deployment**
- Replicas: 2
- Image: potherca/docker-snake
- Resources: Same as 2048
- Health Checks: HTTP GET on / every 10s

#### Services
Each game has a LoadBalancer service:
- Type: LoadBalancer (creates AWS NLB)
- Port: 80
- Session Affinity: ClientIP (1 hour timeout)
- Annotations: AWS-specific configurations

#### Horizontal Pod Autoscalers
- **Metrics**: CPU utilization (70% target)
- **Scaling Behavior**:
  - Scale Up: Immediate, max 100% increase or 2 pods
  - Scale Down: 5-minute stabilization, max 50% decrease
- **Limits**: Min 2, Max 8-10 pods per game

#### ConfigMap
Centralized configuration for:
- Game titles and descriptions
- Platform metadata
- Environment settings

### 3. Application Layer

#### Game Applications
Browser-based games served as static HTML/JavaScript:
- No backend required
- Stateless design
- Containerized for portability

## Network Flow

```
User Request
    ↓
Internet Gateway
    ↓
Network Load Balancer (Public Subnet)
    ↓
Kubernetes Service (ClusterIP)
    ↓
Pod (Private Subnet)
    ↓
Container (Game Application)
```

## Security Architecture

### Network Security
- **Security Groups**:
  - Cluster SG: Controls EKS control plane communication
  - Node SG: Controls worker node traffic
  - Load Balancer SG: Allows HTTP (80) from internet
- **Network Policies**: Can be added for pod-to-pod communication control

### IAM Security
- **Cluster Role**: Permissions for EKS control plane
- **Node Role**: Permissions for worker nodes (EC2, ECR, CloudWatch)
- **IRSA**: IAM Roles for Service Accounts (OIDC provider)

### Container Security
- **Read-only root filesystem**: Can be enabled
- **Non-root user**: Containers run as non-root where possible
- **Resource limits**: Prevent resource exhaustion attacks

## Scalability

### Horizontal Scaling
- **Pod Level**: HPA scales pods based on metrics
- **Node Level**: Cluster Autoscaler can scale nodes (optional)

### Vertical Scaling
- **VPA**: Vertical Pod Autoscaler can adjust resource requests (optional)

## High Availability

### Application Level
- Multiple pod replicas across nodes
- Anti-affinity rules can spread pods across AZs

### Infrastructure Level
- Multi-AZ deployment
- Managed node groups with auto-recovery
- EKS control plane is multi-AZ by default

## Monitoring & Observability

### Metrics
- **Kubernetes Metrics Server**: Pod and node metrics for HPA
- **CloudWatch Container Insights**: Cluster-level metrics
- **Prometheus**: Can be added for advanced metrics

### Logging
- **CloudWatch Logs**: Centralized log aggregation
- **Fluentd/Fluent Bit**: Log forwarding agents

### Tracing
- **AWS X-Ray**: Can be integrated for distributed tracing

## Disaster Recovery

### Backup Strategy
- **etcd**: Automatically backed up by AWS
- **Application State**: Stateless apps, no backup needed
- **Configuration**: Stored in Git (Infrastructure as Code)

### Recovery Procedures
1. Recreate cluster using Terraform
2. Apply Kubernetes manifests
3. DNS updates (if using custom domain)

## Cost Optimization

### Current Architecture
- **EKS Control Plane**: Fixed cost ($73/month)
- **Worker Nodes**: Variable based on instance type and count
- **Load Balancers**: Per NLB cost ($16/month each)
- **Data Transfer**: Based on usage

### Optimization Strategies
1. **Spot Instances**: 70% cost savings on nodes
2. **Fargate**: Pay per pod, no node management
3. **Reserved Instances**: Commit for 1-3 years
4. **Single NLB**: Use Ingress controller instead of multiple NLBs

## Future Enhancements

### Planned Features
- [ ] Ingress Controller (AWS ALB) for path-based routing
- [ ] Custom domain with Route53
- [ ] SSL/TLS certificates with ACM
- [ ] CI/CD pipeline with GitHub Actions
- [ ] Prometheus + Grafana monitoring stack
- [ ] ArgoCD for GitOps deployment
- [ ] Service Mesh (Istio/Linkerd) for advanced traffic management

### Scalability Improvements
- [ ] Cluster Autoscaler for node scaling
- [ ] Karpenter for advanced node provisioning
- [ ] Multi-region deployment for global availability
- [ ] CDN integration (CloudFront) for static assets

## Technology Stack

| Layer | Technology |
|-------|------------|
| Cloud Provider | AWS |
| Container Orchestration | Kubernetes (EKS) |
| Infrastructure as Code | Terraform |
| Container Runtime | containerd |
| Networking | AWS VPC CNI |
| Load Balancing | AWS Network Load Balancer |
| Monitoring | CloudWatch, Metrics Server |
| Automation | Bash Scripts |
| Version Control | Git |

## References

- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)
- [AWS VPC CNI Plugin](https://github.com/aws/amazon-vpc-cni-k8s)
