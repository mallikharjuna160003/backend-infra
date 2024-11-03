terraform {
  backend "s3" {
    bucket         = "backend-s3-bucket-123456"
    key            = "terraform/state"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "backend-lockfile"
  }
}

