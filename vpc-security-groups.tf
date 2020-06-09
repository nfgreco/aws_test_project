
# PRIVATE SG
resource "aws_security_group" "sg-vpc-test-project-private" {
  name        = "SG-vpc-test-project-private"
  description = "SG-vpc-test-project-private"
  vpc_id      = module.vpc-test-project.output-vpc-id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-vpc-test-project-private"
  }
}

# PUBLIC SG
resource "aws_security_group" "sg-vpc-test-project-public" {
  name        = "SG-vpc-test-project-public"
  description = "SG-vpc-test-project-public"
  vpc_id      = module.vpc-test-project.output-vpc-id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-vpc-test-project-private"
  }
}
