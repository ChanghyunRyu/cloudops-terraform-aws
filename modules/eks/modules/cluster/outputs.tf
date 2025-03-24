output "eks_cluster_id" {
  description = "EKS Cluster name"
  value       = aws_eks_cluster.this.id
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster endpoint URL"
  value       = aws_eks_cluster.this.endpoint
}

output "eks_cluster_name" {
    description = "EKS Cluster name"
    value = aws_eks_cluster.this.name
}

output "eks_cluster_certificate_authority" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "eks_oidc_issuer" {
    description = "OIDC Provider URL"
    value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.this.id
}

output "eks_cluster_iam_role_arn" {
  description = "IAM role ARN used by EKS control plane"
  value       = aws_iam_role.this.arn
}
