
# OUTPUT LB DNS TO CONSUME
output "alb_dns_name" {
  value = aws_lb.test-project-alb.dns_name
}