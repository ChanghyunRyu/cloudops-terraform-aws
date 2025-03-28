resource "aws_eks_addon" "cloudwatch" {
  cluster_name = var.cluster_name
  addon_name = "amazon-cloudwatch-observability"
  addon_version = var.addon_version
  resolve_conflicts = "OVERWRITE"
  service_account_role_arn = var.irsa_role_arn

  tags = merge({"Name" = "${var.name}-eks-addon"}, var.default_tags)
  
  depends_on = [var.dependency]
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = var.irsa_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}