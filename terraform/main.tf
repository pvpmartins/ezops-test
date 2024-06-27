terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket         = "test-paulovitor-state"
    key            = "./terraform.tfstate"
    region         = "sa-east-1"
    dynamodb_table = null
    encrypt        = true
    versioning     = true
    lock {
      enabled = true
    }
  }
}

provider "aws" {
  region = var.aws_region
}

