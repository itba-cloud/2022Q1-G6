# Internet Gateway
resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "internet-gateway"
    }
}

# NAT Gateway
resource "aws_eip" "this" {
    for_each = aws_subnet.public
    vpc = true

    lifecycle {
        prevent_destroy = true
    }

    tags = {
        Name = format("eip-%s", each.key)
    }
}

resource "aws_nat_gateway" "this" {
    for_each      = aws_subnet.public
    subnet_id     = each.value.id
    allocation_id = aws_eip.this[each.key].id
    
    # To ensure proper ordering, it is recommended to add an explicit dependency
    # on the Internet Gateway for the VPC.
    depends_on = [aws_internet_gateway.this]

    tags = {
        Name = format("nat-gateway-%s", each.key)
    }
}


