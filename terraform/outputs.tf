output "alb_host" {
  value       = aws_lb.main.dns_name
  description = "Load balancer host"
}
