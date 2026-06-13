variable "project_name" {
  type    = string
  default = "shopsphere"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the Redis subnet group"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "EKS cluster security group ID — allowed to connect to Redis"
  type        = string
}

variable "node_type" {
  description = "ElastiCache node instance type"
  type        = string
  default     = "cache.t3.micro"
}
