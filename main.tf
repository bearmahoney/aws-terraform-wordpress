terraform {

  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.5.3"
    }

    aws = {
      source  = "aws"
      version = "~> 3.0"


    }

  }

  backend "s3" {
    bucket  = "bearmahoney-terraform-state"
    key     = "terraform-state-key/"
    region  = "eu-west-1"
    encrypt = true
  }

}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}


