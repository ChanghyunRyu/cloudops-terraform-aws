locals {
    default_tags = merge({
        "Project" = var.name
        "ManagedBy" = "Terraform"
    },
    var.tags)
}

###############################################
####              Providers                ####
###############################################

data "aws_eks_cluster_auth" "this" {
    name = var.eks_cluster_name
}

data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
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
    host = var.eks_cluster_name
    cluster_ca_certificate = base64decode(var.eks_cluster_certificate_authority)
    token = data.aws_eks_cluster_auth.token
}

provider "helm" {
  kubernetes {
    host = module.cluster.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.cluster.eks_cluster_certificate_authority)
    token = data.aws_eks_cluster_auth.token
  }
}

# These blocks are for configuration of EKS
module "aws_auth" {
  source = "./aws_auth"

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
      rolearn  = var.node_group_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]
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
    source = "./bastion"

    count = var.enable_bastion ? 1 : 0

    bastion_role_name = aws_iam_role.bastion_role.name
    name = var.name
    vpc_id = var.vpc_id
    subnet_id = var.subnet_id
    cluster_name = var.eks_cluster_name

    instance_type = "t3.medium"
    key_name = var.key_name

    default_tags = local.default_tags
}

###############################################
####              Cloudwatch               ####
###############################################

resource "aws_iam_role" "cloudwatch_irsa" {
  name = "${var.name}-cloudwatch-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
        }
      }
    }]
  })
}

module "eks_cloudwatch" {
  source = "./eks-cloudwatch"

  name = var.name
  addon_version = "v3.5.0-eksbuild.1"
  cluster_name = var.eks_cluster_name
  irsa_role_arn = aws_iam_role.cloudwatch_irsa.arn
  irsa_role_name = aws_iam_role.cloudwatch_irsa.name

  default_tags = local.default_tags
}

###############################################
####            lb-controller              ####
###############################################

data "aws_iam_policy_document" "lb_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "lb_controller_irsa" {
  name               = "${var.name}-lb-controller-irsa"
  assume_role_policy = data.aws_iam_policy_document.lb_assume_role_policy.json
}

module "lb_controller" {
  source = "./modules/eks-lb-controller"

  providers = {helm = helm}

  name = var.name
  cluster_name = var.eks_cluster_name
  vpc_id = var.vpc_id
  region = var.region
  service_account_name = "${var.name}-aws-load-balancer-controller"
  
  lb_controller_irsa_name = aws_iam_role.lb_controller_irsa.name
  lb_controller_irsa_arn = aws_iam_role.lb_controller_irsa.arn
}