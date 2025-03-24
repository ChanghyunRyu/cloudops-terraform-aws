###############################################
####               subnets                 ####
###############################################

# Public Subnets
resource "aws_subnet" "public" {
    for_each = {
        for idx, az in var.azs : az => {
            cidr_block = var.public_subnet_cidrs[idx]
            name = var.public_subnet_names[idx]
        }
    }

    vpc_id = var.vpc_id
    cidr_block = each.value.cidr_block
    availability_zone = each.key
    map_public_ip_on_launch = true

    tags = merge(
        var.default_tags,
        {
            "Name" = each.value.name
        }
    )
}

# Private Subnets
resource "aws_subnet" "private" {
    for_each = {
        for idx, az in var.azs : az => {
            cidr_block = var.private_subnet_cidrs[idx]
            name = var.private_subnet_names[idx]
        }
    }

    vpc_id = var.vpc_id
    cidr_block = each.value.cidr_block
    availability_zone = each.key
    map_public_ip_on_launch = false

    tags = merge(
        var.default_tags,
        {
            "Name" = each.value.name
        }
    )
}

###############################################
####             NAT Gateway               ####
###############################################

# NAT Gateway EIP
resource "aws_eip" "nat" {
    for_each = var.enable_nat_gateway ? toset(var.nat_gateway_azs) : toset([])

    domain = "vpc"

    tags = merge(
        var.default_tags,
        {
            "Name" = "${var.name}-eip-${each.key}"
        }
    )
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
    for_each = var.enable_nat_gateway ? toset(var.nat_gateway_azs) : toset([])

    allocation_id = aws_eip.nat[each.key].id
    subnet_id = aws_subnet.public[each.key].id

    tags = merge(
        var.default_tags,
        {
            "Name" = "${var.name}-natgw-${each.key}"
        }
    )
}


###############################################
####             Route table               ####
###############################################

# Route Table Association (public)
resource "aws_route_table_association" "public" {
    for_each = aws_subnet.public

    subnet_id = each.value.id
    route_table_id = var.route_table_ids.public
}

# Route Table Association (public)
resource "aws_route_table_association" "private" {
    for_each = aws_subnet.private

    subnet_id = each.value.id
    route_table_id = var.route_table_ids.private[each.key]
}

locals {
  private_route_nat_mapping = {
    for az in var.azs : az => (
      var.single_nat_gateway ? var.nat_gateway_azs[0] : az
    )
  }
}

resource "aws_route" "private_nat" {
    for_each = var.enable_nat_gateway ? local.private_route_nat_mapping : {}

    route_table_id = var.route_table_ids.private[each.key]
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.value].id
}