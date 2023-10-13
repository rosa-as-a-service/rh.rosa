data "aws_caller_identity" "current" {}

data "rhcs_rosa_operator_roles" "operator_roles" {
  operator_role_prefix = var.operator_role_prefix
  account_role_prefix  = var.account_role_prefix
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
    values = ["{{ rosa_subnets[0].name | default(rosa_vpc_name + '-2a') }}", "{{ rosa_subnets[1].name | default(rosa_vpc_name + '-2b') }}"]
  }
}

data "aws_subnet" "tenent_subnet_id" {
  for_each = toset(data.aws_subnets.tenent_subnet_ids.ids)
  id = each.value
}