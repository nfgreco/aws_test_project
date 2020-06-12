
variable "project" {
  type    = string
  default = ""
}

# VPC related variables

variable "cidr_block" {
  type = string
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = false
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

# SUBNETS related variables

variable "newbits" {
  type    = number
  default = 8
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}

variable "public_subnets" {
  type    = number
  default = 1
}

variable "public_subnets_identifier" {
  type    = string
  default = "public"
}

variable "public_subnets_tags" {
  type    = map
  default = {}
}

variable "private_subnets" {
  type    = number
  default = 0
}

variable "private_subnets_identifier" {
  type    = string
  default = "private"
}

variable "private_subnets_tags" {
  type    = map
  default = {}
}