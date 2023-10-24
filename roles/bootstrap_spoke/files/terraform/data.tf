data "aws_caller_identity" "current" {}

data "aws_vpc" "spoke_vpc" {
  filter {
    name   = "tag:cluster-name"
    values = [ var.rosa_vpc_name ]
  }
}

data "aws_vpc_endpoint_service" "spoke_endpoint_service" {
  filter {
    name   = "tag:cluster-name"
    values = [ var.rosa_cluster_name ]
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

data "aws_vpc_security_group" "spoke_master_security_group" {
  filter {
    name   = "tag:Name"
    values = [ join("-", [ var._rosa_cluster_infra_id, "master-sg"])]
  }
}

data "aws_vpc_security_group" "hub_master_security_group" {
  filter {
    name   = "tag:Name"
    values = [ join("-", [var._rosa_hub_cluster_infra_id, "master-sg"])]
  }
}

data "aws_lbs" "spoke_lb" {
  tags = {
    "Name" = var.rosa_cluster_name
  }
}