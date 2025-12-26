output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.vpc.nat_gateway_id
}

output "workspaces_directory_id" {
  description = "ID of the WorkSpaces directory"
  value       = module.workspaces.directory_id
}

output "workspace_id" {
  description = "ID of the WorkSpace"
  value       = module.workspaces.workspace_id
}

output "workspace_ip_address" {
  description = "IP address of the WorkSpace"
  value       = module.workspaces.workspace_ip_address
}

output "workspace_state" {
  description = "State of the WorkSpace"
  value       = module.workspaces.workspace_state
}

output "workspaces_info" {
  description = "WorkSpaces connection information"
  value = {
    workspace_id    = module.workspaces.workspace_id
    directory_id    = module.workspaces.directory_id
    username        = var.analyst_username
    ip_address      = module.workspaces.workspace_ip_address
    state          = module.workspaces.workspace_state
    bundle_id      = var.workspace_bundle
    compute_type   = var.workspace_compute_type
    running_mode   = var.workspace_running_mode
  }
  sensitive = false
}

output "security_group_id" {
  description = "ID of the WorkSpaces security group"
  value       = module.security.workspaces_sg_id
}

output "kms_key_id" {
  description = "ID of the KMS key for encryption"
  value       = module.workspaces.kms_key_id
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = module.monitoring.cloudtrail_arn
}

output "flow_logs_id" {
  description = "ID of the VPC Flow Logs"
  value       = module.monitoring.flow_logs_id
}

output "connection_instructions" {
  description = "Instructions for connecting to WorkSpaces"
  value = <<-EOT
    
    🔗 WorkSpaces Connection Instructions:
    
    1. Download WorkSpaces Client:
       https://clients.amazonworkspaces.com/
    
    2. Connection Details:
       - Registration Code: ${module.workspaces.directory_id}
       - Username: ${var.analyst_username}
       - Password: [Set during first login]
    
    3. First Login:
       - Use temporary password provided by administrator
       - You will be prompted to change password
    
    4. WorkSpace Information:
       - Workspace ID: ${module.workspaces.workspace_id}
       - IP Address: ${module.workspaces.workspace_ip_address}
       - State: ${module.workspaces.workspace_state}
       - Compute Type: ${var.workspace_compute_type}
    
    ⚠️  Security Reminders:
    - This environment is completely isolated
    - All activities are logged and monitored
    - Environment will auto-delete in ${var.auto_cleanup_hours} hours
    - Do not store sensitive data permanently
    
  EOT
}

output "cost_estimation" {
  description = "Estimated daily cost breakdown"
  value = {
    workspaces_daily = "$42.00"
    nat_gateway_daily = "$1.08"
    other_resources_daily = "$0.50"
    total_daily = "$43.58"
    note = "Costs are estimates and may vary based on actual usage"
  }
}

output "cleanup_command" {
  description = "Command to cleanup the environment"
  value = "cd terraform && terraform destroy -auto-approve"
}