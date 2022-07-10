# autoscaling launch configuration
resource "aws_launch_configuration" "this" {
  provider      = aws.aws
  name_prefix   = "custom-launch-configuration-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = local.ec2.instance_type

  security_groups = [aws_security_group.instance.id]

  user_data = file("../modules/vpc/initiate.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# autoscaling group
resource "aws_autoscaling_group" "this" {
  provider             = aws.aws
  name                 = "custom-autoscaling-group"
  vpc_zone_identifier  = keys(module.vpc.vpc_private_subnets)
  launch_configuration = aws_launch_configuration.this.name
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2

  health_check_grace_period = 100
  health_check_type         = "ELB"
  target_group_arns         = [aws_lb_target_group.this.arn]

  force_delete = true
  tag {
    key                 = "Name"
    value               = "custom-ec2-instance"
    propagate_at_launch = true
  }
}

# autoscaling policy
resource "aws_autoscaling_policy" "scaling" {
  provider               = aws.aws
  name                   = "scaleup-autoscaling-policy"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}

# autoscaling watch alarm
resource "aws_cloudwatch_metric_alarm" "scaling" {
  provider            = aws.aws
  alarm_name          = "cpu-alarm-scaleup"
  alarm_description   = "alarm once cpu usage increases"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.this.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.scaling.arn]

  tags = {
    Name = "cpu-alarm-scaleup"
  }
}


# auto descaling policy
resource "aws_autoscaling_policy" "descaling" {
  provider               = aws.aws
  name                   = "scaledown-autoscaling-policy"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 60
  policy_type            = "SimpleScaling"
}


# descaling cloud watch
resource "aws_cloudwatch_metric_alarm" "descaling" {
  provider            = aws.aws
  alarm_name          = "cpu-alarm-scaledown"
  alarm_description   = "alarm once cpu usage decreases"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 10

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.this.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.descaling.arn]

  tags = {
    Name = "cpu-alarm-scaledown"
  }
}