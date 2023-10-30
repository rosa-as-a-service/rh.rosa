data "aws_caller_identity" "current" {}

data "rhcs_rosa_operator_roles" "operator_roles" {
  operator_role_prefix = "{{ rosa_cluster_name }}"
  account_role_prefix  = "{{ rosa_cluster_name }}"
}

data "rhcs_policies" "all_policies" {}

data "rhcs_versions" "all" {}

data "aws_vpc" "tenent_vpc" {
  filter {
    name   = "tag:Name"
    values = ["{{ rosa_vpc_name }}"]
  }
}

data "aws_subnets" "tenent_subnet_ids" {
  filter {
    name   = "tag:Name"
    values = {{ rosa_subnets | community.general.json_query('[*].name') | to_json }}
  }
}

data "aws_subnet" "tenent_subnet_id" {
  for_each = toset(data.aws_subnets.tenent_subnet_ids.ids)
  id = each.value
}