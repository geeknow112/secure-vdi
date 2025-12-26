variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "secure-vdi"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.100.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for deployment"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "admin_ips" {
  description = "Admin IP addresses for access control (CIDR format)"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for ip in var.admin_ips : can(cidrhost(ip, 0))
    ])
    error_message = "Admin IPs must be in CIDR format (e.g., 192.168.1.1/32)."
  }
}

variable "directory_password" {
  description = "Password for WorkSpaces directory (minimum 8 characters)"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.directory_password) >= 8
    error_message = "Directory password must be at least 8 characters long."
  }
}

variable "analyst_username" {
  description = "Username for security analyst"
  type        = string
  default     = "security-analyst"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.analyst_username))
    error_message = "Username must contain only alphanumeric characters, dots, underscores, and hyphens."
  }
}

variable "auto_cleanup_hours" {
  description = "Hours after which environment auto-deletes (0 to disable)"
  type        = number
  default     = 72
  
  validation {
    condition     = var.auto_cleanup_hours >= 0 && var.auto_cleanup_hours <= 168
    error_message = "Auto cleanup hours must be between 0 and 168 (1 week)."
  }
}

variable "workspace_bundle" {
  description = "WorkSpaces bundle ID"
  type        = string
  default     = "wsb-bh8rsxt14"  # Performance bundle
  
  # Common bundle IDs:
  # wsb-clj85qzj1 - Value
  # wsb-3t36q0xfc - Standard  
  # wsb-bh8rsxt14 - Performance
  # wsb-1pzkp0bx4 - PowerPro
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail logging"
  type        = bool
  default     = true
}

variable "workspace_running_mode" {
  description = "WorkSpaces running mode (MANUAL or AUTO_STOP)"
  type        = string
  default     = "MANUAL"
  
  validation {
    condition     = contains(["MANUAL", "AUTO_STOP"], var.workspace_running_mode)
    error_message = "Running mode must be either MANUAL or AUTO_STOP."
  }
}

variable "workspace_compute_type" {
  description = "WorkSpaces compute type"
  type        = string
  default     = "PERFORMANCE"
  
  validation {
    condition = contains([
      "VALUE", "STANDARD", "PERFORMANCE", "POWER", "GRAPHICS", "POWERPRO", "GRAPHICSPRO"
    ], var.workspace_compute_type)
    error_message = "Invalid compute type specified."
  }
}