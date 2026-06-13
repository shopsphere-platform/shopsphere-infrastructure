# ══════════════════════════════════════════════════════════
# WHY THIS FILE?
# After `terraform apply`, these values print to your
# terminal. They're the exact values you'd put into a
# Kubernetes ConfigMap/Secret so each Spring Boot service's
# application.yml points at the real AWS resources instead
# of "localhost" / Docker service names.
# ══════════════════════════════════════════════════════════

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "Run: aws eks update-kubeconfig --name <this> --region us-east-2"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "database_endpoints" {
  description = "host:port for each microservice's Postgres database"
  value       = module.rds.db_endpoints
}

output "kafka_bootstrap_brokers" {
  description = "Value for spring.kafka.bootstrap-servers in every service"
  value       = module.msk.bootstrap_brokers
}

output "redis_endpoint" {
  description = "Value for spring.data.redis.host in inventory-service"
  value       = module.elasticache.primary_endpoint_address
}
