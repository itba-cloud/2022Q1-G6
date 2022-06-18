variable instance_size {
    type = string
    description = "Size of the ec2 web server"
    default = "t3.small"
}

variable instance_ami {
    type = string
    description = "AMI to use for the ec2 web server"
}

variable instance_root_device_size {
    type = number
    description = "Root block device size in GB"
    default = 12
}

variable subnet_id {
    type = string
    description = "Subnets to use for the ec2 web server"
}

variable security_groups {
    type = list(string)
    description = "Security groups to use for the ec2 web server"
    default = []
}

variable create_eip {
    type = bool
    description = "Create an Elastic IP address for the ec2 web server"
    default = false
}