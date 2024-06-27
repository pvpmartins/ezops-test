variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "sa-east-1"
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

