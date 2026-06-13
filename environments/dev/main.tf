# ══════════════════════════════════════════════════════════
# THIS FILE IS THE "WIRING DIAGRAM"
#
# Each module{} block below:
#   1. Points to the module's folder (source)
#   2. Passes in INPUT values (left side = variable name
#      defined in that module's variables.tf)
#   3. Can use OUTPUTS from earlier modules as inputs to
#      later ones — this is how they connect.
#
# Order matters for understanding, NOT for execution —
# Terraform builds a dependency graph automatically from
# these references and creates things in the right order.
# ══════════════════════════════════════════════════════════

# ── 1. NETWORKING ────────────────────────────────────────
# Creates the VPC, public/private subnets, NAT gateway.
# Nothing else can exist without this — everything below
# references module.vpc.* outputs.
module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
}

# ── 2. KUBERNETES CLUSTER ────────────────────────────────
# Creates the EKS control plane + worker node group inside
# the VPC's private subnets. This is where all 8 Spring Boot
# services + React frontend will run as pods.
module "eks" {
  source = "../../modules/eks"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  # Small/cheap defaults for a dev/demo cluster
  node_instance_types = ["t3.medium"]
  node_desired_size   = 2
  node_min_size       = 1
  node_max_size       = 4
}

# ── 3. DATABASES ──────────────────────────────────────────
# Creates 6 RDS Postgres instances (auth, products, orders,
# payments, inventory, notifications) — one per microservice,
# matching the 6 postgres-* containers in docker-compose.yml.
# Security group only allows traffic FROM EKS nodes.
module "rds" {
  source = "../../modules/rds"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.cluster_security_group_id

  db_username = "postgres"
  db_password = var.db_password # from terraform.tfvars, not committed
}

# ── 4. EVENT STREAMING ───────────────────────────────────
# Creates a 2-broker MSK (managed Kafka) cluster, replacing
# the kafka + zookeeper containers. order-service publishes
# "order-created"; inventory-service and notification-service
# consume it — same as in Docker, just different broker address.
module "msk" {
  source = "../../modules/msk"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.cluster_security_group_id
}

# ── 5. CACHE / DISTRIBUTED LOCKS ──────────────────────────
# Creates a managed Redis instance, replacing the redis
# container. inventory-service uses this for the
# setIfAbsent() distributed lock pattern when reserving stock.
module "elasticache" {
  source = "../../modules/elasticache"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  eks_security_group_id = module.eks.cluster_security_group_id
}
