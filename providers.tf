terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = "4.32"
  }
}

provider "aws" {
  profile = var.profile
  region  = "us-east-1"

  default_tags {
    tags = var.tags
  }
}

