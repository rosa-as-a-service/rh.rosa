terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20.0"
    }
    rhcs = {
      source  = "terraform-redhat/rhcs"
      version = "~> 1.7"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
  backend "s3" {
    bucket = "{{ s3_bucket_name }}"
    key    = "rosa/{{ rosa_cluster_name }}/terraform.tfstate"
    region = "{{ rosa_region }}"
  }
}

provider "rhcs" {
  token = var.token
  url   = var.url
}

provider "aws" {
  region = var.cloud_region
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
}
