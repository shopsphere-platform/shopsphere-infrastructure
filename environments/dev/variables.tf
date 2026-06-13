# ══════════════════════════════════════════════════════════
# WHY THIS FILE?
# Variables declared here are the "knobs" for this specific
# environment. Their VALUES come from terraform.tfvars (which
# you create locally and NEVER commit if it has secrets).
# ══════════════════════════════════════════════════════════

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  type    = string
  default = "shopsphere"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "db_password" {
  description = "Master password for all RDS Postgres instances (set via terraform.tfvars, not committed)"
  type        = string
  sensitive   = true
}
