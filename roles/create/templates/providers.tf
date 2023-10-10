terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    rhcs = {
      version = "= 1.4.0-prerelease.2"
      source  = "terraform-redhat/rhcs"
    }
  }
}

provider "rhcs" {
  token = var.token
  url   = var.url
}

provider "aws" {
  region                 = "ap-southeast-2"
  skip_region_validation = true
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}

