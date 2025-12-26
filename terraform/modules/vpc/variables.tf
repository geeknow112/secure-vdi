variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for deployment"
  type        = list(string)
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}