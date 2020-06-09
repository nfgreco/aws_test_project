
# APACHE EC2 INSTANCE + ALB ATTACHMENT
resource "aws_instance" "test-project-apache-01dv" {
  ami                    = "ami-085925f297f89fce1"
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.sg-vpc-test-project-private.id]
  subnet_id              = module.sn-vpc-test-project-priv-1a.subnet-id
  user_data              = templatefile("./files/user_data_ec2.tmpl", { webserver = "apache2" })

  tags = {
    Name = "test-project-apache-01dv"
  }
}

resource "aws_lb_target_group_attachment" "test-project-apache-01dv-attach" {
  target_id        = aws_instance.test-project-apache-01dv.id
  target_group_arn = aws_lb_target_group.test-project-alb-tg-80.arn
  port             = "80"
}

# NGINX EC2 INSTANCE + ALB ATTACHMENT
resource "aws_instance" "test-project-nginx-01dv" {
  ami                    = "ami-085925f297f89fce1"
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.sg-vpc-test-project-private.id]
  subnet_id              = module.sn-vpc-test-project-priv-1b.subnet-id
  user_data              = templatefile("./files/user_data_ec2.tmpl", { webserver = "nginx" })
  tags = {
    Name = "test-project-nginx-02dv"
  }
}

resource "aws_lb_target_group_attachment" "test-project-nginx-01dv" {
  target_id        = aws_instance.test-project-nginx-01dv.id
  target_group_arn = aws_lb_target_group.test-project-alb-tg-80.arn
  port             = "80"
}