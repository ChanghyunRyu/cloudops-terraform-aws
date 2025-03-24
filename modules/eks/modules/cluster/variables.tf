variable "name" {
  description = "Prefix name for EKS resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
}

variable "default_tags" {
    type = map(string)
}

variable "cluster_enabled_log_types" {
    type = list(string)
    default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
