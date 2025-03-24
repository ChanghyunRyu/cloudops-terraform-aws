output "public_subnet_ids" {
    value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
    value = [for subnet in aws_subnet.private : subnet.id]
}

output "nat_gateway_ids" {
    value = {
        for az, nat in aws_nat_gateway.this : az => nat.id
    }
}