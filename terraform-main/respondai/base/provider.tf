# Setup our aws provider
variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "terraform-infra-state"
    region = "us-east-1"
    dynamodb_table = "terraform-locks"
    key = "base/terraform.tfstate"
  }
}

