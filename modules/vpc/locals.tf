locals {
    default_tags = merge({
        "Project" = var.name
        "ManagedBy" = "Terraform"
    },
    var.tags)

    public_subnet_cidrs = [
        for i in range(length(var.azs)) :
        cidrsubnet(var.vpc_cidr_block, 8, i)
    ]

    private_subnet_cidrs = [
        for i in range(length(var.azs)) :
        cidrsubnet(var.vpc_cidr_block, 8, i + 10)
    ]

    nat_gateway_azs = var.single_nat_gateway ? [var.azs[0]] : var.azs

    public_subnet_tags = try(var.custom_subnet_tags["public"], {})
    private_subnet_tags = try(var.custom_subnet_tags["private"], {})

    public_subnet_names = [
        for az in var.azs :
        "${var.name}-public-${az}"
     ]

    private_subnet_names = [
        for az in var.azs :
        "${var.name}-private-${az}"
    ]
}