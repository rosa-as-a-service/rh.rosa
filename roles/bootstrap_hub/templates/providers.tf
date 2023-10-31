terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.22.0"
    }
  }
  backend "s3" {
    bucket     = "{{ s3_bucket_name }}"
    key        = "privatelink/terraform.tfstate"
    region     = "ap-southeast-2"
    access_key = "{{ aws_access_key_id }}"
    secret_key = "{{ aws_secret_access_key }}"
  }
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