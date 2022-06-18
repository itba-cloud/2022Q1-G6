resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
}

# Create a public subnet for each AZ in variables
resource "aws_subnet" "public" {
    for_each = var.public_subnet_numbers

    vpc_id = aws_vpc.this.id
    availability_zone = each.key

    cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 4, each.value)
}

resource "aws_subnet" "private" {
    for_each = var.private_subnet_numbers

    vpc_id = aws_vpc.this.id
    availability_zone = each.key

    cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 4, each.value)
}
