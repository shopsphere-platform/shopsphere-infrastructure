# ══════════════════════════════════════════════════════════
# WHY THESE OUTPUTS?
# Each Spring Boot service's application.yml has:
#   spring.kafka.bootstrap-servers: kafka:29092   (Docker)
# In production (Kubernetes), this becomes an env var pointing
# at the bootstrap_brokers output below — same property name,
# different value, injected via ConfigMap/Secret in Helm.
# ══════════════════════════════════════════════════════════

output "bootstrap_brokers" {
  description = "Plaintext connection string (host:port,host:port,...) for Kafka clients"
  value       = aws_msk_cluster.main.bootstrap_brokers
}

output "bootstrap_brokers_tls" {
  description = "TLS connection string for Kafka clients"
  value       = aws_msk_cluster.main.bootstrap_brokers_tls
}

output "zookeeper_connect_string" {
  description = "Zookeeper connection string (managed internally by MSK)"
  value       = aws_msk_cluster.main.zookeeper_connect_string
}

output "cluster_arn" {
  description = "ARN of the MSK cluster"
  value       = aws_msk_cluster.main.arn
}
