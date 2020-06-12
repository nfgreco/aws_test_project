
locals {
  base_name = lower(var.project)
  base_tags = {
    Deployer = "terraform"
    Project  = lower(var.project)
  }

  public_subnets = var.public_subnets == 0 ? [] : [
    for public_subnet_index in range(var.public_subnets) :
    cidrsubnet(var.cidr_block, var.newbits, public_subnet_index)
  ]

  private_subnets = var.private_subnets == 0 ? [] : [
    for private_subnet_index in range(var.private_subnets) :
    cidrsubnet(var.cidr_block, var.newbits, private_subnet_index + 100)
  ]

  private_sg = aws_security_group.custom_private_security_group
  public_sg = aws_security_group.custom_public_security_group

  base_route = {
    cidr_block                = "0.0.0.0/0"
    egress_only_gateway_id    = ""
    gateway_id                = ""
    instance_id               = ""
    ipv6_cidr_block           = ""
    nat_gateway_id            = ""
    network_interface_id      = ""
    transit_gateway_id        = ""
    vpc_peering_connection_id = ""
  }

  availability_zones = length(data.aws_availability_zones.available.names) > var.public_subnets ? slice(data.aws_availability_zones.available.names, 0, var.public_subnets) : data.aws_availability_zones.available.names
}

###[ VPC ]#####################################################

resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy     = var.instance_tenancy

  tags = merge({
    "Name" = "vpc-${var.project}"
    },
  local.base_tags)
}

###[ SUBNET PUBLIC ]###########################################

resource "aws_subnet" "custom_public_subnet" {
  count             = length(local.public_subnets)
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = local.public_subnets[count.index]
  availability_zone = local.availability_zones[count.index % length(local.availability_zones)]

  tags = merge({
    "Name" = "subnet-${var.project}-${var.public_subnets_identifier}-${count.index}-${local.availability_zones[count.index % length(local.availability_zones)]}"
    },
  local.base_tags, var.public_subnets_tags)

  depends_on = [aws_vpc.custom_vpc]

}

###[ SUBNET PRIVATE ]##########################################

resource "aws_subnet" "custom_private_subnet" {
  count             = length(local.private_subnets)
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = local.availability_zones[count.index % length(local.availability_zones)]

  tags = merge({
    "Name" = "subnet-${var.project}-${var.private_subnets_identifier}-${count.index}-${local.availability_zones[count.index % length(local.availability_zones)]}"
    },
  local.base_tags, var.private_subnets_tags)

  depends_on = [aws_vpc.custom_vpc]

}

###[ SG PUBLIC ]###########################################

resource "aws_security_group" "custom_public_security_group" {
  name = "SG-${var.project}-public"
  vpc_id            = aws_vpc.custom_vpc.id
  tags = merge({
    "Name" = "sg-${var.project}-public"
  },
  local.base_tags)

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

}

###[ SG PRIVATE ]##########################################

resource "aws_security_group" "custom_private_security_group" {
  name = "SG-${var.project}-private"
  vpc_id            = aws_vpc.custom_vpc.id
  tags = merge({
    "Name" = "sg-${var.project}-private"
  },
  local.base_tags)

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


###[ INTERNET GATEWAY ]########################################

resource "aws_internet_gateway" "custom_internet_gateway" {
  count = length(aws_subnet.custom_public_subnet) == 0 ? 0 : 1

  vpc_id = aws_vpc.custom_vpc.id

  tags = merge({
    "Name" = "igw-${var.project}"
    },
  local.base_tags)

  depends_on = [aws_subnet.custom_public_subnet]
}

###[ ELASTIC IP ]##############################################

resource "aws_eip" "custom_eip" {
  count = length(local.availability_zones) <= length(aws_subnet.custom_public_subnet) ? length(local.availability_zones) : length(aws_subnet.custom_public_subnet)
  vpc   = true

  tags = merge({
    "Name" = "eip-${var.project}-${local.availability_zones[count.index % length(local.availability_zones)]}"
    },
  local.base_tags)

  depends_on = [aws_subnet.custom_public_subnet]
}

###[ NAT GATEWAY ]#############################################

resource "aws_nat_gateway" "custom_nat_gateway" {
  count         = length(aws_eip.custom_eip)
  allocation_id = aws_eip.custom_eip[count.index].id
  subnet_id     = aws_subnet.custom_public_subnet[count.index].id

  tags = merge({
    "Name" = "natgw-${var.project}-${local.availability_zones[count.index % length(local.availability_zones)]}"
    },
  local.base_tags)

  depends_on = [aws_subnet.custom_public_subnet, aws_eip.custom_eip]
}

###[ ROUTE TABLE PUBLIC ]######################################

resource "aws_route_table" "custom_public_route_table" {
  count  = length(aws_internet_gateway.custom_internet_gateway)
  vpc_id = aws_vpc.custom_vpc.id

  tags = merge({
    "Name" = "rtb-${var.project}-${var.public_subnets_identifier}"
    },
  local.base_tags)

  depends_on = [aws_vpc.custom_vpc, aws_internet_gateway.custom_internet_gateway]
}

###[ ROUTES PUBLIC ]###########################################

resource "aws_route" "custom_public_igw_route" {
  count                  = length(aws_route_table.custom_public_route_table)
  route_table_id         = aws_route_table.custom_public_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.custom_internet_gateway[count.index].id

  depends_on = [aws_internet_gateway.custom_internet_gateway, aws_route_table.custom_public_route_table]
}

###[ ROUTE TABLE PRIVATE ]#####################################

resource "aws_route_table" "custom_private_route_table" {
  count  = length(aws_nat_gateway.custom_nat_gateway)
  vpc_id = aws_vpc.custom_vpc.id

  tags = merge({
    "Name" = "rtb-${var.project}-${var.private_subnets_identifier}-${local.availability_zones[count.index % length(local.availability_zones)]}"
    },
  local.base_tags)

  depends_on = [aws_vpc.custom_vpc, aws_nat_gateway.custom_nat_gateway]
}

###[ ROUTES PRIVATE ]##########################################

resource "aws_route" "custom_private_natgw_route" {
  count                  = length(aws_route_table.custom_private_route_table)
  route_table_id         = aws_route_table.custom_private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.custom_nat_gateway[count.index].id

  depends_on = [aws_nat_gateway.custom_nat_gateway, aws_route_table.custom_private_route_table]
}

###[ ROUTE TABLE ASSOCIATIONS ]################################

resource "aws_route_table_association" "custom_public_route_table_association" {
  count          = length(aws_subnet.custom_public_subnet)
  subnet_id      = aws_subnet.custom_public_subnet[count.index].id
  route_table_id = aws_route_table.custom_public_route_table[count.index % length(aws_route_table.custom_public_route_table)].id

  depends_on = [aws_subnet.custom_public_subnet, aws_route_table.custom_public_route_table]
}

resource "aws_route_table_association" "custom_private_route_table_association" {
  count          = length(aws_subnet.custom_private_subnet)
  subnet_id      = aws_subnet.custom_private_subnet[count.index].id
  route_table_id = aws_route_table.custom_private_route_table[count.index % length(aws_route_table.custom_private_route_table)].id

  depends_on = [aws_subnet.custom_private_subnet, aws_route_table.custom_private_route_table]
}