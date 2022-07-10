resource "aws_lb" "this" {
  provider = aws.aws

  name            = "alb"
  subnets         = keys(module.vpc.vpc_public_subnets)
  security_groups = [aws_security_group.elb.id]
  internal        = false
  idle_timeout    = 60

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "ec2-application-load-balancer"
  }
}

resource "aws_lb_target_group" "this" {
  provider = aws.aws
  name     = "alb-target-group"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

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

  tags = {
    Name = "ec2-alb-target-group"
  }
}

resource "aws_lb_listener" "alb_listener" {
  provider          = aws.aws
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }

  tags = {
    Name = "ec2-alb-listener"
  }
}