data "aws_caller_identity" "current" {}

data "aws_vpc" "spoke_vpc" {
  filter {
    name   = "tag:cluster-name"
    values = [ "{{ rosa_cluster_name }}" ]
  }
}

data "aws_vpc_endpoint_service" "spoke_endpoint_service" {
  filter {
    name   = "tag:hive.openshift.io/private-link-access-for"
    values = [ "{{ _rosa_cluster_infra_id }}" ]
  }
}

data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:Name"
    values = [ "hub-egress" ]
  }
}

data "aws_vpc_endpoint_service" "hub_endpoint_service" {
  filter {
    name   = "tag:hive.openshift.io/private-link-access-for"
    values = [ "{{ _rosa_hub_cluster_infra_id }}" ]
  }
}

data "aws_security_group" "spoke_master_security_group" {
  tags = {
    Name = "{{ _rosa_cluster_infra_id }}-master-sg"
  }
}

data "aws_security_group" "hub_master_security_group" {
  tags = {
    Name = "{{ _rosa_hub_cluster_infra_id }}-master-sg"
  }
}

data "aws_lb" "spoke_lb" {
  name = "{{ _rosa_cluster_infra_id }}-int"
}

data "aws_route53_zone" "spoke_hosted_zone" {
  name = "{{ _rosa_base_domain }}."
}
