data "aws_caller_identity" "current" {}

data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:cluster-name"
    values = [ "{{ rosa_cluster_name }}" ]
  }
}

data "aws_network_interface" "master_0" {
  filter {
    name = "tag:Name"
    values = ["{{ _rosa_hub_cluster_infra_id }}-master-0"]
  }
}

data "aws_network_interface" "master_1" {
  filter {
    name = "tag:Name"
    values = ["{{ _rosa_hub_cluster_infra_id }}-master-1"]
  }
}

data "aws_network_interface" "master_2" {
  filter {
    name = "tag:Name"
    values = ["{{ _rosa_hub_cluster_infra_id }}-master-2"]
  }
}

data "aws_route53_zone" "hub_hosted_zone" {
  name = "{{ _rosa_base_domain }}."
}

data "aws_lb_target_group" "hub_api_target_group"{
  name = "{{ _rosa_hub_cluster_infra_id }}-aint"
}