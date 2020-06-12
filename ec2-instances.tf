# SEARCHING LATEST UBUNTU AMI
data "aws_ami" "ubuntu-18-latest" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# APACHE EC2 INSTANCE + ALB ATTACHMENT
resource "aws_instance" "test-project-apache-01dv" {
  ami                    = data.aws_ami.ubuntu-18-latest.image_id
  instance_type          = "t3.medium"
  vpc_security_group_ids = [module.vpc-test-project.private_security_group_id]
  subnet_id              = module.vpc-test-project.private_subnet_ids[0]
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
  ami                    = data.aws_ami.ubuntu-18-latest.image_id
  instance_type          = "t3.medium"
  vpc_security_group_ids = [module.vpc-test-project.private_security_group_id]
  subnet_id              = module.vpc-test-project.private_subnet_ids[1]
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