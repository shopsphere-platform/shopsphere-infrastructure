output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "API server endpoint for the EKS cluster"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "Base64 encoded certificate data for cluster auth"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "node_role_arn" {
  description = "IAM role ARN used by worker nodes"
  value       = aws_iam_role.eks_nodes.arn
}
