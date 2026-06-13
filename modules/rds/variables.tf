variable "project_name" {
  type    = string
  default = "shopsphere"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "EKS cluster security group ID — allowed to connect to RDS"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Master username for all database instances"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Master password for all database instances"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "Allocated storage in GB for each database instance"
  type        = number
  default     = 20
}

# One small RDS instance per microservice — matches the 6
# separate Postgres containers in docker-compose.yml
variable "databases" {
  description = "Map of database service name -> database name"
  type        = map(string)
  default = {
    auth          = "shopsphere_auth"
    products      = "shopsphere_products"
    orders        = "shopsphere_orders"
    payments      = "shopsphere_payments"
    inventory     = "shopsphere_inventory"
    notifications = "shopsphere_notifications"
  }
}
