resource "aws_launch_template" "web_app_template" {
  name_prefix   = "web-app-"
  image_id      = "ami-058c59a90c1319653"  # Amazon Linux 2 for us-west-1
  instance_type = "t2.micro"

  user_data = base64encode(file("${path.module}/setup-apps.sh"))

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-app-instance"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity     = 3
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.public_subnet_1.id]

  launch_template {
    id      = aws_launch_template.web_app_template.id
    version = "$Latest"
  }

  # ✅ NEW: Attach Auto Scaling Group to ALB Target Group
  target_group_arns = [aws_lb_target_group.web_app_tg.arn]

  tag {
    key                 = "Name"
    value               = "web-app-instance"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
}

