variable "project_name" {
  type    = string
  default = "shopsphere"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "vpc_id" {
  description = "VPC ID where the cluster will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the EKS node group"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs (for the EKS cluster API endpoint access)"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}
