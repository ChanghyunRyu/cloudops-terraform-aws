output "vpc_id" {
    value = module.networking.vpc_id
}

output "igw_id" {
    value = module.networking.igw_id
}

output "route_table_ids" {
    value = module.networking.route_table_ids
}

output "public_subnet_ids" {
  value = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.subnets.private_subnet_ids
}

output "nat_gateway_ids" {
  value = module.subnets.nat_gateway_ids
} 