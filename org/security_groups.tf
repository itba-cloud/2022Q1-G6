# resource "aws_security_group" "elb_sg" {
#     name        = "elb_sg"
#     description = "Security group for ELB"

#     depends_on = [module.vpc]
#     vpc_id      = module.vpc.id
    
#     ingress {
#         from_port   = 80
#         to_port     = 80
#         protocol    = "tcp"
#         description = "HTTP"
#         cidr_blocks = ["0.0.0.0/0"]
#     } 
    
#     egress {
#         from_port        = 0
#         to_port          = 0
#         protocol         = "-1"
#         cidr_blocks      = ["0.0.0.0/0"]
#         ipv6_cidr_blocks = ["::/0"]
#     }
    
#     tags = {
#         Name = "Security group for ELB"
#     } 
# }