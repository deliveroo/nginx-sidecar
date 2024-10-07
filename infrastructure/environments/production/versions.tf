terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
    roo = {
      source  = "terraform-registry.deliveroo.net/deliveroo/roo"
      version = "~> 1.0"
    }
  }
}
