output "alb_dns_name" {
  description = "Public DNS of the ALB — the registry's front door."
  value       = aws_lb.app.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.app.arn
}
