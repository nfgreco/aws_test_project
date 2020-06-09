# AWS Config
# # Data to connect to AWS

variable "aws_access_key" {
  default = "aws_key_change_me"
}

variable "aws_secret_key" {
  default = "aws_secret_change_me"
}

variable "aws_region" {
  description = "The Amazon AWS Region."
  default     = "us-east-1"
}
