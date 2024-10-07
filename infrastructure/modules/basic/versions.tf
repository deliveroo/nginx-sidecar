terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
    circleci = {
      source  = "terraform-registry.deliveroo.net/deliveroo/circleci"
      version = "~> 1.0"
    }
    roo = {
      source  = "terraform-registry.deliveroo.net/deliveroo/roo"
      version = "~> 1.0"
    }
  }
}
