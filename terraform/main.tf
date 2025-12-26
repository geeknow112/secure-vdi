terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "Secure-VDI"
      Environment = "Isolated"
      Purpose     = "Security-Research"
      ManagedBy   = "Terraform"
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  project_name      = var.project_name
}

# Security Module
module "security" {
  source = "./modules/security"
  
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  admin_ips    = var.admin_ips
  project_name = var.project_name
}

# WorkSpaces Module
module "workspaces" {
  source = "./modules/workspaces"
  
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_id   = module.security.workspaces_sg_id
  directory_password  = var.directory_password
  analyst_username    = var.analyst_username
  workspace_bundle    = var.workspace_bundle
  project_name       = var.project_name
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
}