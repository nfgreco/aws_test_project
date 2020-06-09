
output "output-vpc-id" {
  description = "Output ID for VPC"
  value       = aws_vpc.vpc-module.id
}

output "output-vpc-cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.vpc-module.cidr_block
}
