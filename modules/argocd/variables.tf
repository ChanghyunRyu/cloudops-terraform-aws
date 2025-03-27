variable "install_argocd" {
    description = "If true, install ArgoCD via Helm"
    type        = bool
    default     = false
}

variable "argocd_version" {
    type = string
    default = "5.51.6"
}

variable "application_yamls" {
    description = "Path list of user-defined ArgoCD Application YAMLs"
    type        = list(string)
}

variable "eks_cluster_endpoint" {
    type = string
}

variable "eks_cluster_certificate_authority" {
    type = string
}

variable "eks_cluster_name" {
    type = string
}
