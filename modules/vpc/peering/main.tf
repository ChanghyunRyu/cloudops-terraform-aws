resource "aws_vpc_peering_connection" "this" {
    vpc_id = var.requester_vpc_id
    peer_vpc_id = var.accepter_vpc_id
    auto_accept = false
}

resource "aws_route" "requester_to_accepter" {
    for_each = toset(var.requester_route_table_ids)

    route_table_id = each.value
    destination_cidr_block = var.accepter_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

locals {
  accepter_route_table_map = {
    for idx, rt_id in local.accepter_route_table_id_list :
    "rt-${idx}" => rt_id
  }
}

resource "aws_route" "accepter_to_requester" {
    for_each = local.accepter_route_table_map

    route_table_id = each.value
    destination_cidr_block = var.requester_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
    vpc_peering_connection_id = aws_vpc_peering_connection.this.id
    auto_accept = true
}