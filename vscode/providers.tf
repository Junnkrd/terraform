terraform {
  required_version = "1.9.6"
  required_providers {
    aws   = ">=5.69.0"
    local = ">=2.1.0"
  }
}

provider "aws" {
  region = "us-east-1"
}
