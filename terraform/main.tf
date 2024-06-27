terraform {
  #required_version = ">= 0.12"
  backend "s3" {
    bucket         = "test-paulovitor-state"
    key            = "network/terraform.tfstate"
    region         = var.aws_region
    role_arn       = var.aws_arn_role
    dynamodb_table = null
    encrypt        = true
    versioning     = true
    lock {
      enabled = true
    }
  }
}

provider "aws" {
  assume_role {
    role_arn = var.aws_arn_role
  }
  region = var.aws_region
}

