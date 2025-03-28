# get terraform-vpc_id
data "aws_instances" "terraform_ec2" {
    filter {
        name = "tag:Name"
        values = ["kakao-terraform"]
    }
}

data "aws_instance" "terraform_ec2" {
  instance_id = data.aws_instances.terraform_ec2.ids[0] 
}

data "aws_subnet" "shared_subnet" {
    id = data.aws_instance.terraform_ec2.subnet_id
}

data "aws_vpc" "shared_vpc" {
    id = data.aws_subnet.shared_subnet.vpc_id
}

data "aws_route_tables" "shared_route_tables" {
    vpc_id = data.aws_vpc.shared_vpc.id
}


module "vpc" {
    source = "../../modules/vpc"
    name = "dev"
    cidr_block = "10.10.0.0/16"
    azs = ["ap-northeast-2a", "ap-northeast-2c"]

    custom_subnet_tags = {
        public = {
            "kubernetes.io/cluster/dev-cluster" = "shared"
            "kubernetes.io/role/elb"            = "1"
        }
        private = {
            "kubernetes.io/cluster/dev-cluster" = "shared"
            "kubernetes.io/role/internal-elb"   = "1"
        }
    }

    enable_peering = true

    peer_vpc_id = data.aws_vpc.shared_vpc.id
    peer_cidr_block = data.aws_vpc.shared_vpc.cidr_block
    peer_route_table_ids = data.aws_route_tables.shared_route_tables.ids
}

module "eks" {
    source = "../../modules/eks"

    name = "dev"
    vpc_id = module.vpc.vpc_id
    private_subnet_ids = module.vpc.private_subnet_ids
    public_subnet_ids = module.vpc.public_subnet_ids

    tags = {
        Enviroment = "dev"
        Terraform = "true"
    }

    kubernetes_version = "1.32"

    node_group_config = {
        instance_type = ["t3.medium"]
        disk_size = 30
        desired_size = 2
        min_size     = 1
        max_size     = 6
    }
}

module "eks_resource" {
    source = "../../modules/eks-resource"

    name = "dev"
    vpc_id = module.vpc.vpc_id
    
    tags = {
        Enviroment = "dev"
        Terraform = "true"
    }

    eks_cluster_name = module.eks.eks_cluster_name
    eks_cluster_certificate_authority = module.eks.eks_cluster_certificate_authority
    eks_cluster_endpoint = module.eks.eks_cluster_endpoint

    node_group_role_arn = module.eks.node_group_role_arn

    enable_bastion = true
    subnet_id = module.vpc.public_subnet_ids[0]
    region = "ap-northeast-2"
}

module "argocd" {
    source = "../../modules/argocd"

    eks_cluster_name = module.eks.eks_cluster_name
    eks_cluster_certificate_authority = module.eks.eks_cluster_certificate_authority
    eks_cluster_endpoint = module.eks.eks_cluster_endpoint

    install_argocd = true
    application_yamls = []
}