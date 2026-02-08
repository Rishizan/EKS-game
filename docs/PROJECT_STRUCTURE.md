# Project Structure

```
DevOps-Project-08-Custom/
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml            # Namespace definition
│   ├── configmap.yaml            # Configuration data
│   ├── 2048-deployment.yaml      # 2048 game deployment
│   ├── tetris-deployment.yaml    # Tetris game deployment
│   ├── snake-deployment.yaml     # Snake game deployment
│   ├── services.yaml             # LoadBalancer services
│   └── hpa.yaml                  # Horizontal Pod Autoscalers
│
├── terraform/                    # Infrastructure as Code
│   ├── provider.tf               # Terraform and AWS provider config
│   ├── variables.tf              # Input variables
│   ├── main.tf                   # Main infrastructure definition
│   ├── outputs.tf                # Output values
│   └── README.md                 # Terraform documentation
│
├── scripts/                      # Automation scripts
│   ├── setup-eks.sh              # EKS cluster creation
│   ├── deploy.sh                 # Application deployment
│   └── cleanup.sh                # Resource cleanup
│
├── docs/                         # Documentation
│   ├── ARCHITECTURE.md           # Architecture details
│   └── PROJECT_STRUCTURE.md      # This file
│
├── .github/                      # GitHub specific files
│   └── workflows/                # GitHub Actions (future)
│
├── README.md                     # Main project documentation
├── LICENSE                       # MIT License
└── .gitignore                    # Git ignore rules
```

## File Descriptions

### Kubernetes Manifests (`k8s/`)

#### `namespace.yaml`
Creates the `game-platform` namespace with custom labels for organization and resource isolation.

#### `configmap.yaml`
Stores configuration data for all games including titles, ports, and platform settings. Allows easy configuration updates without rebuilding containers.

#### `*-deployment.yaml`
Each deployment file defines:
- Number of replicas
- Container image and version
- Resource requests and limits
- Health check probes (liveness and readiness)
- Environment variables from ConfigMap

#### `services.yaml`
Defines LoadBalancer services for each game:
- Exposes pods to the internet
- Creates AWS Network Load Balancers
- Configures session affinity for better UX

#### `hpa.yaml`
Horizontal Pod Autoscaler configurations:
- Monitors CPU and memory metrics
- Automatically scales pods based on load
- Defines min/max replica counts

### Terraform Files (`terraform/`)

#### `provider.tf`
- Terraform version requirements
- AWS provider configuration
- Backend configuration for state management
- Default tags for all resources

#### `variables.tf`
Parameterized inputs for:
- AWS region
- Cluster name and version
- Node instance types and counts
- VPC CIDR blocks
- Environment settings

#### `main.tf`
Core infrastructure definitions:
- VPC with public and private subnets
- EKS cluster with managed node groups
- IAM roles and policies
- Security groups
- Network configuration

#### `outputs.tf`
Exports important values:
- Cluster endpoint
- kubectl configuration command
- VPC and subnet IDs
- IAM role ARNs

### Scripts (`scripts/`)

#### `setup-eks.sh`
Automated EKS cluster creation:
- Validates prerequisites
- Creates cluster using eksctl
- Configures kubectl
- Installs metrics server
- Displays cluster information

#### `deploy.sh`
One-command application deployment:
- Checks cluster connectivity
- Creates namespace and ConfigMap
- Deploys all games
- Creates services and HPA
- Waits for pods to be ready
- Displays access URLs

#### `cleanup.sh`
Safe resource deletion:
- Confirmation prompt
- Deletes all Kubernetes resources
- Removes namespace
- Verifies cleanup

### Documentation (`docs/`)

#### `ARCHITECTURE.md`
Comprehensive architecture documentation:
- System overview
- Component descriptions
- Network flow diagrams
- Security architecture
- Scalability considerations
- Future enhancements

#### `PROJECT_STRUCTURE.md`
This file - explains the project organization and file purposes.

### Root Files

#### `README.md`
Main project documentation:
- Overview and features
- Architecture diagram
- Prerequisites
- Quick start guide
- Deployment options
- Troubleshooting
- Cost estimation

#### `LICENSE`
MIT License - allows free use, modification, and distribution.

#### `.gitignore`
Excludes from version control:
- Terraform state files
- AWS credentials
- Kubernetes config files
- IDE settings
- Temporary files

## Design Principles

### 1. Separation of Concerns
- Infrastructure (Terraform) separate from application (Kubernetes)
- Each game has its own deployment file
- Configuration separated into ConfigMap

### 2. Infrastructure as Code
- All infrastructure defined in version-controlled files
- Reproducible deployments
- Easy to modify and extend

### 3. Automation
- Scripts for common tasks
- One-command deployment
- Minimal manual intervention

### 4. Documentation
- Comprehensive README
- Inline comments in code
- Separate architecture documentation
- Clear file organization

### 5. Production-Ready
- Health checks and resource limits
- Autoscaling configurations
- Proper namespacing
- Security best practices

## Adding New Components

### Adding a New Game

1. Create `k8s/newgame-deployment.yaml`
2. Add service definition to `k8s/services.yaml`
3. Add HPA to `k8s/hpa.yaml`
4. Update ConfigMap with game configuration
5. Update `deploy.sh` to include new game
6. Update README with game information

### Adding Monitoring

1. Create `monitoring/` directory
2. Add Prometheus/Grafana manifests
3. Update `deploy.sh` to deploy monitoring
4. Document in ARCHITECTURE.md

### Adding CI/CD

1. Create `.github/workflows/deploy.yml`
2. Configure GitHub secrets for AWS credentials
3. Define deployment pipeline
4. Update README with CI/CD information

## Best Practices

### Version Control
- Commit frequently with meaningful messages
- Use branches for new features
- Tag releases (v1.0.0, v1.1.0, etc.)

### Security
- Never commit credentials or secrets
- Use AWS Secrets Manager or Kubernetes Secrets
- Regularly update dependencies
- Follow least privilege principle

### Documentation
- Keep README up to date
- Document all configuration changes
- Add comments for complex logic
- Include examples in documentation

### Testing
- Test locally with minikube before EKS
- Validate Terraform with `terraform plan`
- Use dry-run for Kubernetes: `kubectl apply --dry-run=client`
- Test cleanup scripts in non-production first
