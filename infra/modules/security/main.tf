# Security module — the three security groups (one per tier, each only opening
# to the tier in front of it) and the regional WAF web ACL for the ALB.

# ALB: open to the internet on 80/443.
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Public ingress to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name}-alb-sg" }
}

# App tier: only the ALB may reach the API port.
resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  description = "App tier — ingress only from the ALB"
  vpc_id      = var.vpc_id

  ingress {
    description     = "API from ALB"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name}-app-sg" }
}

# Data tier: only the app tier may reach MySQL.
resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "Data tier — ingress only from the app tier"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from app tier"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name}-db-sg" }
}

# Regional WAF for the ALB — AWS managed common rule set + a simple rate limit.
resource "aws_wafv2_web_acl" "this" {
  name        = "${var.name}-waf"
  scope       = "REGIONAL"
  description = "WAF in front of the wedding-register ALB"

  default_action {
    allow {}
  }

  rule {
    name     = "aws-common"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-common"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "rate-limit"
    priority = 2
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name}-rate"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name}-waf"
    sampled_requests_enabled   = true
  }

  tags = { Name = "${var.name}-waf" }
}
