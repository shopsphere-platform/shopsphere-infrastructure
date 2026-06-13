# ══════════════════════════════════════════════════════════
# WHY MSK?
# In docker-compose.yml, Kafka + Zookeeper run as containers
# you manage yourself (patching, scaling, broker failures).
# MSK (Managed Streaming for Kafka) is AWS running and
# patching Kafka for you — you just get broker endpoints.
# Your Spring Boot services don't change: same
# spring.kafka.bootstrap-servers property, just pointed at
# MSK's endpoints instead of "kafka:9092".
# ══════════════════════════════════════════════════════════

# ── Security Group ───────────────────────────────────────
# Kafka's plaintext port is 9092, TLS port is 9094.
# Only EKS worker nodes (running our 8 services) can connect.
resource "aws_security_group" "msk" {
  name        = "${var.project_name}-${var.environment}-msk-sg"
  description = "Allow Kafka broker access from EKS nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Kafka plaintext from EKS nodes"
    from_port        = 9092
    to_port          = 9092
    protocol         = "tcp"
    security_groups  = [var.eks_security_group_id]
  }

  ingress {
    description     = "Kafka TLS from EKS nodes"
    from_port        = 9094
    to_port          = 9094
    protocol         = "tcp"
    security_groups  = [var.eks_security_group_id]
  }

  ingress {
    description     = "Zookeeper from EKS nodes (MSK manages this internally too)"
    from_port        = 2181
    to_port          = 2181
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
    Name = "${var.project_name}-${var.environment}-msk-sg"
  }
}

# ── CloudWatch Log Group ─────────────────────────────────
# MSK can ship broker logs here — useful for debugging
# consumer lag, partition rebalances, etc.
resource "aws_cloudwatch_log_group" "msk" {
  name              = "/msk/${var.project_name}-${var.environment}"
  retention_in_days = 7
}

# ══════════════════════════════════════════════════════════
# MSK CLUSTER
#
# number_of_broker_nodes must be a MULTIPLE of the number of
# subnets provided. With 2 private subnets (2 AZs), the
# smallest cluster is 2 brokers — one per AZ, for HA.
#
# This directly replaces:
#   kafka:        confluentinc/cp-kafka:7.6.1   (port 9092)
#   zookeeper:    confluentinc/cp-zookeeper     (port 2181)
# from docker-compose.yml — MSK runs Zookeeper internally,
# you never manage it directly.
# ══════════════════════════════════════════════════════════
resource "aws_msk_cluster" "main" {
  cluster_name           = "${var.project_name}-${var.environment}-kafka"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = length(var.private_subnet_ids)

  broker_node_group_info {
    instance_type   = var.broker_instance_type
    client_subnets  = var.private_subnet_ids
    security_groups = [aws_security_group.msk.id]

    storage_info {
      ebs_storage_info {
        volume_size = var.broker_volume_size
      }
    }
  }

  # Encrypt data at rest (EBS) and in transit between brokers
  encryption_info {
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT" # accepts both TLS (9094) and plaintext (9092)
      in_cluster    = true
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk.name
      }
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-kafka"
  }
}
