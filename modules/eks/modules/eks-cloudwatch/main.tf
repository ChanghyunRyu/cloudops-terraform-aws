resource "aws_eks_addon" "this" {
    cluster_name = var.cluster_name
    addon_name = "amazon-cloudwatch-observability"
    addon_version = var.addon_version
    resolve_conflicts = "OVERWRITE"
    service_account_role_arn = aws_iam_role.this.arn

    tags = merge({"Name" = "${var.name}-eks-addon"}, var.default_tags)
}

resource "aws_iam_role" "this" {
  name = "${var.name}-cloudwatch-IRSA"

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

  tags = var.default_tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.this.name
}


module "cloudwatch_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = aws_iam_role.this.name

  oidc_providers = {
    eks = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["amazon-cloudwatch:cloudwatch-agent"]
    }
  }
}