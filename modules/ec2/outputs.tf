output "app_eip" {
    value = aws_eip.this.*.public_ip
}

output "app_instance" {
    value = aws_instance.this.id
}