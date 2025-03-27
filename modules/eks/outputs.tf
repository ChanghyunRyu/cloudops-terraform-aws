output "eks_cluster_endpoint" {
    value = module.cluster.eks_cluster_endpoint
}

output "eks_cluster_name" {
    value = module.cluster.eks_cluster_name
}

output "eks_cluster_certificate_authority" {
    value = module.cluster.eks_cluster_certificate_authority
}

output "eks_cluster_token" {
    value = module.cluster.kube_token
}

output "oidc_provider_url" {
    value = aws_iam_openid_connect_provider.eks.url
}