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