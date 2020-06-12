
output "vpc_id" {
  value = aws_vpc.custom_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.custom_public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.custom_private_subnet[*].id
}

output "private_security_group_id" {
   value = aws_security_group.custom_private_security_group.id
}

output "public_security_group_id" {
  value = aws_security_group.custom_public_security_group.id
}