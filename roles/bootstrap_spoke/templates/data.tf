data "aws_caller_identity" "current" {}

data "aws_vpc" "spoke_vpc" {
  filter {
    name   = "tag:cluster-name"
    values = [ "{{ rosa_cluster_name }}" ]
  }
}

# data "aws_vpc_endpoint_service" "spoke_endpoint_service" {
#   filter {
#     name   = "tag:hive.openshift.io/private-link-access-for"
#     values = [ "{{ _rosa_cluster_infra_id }}" ]
#   }
# }

data "aws_network_interface" "master_0" {
  filter {
    name = "tag:Name"
    values = ["{{ _rosa_cluster_infra_id }}-master-0"]
  }
}

data "aws_network_interface" "master_1" {
  filter {
    name = "tag:Name"
    values = ["{{ _rosa_cluster_infra_id }}-master-1"]
  }
}

data "aws_network_interface" "master_2" {
  filter {
    name = "tag:Name"
    values = ["{{ _rosa_cluster_infra_id }}-master-2"]
  }
}


data "aws_subnets" "spoke_subnets" {
  filter {
    name   = "tag:cluster-name"
    values = ["{{ rosa_cluster_name }}"]
  }
}

data "aws_subnet" "spoke_subnet" {
  for_each = toset(data.aws_subnets.spoke_subnets.ids)
  id = each.value
}

data "aws_vpc" "hub_vpc" {
  filter {
    name   = "tag:cluster-name"
    values = [ "hub" ]
  }
}

data "aws_vpc_endpoint_service" "hub_endpoint_service" {
  filter {
    name   = "tag:cluster-name"
    values = [ "hub" ]
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

# data "aws_lb" "spoke_lb_ingress" {
#   name = "{{ _rosa_cluster_infra_id }}-ingress"
# }

data "aws_route53_zone" "spoke_hosted_zone" {
  name = "{{ _rosa_base_domain }}."
}

data "aws_lb_target_group" "spoke_api_target_group"{
  name = "{{ _rosa_cluster_infra_id }}-aint"
}