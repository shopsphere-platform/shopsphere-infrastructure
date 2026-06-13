# ══════════════════════════════════════════════════════════
# DB SUBNET GROUP
# RDS instances live in private subnets across 2 AZs
# ══════════════════════════════════════════════════════════
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}

# ══════════════════════════════════════════════════════════
# SECURITY GROUP
# Only allows Postgres (5432) traffic from EKS worker nodes
# ══════════════════════════════════════════════════════════
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Allow Postgres access from EKS nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  }
}

# ══════════════════════════════════════════════════════════
# RDS INSTANCES — one per microservice
# for_each creates: shopsphere-dev-auth, shopsphere-dev-products, etc.
# Mirrors the 6 separate Postgres containers in docker-compose.yml
# ══════════════════════════════════════════════════════════
resource "aws_db_instance" "main" {
  for_each = var.databases

  identifier     = "${var.project_name}-${var.environment}-${each.key}"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  allocated_storage     = var.allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = each.value
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az            = false  # set true for production HA (doubles cost)
  publicly_accessible = false
  skip_final_snapshot  = true  # set false for production

  backup_retention_period = 1
  deletion_protection     = false

  tags = {
    Name    = "${var.project_name}-${var.environment}-${each.key}-db"
    Service = each.key
  }
}
