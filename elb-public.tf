
# AWS ALB
resource "aws_lb" "test-project-alb" {
  name               = "test-project-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [module.sn-vpc-test-project-pub-1a.subnet-id, module.sn-vpc-test-project-pub-1b.subnet-id]
  security_groups    = [aws_security_group.sg-vpc-test-project-public.id]
  tags = {
    name = "test-project-alb"
  }
}

# TARGET GROUP
resource "aws_lb_target_group" "test-project-alb-tg-80" {
  name        = "http-80"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = module.vpc-test-project.output-vpc-id
  target_type = "instance"
}

# LISTENER
resource "aws_lb_listener" "test-project-alb-80-listener" {
  load_balancer_arn = aws_lb.test-project-alb.arn
  port              = "80"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test-project-alb-tg-80.arn
  }
}

# OUTPUT LB DNS TO CONSUME
output "alb_dns_name" {
  value = aws_lb.test-project-alb.dns_name
}