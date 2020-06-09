
variable "vpc_cidr" {
  description = "VPC CIDR"
}
variable "vpc_name" {
  description = "VPC name"
}
variable "vpc_tenancy" {
  default = "default"
}

variable "tags" {
  description = "Additional tags for VPC"
  type        = map(string)
  default     = {}
}
