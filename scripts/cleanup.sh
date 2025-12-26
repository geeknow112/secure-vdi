#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_NAME="secure-vdi"

echo -e "${BLUE}🧹 Secure VDI Infrastructure Cleanup${NC}"
echo "====================================="

# Warning message
echo -e "${RED}⚠️  WARNING: This will PERMANENTLY DELETE all infrastructure${NC}"
echo -e "${RED}    - All WorkSpaces will be terminated${NC}"
echo -e "${RED}    - All data will be lost${NC}"
echo -e "${RED}    - All AWS resources will be destroyed${NC}"
echo ""

# Confirmation
read -p "🤔 Are you sure you want to continue? (y/N): " confirm
if [[ $confirm != [yY] ]]; then
    echo -e "${YELLOW}❌ Cleanup cancelled${NC}"
    exit 1
fi

# Double confirmation
echo -e "${YELLOW}⚠️  Last chance to cancel...${NC}"
read -p "🔥 Type 'DELETE' to confirm permanent deletion: " delete_confirm
if [[ $delete_confirm != "DELETE" ]]; then
    echo -e "${YELLOW}❌ Cleanup cancelled${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Starting cleanup process...${NC}"

# Change to terraform directory
cd terraform

# Check if terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo -e "${YELLOW}⚠️  No terraform state found. Nothing to cleanup.${NC}"
    exit 0
fi

# Get current resources before cleanup
echo -e "${YELLOW}📋 Checking current resources...${NC}"
terraform show -json > /tmp/terraform_state_backup.json 2>/dev/null || true

# Force terminate WorkSpaces (in case they're stuck)
echo -e "${YELLOW}🛑 Force terminating WorkSpaces...${NC}"
WORKSPACE_IDS=$(aws workspaces describe-workspaces \
    --query "Workspaces[?Tags[?Key=='Project' && Value=='Secure-VDI']].WorkspaceId" \
    --output text 2>/dev/null || echo "")

if [ ! -z "$WORKSPACE_IDS" ]; then
    for workspace_id in $WORKSPACE_IDS; do
        echo "   Terminating WorkSpace: $workspace_id"
        aws workspaces terminate-workspaces \
            --terminate-workspace-requests WorkspaceId=$workspace_id \
            2>/dev/null || echo "   Failed to terminate $workspace_id"
    done
    
    # Wait for WorkSpaces to terminate
    echo "   Waiting for WorkSpaces to terminate..."
    sleep 30
fi

# Delete snapshots created by WorkSpaces
echo -e "${YELLOW}📸 Deleting WorkSpaces snapshots...${NC}"
SNAPSHOT_IDS=$(aws ec2 describe-snapshots \
    --owner-ids self \
    --filters "Name=tag:Project,Values=Secure-VDI" \
    --query 'Snapshots[].SnapshotId' \
    --output text 2>/dev/null || echo "")

if [ ! -z "$SNAPSHOT_IDS" ]; then
    for snapshot_id in $SNAPSHOT_IDS; do
        echo "   Deleting snapshot: $snapshot_id"
        aws ec2 delete-snapshot --snapshot-id $snapshot_id 2>/dev/null || echo "   Failed to delete $snapshot_id"
    done
fi

# Archive logs before deletion
echo -e "${YELLOW}📦 Archiving logs...${NC}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_BUCKET="${PROJECT_NAME}-logs-archive-${TIMESTAMP}"

# Try to create archive bucket and export logs
aws s3 mb s3://$LOG_BUCKET 2>/dev/null || echo "   Could not create archive bucket"

# Export VPC Flow Logs if they exist
VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || echo "")
if [ ! -z "$VPC_ID" ]; then
    echo "   Exporting VPC Flow Logs..."
    aws logs create-export-task \
        --log-group-name "/aws/vpc/${PROJECT_NAME}-flowlogs" \
        --from $(date -d '7 days ago' +%s)000 \
        --to $(date +%s)000 \
        --destination $LOG_BUCKET \
        --destination-prefix "vpc-flowlogs" \
        2>/dev/null || echo "   Could not export VPC Flow Logs"
fi

# Export CloudTrail logs if they exist
aws logs create-export-task \
    --log-group-name "/aws/cloudtrail/${PROJECT_NAME}" \
    --from $(date -d '7 days ago' +%s)000 \
    --to $(date +%s)000 \
    --destination $LOG_BUCKET \
    --destination-prefix "cloudtrail-logs" \
    2>/dev/null || echo "   Could not export CloudTrail logs"

# Terraform destroy
echo -e "${BLUE}🗑️  Destroying infrastructure with Terraform...${NC}"
terraform destroy -auto-approve -var-file="terraform.tfvars"

# Clean up terraform files
echo -e "${YELLOW}🧽 Cleaning up Terraform state...${NC}"
rm -f terraform.tfstate*
rm -f .terraform.lock.hcl
rm -rf .terraform/

# Remove from crontab
echo -e "${YELLOW}⏰ Removing auto-cleanup from crontab...${NC}"
crontab -l 2>/dev/null | grep -v "cleanup.sh" | crontab - 2>/dev/null || echo "   No crontab entries found"

# Final verification
echo -e "${YELLOW}🔍 Verifying cleanup...${NC}"

# Check for remaining WorkSpaces
REMAINING_WORKSPACES=$(aws workspaces describe-workspaces \
    --query "Workspaces[?Tags[?Key=='Project' && Value=='Secure-VDI']].WorkspaceId" \
    --output text 2>/dev/null || echo "")

if [ ! -z "$REMAINING_WORKSPACES" ]; then
    echo -e "${YELLOW}⚠️  Warning: Some WorkSpaces may still exist: $REMAINING_WORKSPACES${NC}"
fi

# Check for remaining snapshots
REMAINING_SNAPSHOTS=$(aws ec2 describe-snapshots \
    --owner-ids self \
    --filters "Name=tag:Project,Values=Secure-VDI" \
    --query 'Snapshots[].SnapshotId' \
    --output text 2>/dev/null || echo "")

if [ ! -z "$REMAINING_SNAPSHOTS" ]; then
    echo -e "${YELLOW}⚠️  Warning: Some snapshots may still exist: $REMAINING_SNAPSHOTS${NC}"
fi

echo ""
echo -e "${GREEN}✅ Cleanup completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Summary:${NC}"
echo "   - All Terraform resources destroyed"
echo "   - WorkSpaces terminated"
echo "   - Snapshots deleted"
echo "   - Logs archived to S3 (if successful)"
echo "   - Auto-cleanup removed from crontab"

if [ ! -z "$LOG_BUCKET" ]; then
    echo ""
    echo -e "${BLUE}📦 Archived logs available at:${NC}"
    echo "   S3 Bucket: s3://$LOG_BUCKET"
    echo "   Note: You may want to delete this bucket after reviewing logs"
fi

echo ""
echo -e "${GREEN}🎯 Environment successfully cleaned up!${NC}"
echo -e "${YELLOW}💡 Remember to review any archived logs for compliance purposes${NC}"