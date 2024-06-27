variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "aws_arn_role" {
  description = "ARN of the IAM role for AWS access"
  type        = string
}

variable "ec2_key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
}

