data "aws_eks_cluster_auth" "this" {
    name = var.cluster_name
}

provider "kubernetes" {
    host = var.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(var.eks_cluster_ca)
    token = data.aws_eks_cluster_auth.this.token
}

locals {
    role_mappings = [
        {
            rolearn = var.node_iam_role_arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups   = ["system:bootstrappers", "system:nodes"]
        }
    ] ++ [
        for arn in var.additional_role_arns : {
            rolearn = arn
            username = "admin:${arn}"
            groups = ["system:masters"]
        }
    ]
}

resource "kubernetes_config_map" "aws_auth" {
    metadata {
        name = "aws-auth"
        namespace = "kube-system"
    }

    data = {
        mapRoles = yamlencode(local.role_mappings)
    }

    lifecycle {
        ignore_changes = [data]
    }
}