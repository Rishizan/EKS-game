terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # Uncomment and configure for remote state
    # bucket = "your-terraform-state-bucket"
    # key    = "eks-game-platform/terraform.tfstate"
    # region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "EKS-Game-Platform"
      ManagedBy   = "Terraform"
      Owner       = "Rishi"
      Environment = var.environment
    }
  }
}
