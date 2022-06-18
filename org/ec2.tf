# module "ec2" {
#     count = length(local.vpc.private_subnets)
#     source = "../modules/ec2"

#     instance_size = local.ec2.instance.instance_type
#     instance_ami = data.aws_ami.app.id
#     subnet_id = keys(module.vpc.vpc_private_subnets)[count.index]
#     create_eip = false

#     providers = {
#         aws = aws.aws
#     }
# }

# resource "aws_security_group" "this" {
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

# resource "aws_launch_configuration" "this" {
#     name_prefix   = "app-launch-config"
#     image_id      =  data.aws_ami.app.id
#     instance_type = "t2.micro"
#     # key_name = var.keyname
#     # security_groups = ["${aws_security_group.webserver_sg.id}"]
    
#     root_block_device {
#         volume_type = "gp2"
#         volume_size = 10
#         encrypted   = true
#     }  
            
#     lifecycle {
#         create_before_destroy = true
#     }

#     # user_data = filebase64("${path.module}/init_webserver.sh")
# }

# resource "aws_lb_target_group" "this" {
#     name     = "Demo-TargetGroup-tf"
#     depends_on = [module.vpc]
#     port     = 80
#     protocol = "HTTP"
#     vpc_id   = module.vpc.id
#     # health_check {
#     #     interval            = 70
#     #     path                = "/index.html"
#     #     port                = 80
#     #     healthy_threshold   = 2
#     #     unhealthy_threshold = 2
#     #     timeout             = 60 
#     #     protocol            = "HTTP"
#     #     matcher             = "200,202"
#     # }
# }

# # Create Auto Scaling Group
# resource "aws_autoscaling_group" "Demo-ASG-tf" {
#     name               = "Demo-ASG-tf"
#     desired_capacity   = 1
#     max_size           = 2
#     min_size           = 1
#     force_delete       = true
#     depends_on         = [aws_lb.this]
#     target_group_arns  =  [aws_lb_target_group.this.arn]
#     health_check_type  = "EC2"
#     launch_configuration = aws_launch_configuration.this.name
#     vpc_zone_identifier = keys(module.vpc.vpc_private_subnets)
    
#     tag {
#         key                 = "Name"
#         value               = "Demo-ASG-tf"
#         propagate_at_launch = true
#     }
# }

# resource "aws_lb" "this" {
#     name                 = "Demo-ALG-tf"
#     internal            = false
#     load_balancer_type  = "application"
#     security_groups     = [aws_security_group.this.id]
#     subnets             = keys(module.vpc.vpc_private_subnets)
#     tags = {
#         name  = "Demo-AppLoadBalancer-tf"
#         Project = "demo-assignment"
#     }
# }

# # Create ALB Listener
# resource "aws_lb_listener" "this" {
#     load_balancer_arn   = aws_lb.this.arn
#     port                = "80"
#     protocol            = "HTTP"
#     default_action {
#         type             = "forward"
#         target_group_arn = aws_lb_target_group.this.arn
#     }
# }