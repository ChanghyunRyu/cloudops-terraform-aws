terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
  }
}

resource "kubernetes_config_map" "aws_auth" {
    metadata {
        name = "aws-auth"
        namespace = "kube-system"
    }

    data = {
        mapRoles = yamlencode([var.role_mapping])
    }

    lifecycle {
        ignore_changes = [data]
    }

    depends_on = [] 
}