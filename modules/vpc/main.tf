module "networking" {
    source = "./modules/networking"

    name = var.name
    cidr_block = var.cidr_block
    enable_dns_support = var.enable_dns_support
    enable_dns_hostnames = var.enable_dns_hostnames
    default_tags = local.default_tags

    azs = var.azs
}

module "subnet" {
    source = "./modules/subnets"

    name = var.name
    azs = var.azs
    public_subnet_cidrs = locals.public_subnet_cidrs
    private_subnet_cidrs = locals.private_subnet_cidrs
    public_subnet_count = var.public_subnet_count
    private_subnet_count = var.private_subnet_count

    public_subnet_tags = locals.public_subnet_tags
    private_subnet_tags = locals.private_subnet_tags

    nat_gateway_azs = locals.nat_gateway_azs
    enable_nat_gateway = var.enable_nat_gateway
    single_nat_gateway = var.single_nat_gateway

    vpc_id = module.networking.vpc_id
    igw_id = module.networking.igw_id
    route_table_ids = module.networking.route_table_ids

    default_tags = local.default_tags
}