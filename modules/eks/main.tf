locals {
    default_tags = merge({
        "Project" = var.name
        "ManagedBy" = "Terraform"
    },
    var.tags)
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = module.cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.cluster.eks_cluster_certificate_authority)
  token                  = module.cluster.kube_token
}

module "cluster" {
    source = "./modules/cluster"

    name =  var.name
    vpc_id = var.vpc_id
    private_subnet_ids = var.private_subnet_ids
    kubernetes_version = var.kubernetes_version

    default_tags = local.default_tags
    cluster_enabled_log_types = var.cluster_enabled_log_types

    node_group_role_arn = aws_iam_role.node_group_role.arn
    bastion_role_arn = aws_iam_role.bastion_role.arn
}

###############################################
####              Node Group               ####
###############################################

resource "aws_iam_role" "node_group_role" {
  name = "${var.name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.default_tags
}

module "node_group" {
    source = "./modules/node_group"

    name = var.name
    cluster_name = module.cluster.eks_cluster_name
    private_subnet_ids = var.private_subnet_ids
    default_tags = local.default_tags

    node_group_role_name = aws_iam_role.node_group_role.name
    node_group_role_arn = aws_iam_role.node_group_role.arn

    instance_types = var.instance_types
    disk_size = var.disk_size
    desired_size = var.scaling_config["desired_size"]
    max_size = var.scaling_config["max_size"]
    min_size = var.scaling_config["min_size"]

}

###############################################
####             Bastion Host              ####
###############################################

resource "aws_iam_role" "bastion_role" {
    name = "${var.name}-bastion-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
            Service = "ec2.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }]
    })

    tags = local.default_tags
}

module "bastion" {
    source = "./modules/bastion"

    count = var.enable_bastion ? 1 : 0

    bastion_role_name = aws_iam_role.bastion_role.name
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
    token = module.cluster.kube_token
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
      rolearn  = aws_iam_role.bastion_role.arn
      username = "admin:bastion"
      groups   = ["system:masters"]
    },
    {
      rolearn  = aws_iam_role.node_group_role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]

  depends_on = [module.cluster]
}