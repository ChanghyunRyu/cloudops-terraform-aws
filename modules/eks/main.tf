locals {
    default_tags = merge({
        "Project" = var.name
        "ManagedBy" = "Terraform"
    },
    var.tags)
}

module "cluster" {
    source = "./modules/cluster"

    name =  var.name
    vpc_id = var.vpc_id
    private_subnet_ids = var.private_subnet_ids
    kubernetes_version = var.kubernetes_version

    default_tags = local.default_tags
    cluster_enabled_log_types = var.cluster_enabled_log_types
}

module "node_group" {
    source = "./modules/node_group"

    name = var.name
    cluster_name = module.cluster.eks_cluster_name
    private_subnet_ids = var.private_subnet_ids
    default_tags = local.default_tags

    instance_types = var.instance_types
    disk_size = var.disk_size
    desired_size = var.scaling_config["desired_size"]
    max_size = var.scaling_config["max_size"]
    min_size = var.scaling_config["min_size"]

}

###############################################
####             Bastion Host              ####
###############################################

module "bastion" {
    source = "./modules/bastion"

    count = var.enable_bastion ? 1 : 0

    name = var.name
    vpc_id = var.vpc_id
    subnet_id = var.public_subnet_ids[0]
    cluster_name = module.cluster.eks_cluster_name

    instance_type = "t3.medium"
    key_name = null

    default_tags = local.default_tags
}

###############################################
####              Providers                ####
###############################################

data "aws_eks_cluster_auth" "this" {
    name = module.cluster.eks_cluster_name

    depends_on = [module.cluster]
}

data "aws_eks_cluster" "this" {
  name = module.cluster.eks_cluster_name

  depends_on = [module.cluster]
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

provider "kubernetes" {
    host = module.cluster.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster.eks_cluster_certificate_authority)
    token = data.aws_eks_cluster_auth.this.token
}

###############################################
####              EKS tools                ####
###############################################

# These blocks are for configuration of EKS

module "aws_auth" {
  source = "./modules/aws_auth"

  providers = {
    kubernetes = kubernetes
  }

  role_mapping = [
    {
      rolearn  = module.bastion[0].bastion_iam_role_arn
      username = "admin:bastion"
      groups   = ["system:masters"]
    },
    {
      rolearn  = module.node_group.node_group_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]

}

module "cloudwatch" {
  source = "./modules/eks-cloudwatch"
  name = var.name

  cluster_name = module.cluster.eks_cluster_name
  oidc_provider_arn = aws_iam_openid_connect_provider.eks.arn

  default_tags = local.default_tags
}