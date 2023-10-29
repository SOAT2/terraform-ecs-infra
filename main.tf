terraform {
  required_version = "~> 1.6"
  required_providers {
    vault = {
      source = "hashicorp/vault"
      #version = "3.21.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}