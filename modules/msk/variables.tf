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
  description = "Private subnet IDs — MSK brokers spread across these (one per AZ)"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "EKS cluster security group ID — allowed to connect to Kafka brokers"
  type        = string
}

variable "kafka_version" {
  type    = string
  default = "3.6.0"
}

variable "broker_instance_type" {
  description = "EC2 instance type for each Kafka broker"
  type        = string
  default     = "kafka.t3.small"
}

variable "broker_volume_size" {
  description = "EBS volume size (GB) per broker"
  type        = number
  default     = 20
}
