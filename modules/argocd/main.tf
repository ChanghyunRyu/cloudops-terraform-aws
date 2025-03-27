data "aws_eks_cluster_auth" "this" {
    name = var.eks_cluster_name
}

provider "kubernetes" {
    host = var.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.eks_cluster_certificate_authority)
    token = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host = var.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.eks_cluster_certificate_authority)
    token = data.aws_eks_cluster_auth.this.token
  }
}

resource "helm_release" "argocd" {
    count = var.install_argocd ? 1 : 0

    name = "argocd"
    namespace = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    chart      = "argo-cd"
    version    = var.argocd_version

    create_namespace = true
    values = []
}

resource "kubernetes_manifest" "applications" {
    for_each = { for path in var.application_yamls : path => path }
     manifest = yamldecode(file(each.value))
}