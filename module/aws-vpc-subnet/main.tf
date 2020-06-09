resource "aws_subnet" "main_subnet_creation" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_ipblock
  map_public_ip_on_launch = var.subnet_public
  availability_zone       = var.az

  tags = merge(
    {
      "Name" = var.subnet_id
    },
    var.tags,
  )

}
