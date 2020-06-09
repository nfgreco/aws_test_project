# VPC CREATION
module "vpc-test-project" {
  source = "./module/aws-vpc"

  vpc_cidr = "10.10.0.0/16"
  vpc_name = "vpc-test-project"
}

# ROUTE TABLE CREATION - PUBLIC RT
resource "aws_route_table" "rtb-test-project-public" {
  vpc_id = module.vpc-test-project.output-vpc-id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-test-project.id
  }

  tags = {
    Name = "rtb-test-project-public"
  }
}

# ROUTE TABLE CREATION - PRIVATE RTs
resource "aws_route_table" "rtb-test-project-private-1a" {
  vpc_id = module.vpc-test-project.output-vpc-id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw-test-project-1a.id
  }

  tags = {
    Name = "rtb-test-project-private-1a"
  }
}

resource "aws_route_table" "rtb-test-project-private-1b" {
  vpc_id = module.vpc-test-project.output-vpc-id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw-test-project-1b.id
  }

  tags = {
    Name = "rtb-test-project-private-1b"
  }
}

# SUBNETS
module "sn-vpc-test-project-priv-1a" {
  source = "./module/aws-vpc-subnet"

  vpc_id         = module.vpc-test-project.output-vpc-id
  subnet_id      = "sn-vpc-test-project-priv-1a"
  subnet_ipblock = "10.10.1.0/24"
  az             = "us-east-1a"
  tags = {
    Tier = "private",
  }
}

module "sn-vpc-test-project-priv-1b" {
  source = "./module/aws-vpc-subnet"

  vpc_id         = module.vpc-test-project.output-vpc-id
  subnet_id      = "sn-vpc-test-project-priv-1b"
  subnet_ipblock = "10.10.10.0/24"
  az             = "us-east-1b"
  tags = {
    Tier = "private",
  }
}

module "sn-vpc-test-project-pub-1a" {
  source = "./module/aws-vpc-subnet"

  vpc_id         = module.vpc-test-project.output-vpc-id
  subnet_id      = "sn-vpc-test-project-pub-1a"
  subnet_ipblock = "10.10.50.0/24"
  subnet_public  = "true"
  az             = "us-east-1a"
  tags = {
    Tier = "public",
  }
}

module "sn-vpc-test-project-pub-1b" {
  source = "./module/aws-vpc-subnet"

  vpc_id         = module.vpc-test-project.output-vpc-id
  subnet_id      = "sn-vpc-test-project-pub-1b"
  subnet_ipblock = "10.10.51.0/24"
  subnet_public  = "true"
  az             = "us-east-1b"
  tags = {
    Tier = "public",
  }
}


# SUBNETS TO RT ASSOCIATIONS
resource "aws_route_table_association" "route_table_association-test-project-pub-1a" {
  subnet_id      = module.sn-vpc-test-project-pub-1a.subnet-id
  route_table_id = aws_route_table.rtb-test-project-public.id
}

resource "aws_route_table_association" "route_table_association-test-project-pub-1b" {
  subnet_id      = module.sn-vpc-test-project-pub-1b.subnet-id
  route_table_id = aws_route_table.rtb-test-project-public.id
}

resource "aws_route_table_association" "route_table_association-test-project-priv-1a" {
  subnet_id      = module.sn-vpc-test-project-priv-1a.subnet-id
  route_table_id = aws_route_table.rtb-test-project-private-1a.id
}

resource "aws_route_table_association" "route_table_association-test-project-priv-1b" {
  subnet_id      = module.sn-vpc-test-project-priv-1b.subnet-id
  route_table_id = aws_route_table.rtb-test-project-private-1b.id
}


resource "aws_internet_gateway" "igw-test-project" {
  vpc_id = module.vpc-test-project.output-vpc-id

  tags = {
    Name = "igw-test-project"
  }
}

# ELASTIC IP FOR IGW 1a
resource "aws_eip" "eip_test-project-1a" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw-test-project]
  tags = {
    Name = "EIP NAT GW test-project 1a"
  }
}

# PUBLIC NAT GATEWAY ASSOCIATED WITH IGW & EIP 1a
resource "aws_nat_gateway" "ngw-test-project-1a" {
  allocation_id = aws_eip.eip_test-project-1a.id
  subnet_id     = module.sn-vpc-test-project-pub-1a.subnet-id
  depends_on    = [aws_internet_gateway.igw-test-project]
  tags = {
    Name = "ngw-test-project 1a NAT"
  }
}

# ELASTIC IP FOR IGW 1b
resource "aws_eip" "eip_test-project-1b" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw-test-project]
  tags = {
    Name = "EIP NAT GW test-project 1b"
  }
}

# PUBLIC NAT GATEWAY ASSOCIATED WITH IGW & EIP 1b
resource "aws_nat_gateway" "ngw-test-project-1b" {
  allocation_id = aws_eip.eip_test-project-1b.id
  subnet_id     = module.sn-vpc-test-project-pub-1b.subnet-id
  depends_on    = [aws_internet_gateway.igw-test-project]
  tags = {
    Name = "ngw-test-project 1b NAT"
  }
}