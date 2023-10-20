data "aws_caller_identity" "current" {}

data "aws_vpc" "spoke_vpc" {
  filter {
    name   = "tag:Name"
    values = ["{{ rosa_vpc_name }}-private-rosa"]
  }
}

data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:Name"
    values = ["hub-gress"]
  }
}

data "aws_security_group" "master_security_group" {
  filter {
    name   = "tag:Name"
    values = "{{ rosa_cluster_name }}-{{ _rosa_cluster_uuid }}-master-sg"
  }
}