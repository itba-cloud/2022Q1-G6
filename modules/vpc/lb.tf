resource "aws_lb" "alb" {  
    name            = "alb"  
    subnets         = [for subnet in aws_subnet.public : subnet.id]
    security_groups = [aws_security_group.elb.id]
    internal        = false 
    idle_timeout    = 60   
    tags = {    
        Name    = "alb"    
    } 

    enable_cross_zone_load_balancing = true
}

resource "aws_lb_target_group" "this" {  
    name     = "alb-target-group"  
    port     = "80"  
    protocol = "HTTP"  
    vpc_id   = aws_vpc.this.id  

    tags = {    
        name = "alb_target_group"    
    }  

    stickiness {    
        type            = "lb_cookie"    
        cookie_duration = 1800    
        enabled         = true 
    }   

    health_check {    
        healthy_threshold   = 3    
        unhealthy_threshold = 10    
        timeout             = 5    
        interval            = 10    
        path                = "/"
        port                = 80
    }
}

resource "aws_lb_listener" "alb_listener" {  
    load_balancer_arn = aws_lb.alb.arn  
    port              = 80  
    protocol          = "HTTP"
    
    default_action {    
        target_group_arn = aws_lb_target_group.this.arn
        type             = "forward"  
    }
}


# Load Balancer Security Group
resource "aws_security_group" "elb" {
    name = "custom-elb-sg"
    description = "Custom ELB Security Group"
    vpc_id = aws_vpc.this.id

    # Inbound Rules
    # HTTP access from anywhere
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }  
    
    # HTTPS access from anywhere
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }  
    
    # SSH access from anywhere
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    # Outbound Rules
    # Internet access to anywhere
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "custom-elb-sg"
    }
}

# Instance Security Group
resource "aws_security_group" "instance" {
    vpc_id = aws_vpc.this.id
    name = "custom-instance-sg"
    description = "security group for instances"

    # Inbound Rules
    # HTTP access from anywhere
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }  
    
    # HTTPS access from anywhere
    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }  
    
    # SSH access from anywhere
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    # Outbound Rules
    # Internet access to anywhere
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "custom-instance-sg"
    }
}