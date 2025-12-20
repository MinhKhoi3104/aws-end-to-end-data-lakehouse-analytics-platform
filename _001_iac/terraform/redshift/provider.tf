################################
## AWS Provider Module - Main ##
################################

# Terraform Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = "default"
}
