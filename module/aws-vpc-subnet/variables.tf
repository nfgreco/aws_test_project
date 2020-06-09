
variable "vpc_id" {
  description = ""
}
variable "subnet_ipblock" {
  description = ""
}

variable "subnet_id" {
  description = ""
}

variable "subnet_public" {
  default = "false"
}

variable "az" {
  description = ""
}


variable "tags" {
  description = "Additional tags for subnets"
  type        = map(string)
  default     = {}
}
