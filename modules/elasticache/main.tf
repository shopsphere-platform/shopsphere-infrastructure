# ══════════════════════════════════════════════════════════
# WHY ELASTICACHE?
# docker-compose.yml runs Redis as a container on port 6379,
# used by inventory-service for distributed locks (SETNX on
# "lock:product:{id}") to prevent overselling the last unit
# of a watch when two orders arrive at once.
#
# ElastiCache for Redis is the same Redis engine, just
# managed by AWS — automatic failover, patching, backups.
# inventory-service's code (StringRedisTemplate, setIfAbsent)
# doesn't change — only spring.data.redis.host changes from
# "redis" to this cluster's endpoint.
# ══════════════════════════════════════════════════════════

# ── Subnet Group ─────────────────────────────────────────
# Tells ElastiCache which private subnets it can place
# its nodes in (same private subnets as EKS nodes and RDS)
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids
}

# ── Security Group ───────────────────────────────────────
# Only EKS nodes (running inventory-service) can reach
# Redis on port 6379
resource "aws_security_group" "redis" {
  name        = "${var.project_name}-${var.environment}-redis-sg"
  description = "Allow Redis access from EKS nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from EKS nodes"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    security_groups  = [var.eks_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-redis-sg"
  }
}

# ══════════════════════════════════════════════════════════
# ELASTICACHE REPLICATION GROUP
#
# Using a "replication group" (even with 1 node) instead of
# a basic cluster gives you the option to add a read replica
# later for HA, just by changing num_cache_clusters.
#
# This replaces:
#   redis:  redis:7-alpine  (port 6379, --appendonly yes)
# from docker-compose.yml. AWS handles persistence/snapshots
# instead of the "appendonly" flag.
# ══════════════════════════════════════════════════════════
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${var.project_name}-${var.environment}-redis"
  description           = "Redis for ShopSphere inventory distributed locks"

  engine         = "redis"
  engine_version = "7.1"
  node_type      = var.node_type
  port           = 6379

  num_cache_clusters = 1 # set to 2+ for automatic failover (adds cost)

  subnet_group_name = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  automatic_failover_enabled = false # requires num_cache_clusters >= 2

  tags = {
    Name = "${var.project_name}-${var.environment}-redis"
  }
}
