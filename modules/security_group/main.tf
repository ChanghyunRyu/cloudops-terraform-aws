resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" = var.name
    },
    var.tags
  )
}

# Ingress rules
resource "aws_security_group_rule" "ingress" {
  for_each = {
    for idx, rule in var.ingress_rules : idx => rule
  }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.this.id

  # Optional blocks
  cidr_blocks      = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks = try(each.value.ipv6_cidr_blocks, null)
  source_security_group_id = length(try(each.value.security_groups, [])) > 0 ? element(each.value.security_groups, 0) : null
  self             = try(each.value.self, null)
  description      = try(each.value.description, null)
}

# Egress rules
resource "aws_security_group_rule" "egress" {
  for_each = {
    for idx, rule in var.egress_rules : idx => rule
  }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.this.id

  # Optional blocks
  cidr_blocks      = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks = try(each.value.ipv6_cidr_blocks, null)
  source_security_group_id = length(try(each.value.security_groups, [])) > 0 ? element(each.value.security_groups, 0) : null
  self             = try(each.value.self, null)
  description      = try(each.value.description, null)
}
