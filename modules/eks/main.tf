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

    instance_types = var.node_group_config["instance_type"]
    disk_size = var.node_group_config["disk_size"]
    desired_size = var.node_group_config["desired_size"]
    max_size = var.node_group_config["max_size"]
    min_size = var.node_group_config["min_size"]

    depends_on = [module.cluster]
}