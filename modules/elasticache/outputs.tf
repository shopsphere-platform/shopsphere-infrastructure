# ══════════════════════════════════════════════════════════
# WHY THIS OUTPUT?
# inventory-service's application.yml has:
#   spring.data.redis.host: localhost   (or "redis" in Docker)
#   spring.data.redis.port: 6379
# In production, host becomes this primary_endpoint_address,
# injected via Kubernetes ConfigMap/Secret in the Helm chart.
# ══════════════════════════════════════════════════════════

output "primary_endpoint_address" {
  description = "Redis primary endpoint address (host)"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "port" {
  description = "Redis port"
  value       = aws_elasticache_replication_group.main.port
}
