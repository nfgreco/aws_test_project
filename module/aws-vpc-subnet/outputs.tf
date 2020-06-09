
output "subnet-id" {
  description = "Output ID for a subnet"
  value       = "${aws_subnet.main_subnet_creation.id}"
}
