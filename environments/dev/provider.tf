# ══════════════════════════════════════════════════════════
# WHY THIS FILE?
# Tells Terraform: (1) which AWS region to talk to, and
# (2) the minimum Terraform + provider versions, so anyone
# running this gets consistent behavior (important for teams
# and CI/CD — avoids "works on my machine" for infra too).
# ══════════════════════════════════════════════════════════

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # ── State Backend ────────────────────────────────────────
  # By default Terraform stores "state" (what it created) in
  # a local file terraform.tfstate. For a team / CI pipeline,
  # state should live in S3 so everyone shares the same view.
  #
  # Uncomment once you've created an S3 bucket for this:
  #
  # backend "s3" {
  #   bucket = "shopsphere-terraform-state"
  #   key    = "dev/terraform.tfstate"
  #   region = "us-east-2"
  # }
}

provider "aws" {
  region = var.aws_region
}
