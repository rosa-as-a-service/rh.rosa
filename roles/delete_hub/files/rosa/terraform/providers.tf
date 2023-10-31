terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    rhcs = {
      source = "terraform-redhat/rhcs"
      version = "1.4.0"
    }
  }
}

provider "rhcs" {
  token = var.token
  url   = var.url
}

provider "aws" {
  region                 = "ap-southeast-2"
  access_key             = var.AWS_ACCESS_KEY_ID
  secret_key             = var.AWS_SECRET_ACCESS_KEY
  skip_region_validation = true
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}

