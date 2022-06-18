resource "aws_instance" "this" {
    ami             = var.instance_ami
    instance_type   = var.instance_size

    subnet_id = var.subnet_id
    vpc_security_group_ids = var.security_groups

}

resource "aws_eip" "this" {
    # IF it is true then create else don't
    count = var.create_eip ? 1 : 0

    vpc = true

    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_eip_association" "eip_assoc" {
    # IF it is true then create else don't
    count = var.create_eip ? 1 : 0

    instance_id = aws_instance.this.id
    allocation_id = aws_eip.this[0].id
}