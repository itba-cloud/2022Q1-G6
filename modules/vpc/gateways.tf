
# Internet Gateway
resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id
}

# NAT Gateway
resource "aws_eip" "this" {
    for_each = aws_subnet.public
    vpc = true

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_nat_gateway" "this" {
    for_each      = aws_subnet.public
    subnet_id     = each.value.id
    allocation_id = aws_eip.this[each.key].id
    
    # To ensure proper ordering, it is recommended to add an explicit dependency
    # on the Internet Gateway for the VPC.
    depends_on = [aws_internet_gateway.this]
}

# Route Tables
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }
}

resource "aws_route_table" "private" {
    for_each = aws_nat_gateway.this
    vpc_id   = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = each.value.id
    }
}


