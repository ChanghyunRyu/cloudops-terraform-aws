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
    desired_size = var.scaling_config['desired_size']
    max_size = var.scaling_config['max_size']
    min_size = var.scaling_config['min_size']
}

module "bastion" {
    source = "./modules/bastion"

    count = var.enable_bastion ? 1 : 0

    name = var.name
    vpc_id = var.vpc_id
    subnet_id = var.public_subnet_ids[0]
    cluster_name = module.cluster.eks_cluster_name

    instance_type = "t3.medium"
    key_name = var.key_name

    default_tags = local.default_tags
}

module "aws-auth" {
    source = "./modules/aws_auth"

    cluster_name = module.cluster.eks_cluster_name
    eks_cluster_endpoint = module.cluster.eks_cluster_endpoint
    eks_cluster_ca = module.cluster.eks_cluster_certificate_authority
    node_iam_role_arn = module.node_group.node_group_iam_role_arn

    additional_role_arns = var.enable_bastion ? [module.bastion[0].bastion_iam_role_arn] : []
    default_tags = local.default_tags
}