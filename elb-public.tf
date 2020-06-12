
# AWS ALB
resource "aws_lb" "test-project-alb" {
  name               = "test-project-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc-test-project.public_subnet_ids
  security_groups    = [module.vpc-test-project.public_security_group_id]
  tags = {
    name = "test-project-alb"
  }
}

# TARGET GROUP
resource "aws_lb_target_group" "test-project-alb-tg-80" {
  name        = "http-80"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = module.vpc-test-project.vpc_id
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