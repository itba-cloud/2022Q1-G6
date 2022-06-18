data "aws_ami" "app" {
	# provider = aws.aws
	most_recent = true

	filter {
		name   = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
	}

	filter {
		name   = "virtualization-type"
		values = ["hvm"]
	}

	filter {
		name   = "architecture"
		values = ["x86_64"]
	}

	owners = ["099720109477"] # Canonical official
}


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
    map_public_ip_on_launch = false

    cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 4, each.value)
}

resource "aws_security_group" "this" {
    name        = "alb_sg"
    description = "Security group for ALB"

    depends_on = [aws_vpc.this]
    vpc_id      = aws_vpc.this.id
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        description = "HTTP"
        cidr_blocks = ["0.0.0.0/0"]
    } 
    
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
    
    tags = {
        Name = "Security group for ALB"
    } 
}

resource "aws_launch_configuration" "this" {
    name_prefix   = "app-launch-config"
    image_id      =  data.aws_ami.app.id
    instance_type = "t2.micro"
    # key_name = var.keyname
    security_groups = [aws_security_group.this.id]
    user_data = "${file("/Users/ines/HEAVY/cloud-tp3/modules/vpc/initiate.sh")}"
    
    root_block_device {
        volume_type = "gp2"
        volume_size = 10
        encrypted   = true
    }  
            
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_lb_target_group" "this" {
    depends_on  = [aws_alb.this]
    port        = 80
    protocol    = "HTTP"
    target_type = "instance"
    vpc_id   = aws_vpc.this.id

    # health_check {
    #     enabled = true
    #     path    = "/health"
    # }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "Demo-ASG-tf" {
    name               = "Demo-ASG-tf"
    desired_capacity   = 2
    max_size           = 5
    min_size           = 2
    force_delete       = true
    depends_on         = [aws_alb.this]

    target_group_arns  =  [aws_lb_target_group.this.arn]
    health_check_type  = "EC2"
    launch_configuration = aws_launch_configuration.this.name
    vpc_zone_identifier = [aws_subnet.public["us-east-1a"].id, aws_subnet.public["us-east-1b"].id] // TODO: change
    
}

resource "aws_alb" "this" {
    name                 = "Demo-ALG-tf"
    internal            = true
    load_balancer_type  = "application"
    security_groups     = [aws_security_group.this.id]
    subnets = [aws_subnet.private["us-east-1a"].id, aws_subnet.private["us-east-1b"].id] // TODO: change

    tags = {
        name  = "Demo-AppLoadBalancer-tf"
        Project = "demo-assignment"
    }
}

# # Create ALB Listener
resource "aws_lb_listener" "this" {
    load_balancer_arn   = aws_alb.this.arn
    port                = "80"
    protocol            = "HTTP"
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.this.arn
    }
}
