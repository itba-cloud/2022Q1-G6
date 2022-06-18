module "vpc" {
    source   = "../modules/vpc"

    vpc_cidr = local.vpc.vpc_cidr
    public_subnet_numbers = local.vpc.public_subnets
    private_subnet_numbers = local.vpc.private_subnets

    providers = {
        aws = aws.aws
    }

}