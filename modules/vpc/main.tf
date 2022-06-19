resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
}

# Create a public subnet for each AZ in variables
resource "aws_subnet" "public" {
    for_each = var.public_subnet_numbers

    vpc_id = aws_vpc.this.id
    availability_zone = each.key

    cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 4, each.value)

    tags = {
        Name = format("public-subnet-%s",each.key)
    }
}

# Create a private subnet for each AZ in variables
resource "aws_subnet" "private" {
    for_each = var.private_subnet_numbers

    vpc_id = aws_vpc.this.id
    availability_zone = each.key
    map_public_ip_on_launch = false

    cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 4, each.value)

    tags = {
        Name = format("private-subnet-%s",each.key)
    }
}

# Route Tables
resource "aws_route_table" "public" {
    for_each = aws_subnet.public
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }

    tags = {
        Name = format("public-subnet-route-table-%s", each.key)
    }
}

resource "aws_route_table" "private" {
    for_each = aws_nat_gateway.this
    vpc_id   = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = each.value.id
    }

    tags = {
        Name = format("private-subnet-route-table-%s", each.key)
    }
}

resource "aws_route_table_association" "public" {
    for_each = aws_subnet.public
    subnet_id = each.value.id
    route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route_table_association" "private" {
    for_each = aws_subnet.private
    subnet_id = each.value.id
    route_table_id = aws_route_table.private[each.key].id
}

