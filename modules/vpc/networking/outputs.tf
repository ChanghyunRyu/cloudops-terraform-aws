output "vpc_id" {
    value = aws_vpc.this.id
}

output "igw_id" {
    value = aws_internet_gateway.this.id
}

output "route_table_ids" {
  description = "Public 및 Private Route Table ID 목록"
  value = {
    public  = aws_route_table.public.id
    private = { for az, rt in aws_route_table.private : az => rt.id }
  }
}