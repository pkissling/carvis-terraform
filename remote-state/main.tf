provider "aws" {
  region                   = "eu-west-1"
  shared_credentials_files = ["~/.aws/credentials.carvis"]
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "carvis-tfstate"
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "carvis-tfstate"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}