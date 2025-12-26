#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLEANUP_HOURS=${CLEANUP_HOURS:-72}
ANALYST_USERNAME=${ANALYST_USERNAME:-"security-analyst"}
PROJECT_NAME="secure-vdi"

echo -e "${BLUE}🚀 Secure VDI Infrastructure Deployment Started${NC}"
echo "=================================================="

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI is not installed${NC}"
    exit 1
fi

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform is not installed${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "terraform/terraform.tfvars" ]; then
    echo -e "${YELLOW}⚠️  terraform.tfvars not found. Creating template...${NC}"
    cat > terraform/terraform.tfvars << EOF
# AWS Configuration
aws_region = "ap-northeast-1"

# Network Configuration
vpc_cidr = "10.100.0.0/16"
availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]

# Security Configuration
admin_ips = ["YOUR.IP.ADDRESS/32"]  # Replace with your IP
directory_password = "SecurePassword123!"  # Change this password

# WorkSpaces Configuration
analyst_username = "security-analyst"
workspace_bundle = "wsb-bh8rsxt14"  # Performance bundle
workspace_compute_type = "PERFORMANCE"
workspace_running_mode = "MANUAL"

# Monitoring Configuration
enable_flow_logs = true
enable_cloudtrail = true

# Auto-cleanup Configuration
auto_cleanup_hours = 72
EOF
    echo -e "${RED}❌ Please edit terraform/terraform.tfvars with your settings${NC}"
    echo -e "${YELLOW}   Especially update admin_ips with your IP address${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Display configuration
echo -e "${BLUE}⚙️  Configuration:${NC}"
echo "   Environment will auto-delete after: ${CLEANUP_HOURS} hours"
echo "   Analyst username: ${ANALYST_USERNAME}"
echo "   Project: ${PROJECT_NAME}"

# Confirmation
echo ""
read -p "🤔 Continue with deployment? (y/N): " confirm
if [[ $confirm != [yY] ]]; then
    echo -e "${YELLOW}❌ Deployment cancelled${NC}"
    exit 1
fi

# Change to terraform directory
cd terraform

# Terraform initialization
echo -e "${YELLOW}📦 Initializing Terraform...${NC}"
terraform init

# Terraform validation
echo -e "${YELLOW}🔍 Validating Terraform configuration...${NC}"
terraform validate

# Terraform plan
echo -e "${YELLOW}📋 Planning infrastructure...${NC}"
terraform plan \
  -var="auto_cleanup_hours=${CLEANUP_HOURS}" \
  -var="analyst_username=${ANALYST_USERNAME}" \
  -var-file="terraform.tfvars"

# Final confirmation
echo ""
read -p "🚀 Deploy infrastructure? (y/N): " deploy_confirm
if [[ $deploy_confirm != [yY] ]]; then
    echo -e "${YELLOW}❌ Deployment cancelled${NC}"
    exit 1
fi

# Deploy infrastructure
echo -e "${BLUE}🏗️  Deploying infrastructure...${NC}"
terraform apply -auto-approve \
  -var="auto_cleanup_hours=${CLEANUP_HOURS}" \
  -var="analyst_username=${ANALYST_USERNAME}" \
  -var-file="terraform.tfvars"

# Get outputs
echo -e "${GREEN}✅ Deployment completed!${NC}"
echo ""
echo -e "${BLUE}📋 WorkSpaces Connection Information:${NC}"
terraform output connection_instructions

echo ""
echo -e "${BLUE}💰 Cost Estimation:${NC}"
terraform output cost_estimation

# Setup auto-cleanup if hours > 0
if [ "$CLEANUP_HOURS" -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⏰ Setting up auto-cleanup in ${CLEANUP_HOURS} hours...${NC}"
    
    # Create cleanup script path
    CLEANUP_SCRIPT="$(pwd)/../scripts/cleanup.sh"
    
    # Calculate cleanup time
    if command -v date &> /dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            CLEANUP_TIME=$(date -v+${CLEANUP_HOURS}H '+%M %H %d %m *')
        else
            # Linux
            CLEANUP_TIME=$(date -d "+${CLEANUP_HOURS} hours" '+%M %H %d %m *')
        fi
        
        # Add to crontab
        (crontab -l 2>/dev/null; echo "${CLEANUP_TIME} ${CLEANUP_SCRIPT}") | crontab -
        echo -e "${GREEN}✅ Auto-cleanup scheduled${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not schedule auto-cleanup. Please run cleanup.sh manually${NC}"
    fi
fi

echo ""
echo -e "${GREEN}🎯 Environment ready for security research!${NC}"
echo -e "${YELLOW}⚠️  Important reminders:${NC}"
echo "   - This environment is completely isolated"
echo "   - All activities are logged and monitored"
if [ "$CLEANUP_HOURS" -gt 0 ]; then
    echo "   - Environment will auto-delete in ${CLEANUP_HOURS} hours"
fi
echo "   - Do not store sensitive data permanently"
echo "   - Run './scripts/cleanup.sh' when finished"

echo ""
echo -e "${BLUE}📚 Next steps:${NC}"
echo "   1. Download WorkSpaces client from: https://clients.amazonworkspaces.com/"
echo "   2. Use the registration code and credentials shown above"
echo "   3. Begin your security research"
echo "   4. Run cleanup script when finished"