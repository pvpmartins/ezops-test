provider "aws" {
  region = "sa-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "test-paulovitor-state"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "test-paulovitor-state"
    key            = "network/terraform.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "teste-paulo-vitor-lock-state-table"
    encrypt        = true
  }
}

