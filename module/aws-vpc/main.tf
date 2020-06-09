resource "aws_vpc" "vpc-module" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.vpc_tenancy

  tags = merge(
    {
      "Name" = var.vpc_name,
    },
    var.tags,
  )

}