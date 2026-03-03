# -------- Fetch Latest Ubuntu AMI method 2 --------
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# ---------------- Launch Template ----------------
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project_name}-lt"   
  image_id      = data.aws_ssm_parameter.ubuntu_ami.value        
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(file("userdata.sh"))

  metadata_options {                                    # IMDSv2 only No IMDSv1 fallback (Keep it if required)
    http_tokens = "required"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-instance"
    }
  }
}

# ---------------- Auto Scaling Group ----------------
resource "aws_autoscaling_group" "app_asg" {
  name            = "${var.project_name}-asg"
  desired_capacity = 2
  max_size        = 3
  min_size        = 2

  vpc_zone_identifier = [
    aws_subnet.private_app_az1.id,
    aws_subnet.private_app_az2.id
  ]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  # instance_refresh {
  #   strategy = "Rolling"
  # }

  #or

  # instance_refresh {
  # strategy = "Rolling"

  # preferences {
  #   min_healthy_percentage = 50
  # }

  # triggers = ["launch_template"]
  # }

  
  target_group_arns = [aws_lb_target_group.app_tg.arn]

  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}


# ---------------- Auto Scaling Target Tracking ----------------
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${var.project_name}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50
  }
}