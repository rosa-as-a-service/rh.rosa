data "aws_caller_identity" "current" {}

data "aws_vpc" "spoke_vpc" {
  filter {
    name   = "tag:cluster-name"
    values = ["{{ rosa_vpc_name }}"]
  }
}

data "aws_vpc_endpoint_service" "spoke_endpoint_service" {
  filter {
    name   = "tag:cluster-name"
    values = ["{{ rosa_cluster_name }}"]
  }
}

data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:cluster-name"
    values = ["hub"]
  }
}

data "aws_vpc_endpoint_service" "hub_endpoint_service" {
  filter {
    name   = "tag:cluster-name"
    values = ["hub"]
  }
}

data "aws_lbs" "spoke_lb" {
  tags = {
    "Name" = "{{ rosa_cluster_name }}"
  }
}