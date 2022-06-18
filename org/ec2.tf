module "ec2" {
    count = length(local.vpc.private_subnets)
    source = "../modules/ec2"

    instance_size = local.ec2.instance.instance_type
    instance_ami = data.aws_ami.app.id
    subnet_id = keys(module.vpc.vpc_private_subnets)[count.index]
    create_eip = false

    providers = {
        aws = aws.aws
    }
}