resource "aws_vpc" "this" {
    cidr_block = var.cidr_block
    enable_dns_hostnames = var.enable_dns_hostnames
    enable_dns_support = var.enable_dns_support

    tags = merge(
        var.default_tags,
        { "Name" = "${var.name}-vpc"}
    )
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id

    tags = merge(
        var.default_tags,
        {"Name" = "${var.name}-igw"}
    )
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }

    tags = merge(
        var.default_tags,
        {
            "Name" = "${var.name}-public-rt",
            "Type" = "public"
        }
    )
}

resource "aws_route_table" "private" {
  for_each = toset(var.azs)

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.default_tags,
    {
      "Name" = "${var.name}-private-rt-${each.key}"
      "Type" = "private"
    }
  )
}