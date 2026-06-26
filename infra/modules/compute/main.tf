# Compute module — the public ALB (with WAF attached) and the EC2 Auto Scaling
# Group that runs the node API in the private app subnets.

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# --- Public load balancer ---
resource "aws_lb" "app" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
  tags               = { Name = "${var.name}-alb" }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
    matcher             = "200"
  }
  tags = { Name = "${var.name}-tg" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Attach the regional WAF web ACL to the ALB.
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.app.arn
  web_acl_arn  = var.waf_web_acl_arn
}

# --- App tier: launch template + ASG ---
resource "aws_launch_template" "app" {
  name_prefix            = "${var.name}-app-"
  image_id               = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.app_sg_id]

  user_data = base64encode(<<-EOT
    #!/bin/bash
    set -euo pipefail
    dnf install -y nodejs git
    # In a real deploy you'd pull a versioned artifact; this is the demo shape.
    cat >/etc/wedding-register.env <<ENV
    PORT=${var.app_port}
    DB_HOST=${var.db_host}
    DB_PORT=3306
    DB_NAME=${var.db_name}
    ENV
    echo "wedding-register app instance booted..."
  EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.name}-app", Tier = "app" }
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "${var.name}-asg"
  vpc_zone_identifier = var.app_subnet_ids
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-app"
    propagate_at_launch = true
  }
}
