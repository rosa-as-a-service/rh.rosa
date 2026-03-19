{% if rosa_subnet_ids is defined %}
variable "subnet_ids" {
  type    = list(string)
  default = {{ rosa_subnet_ids | to_json }}
}

data "aws_subnet" "cluster_subnet" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}
{% else %}
data "aws_subnets" "cluster_subnets" {
  filter {
    name   = "tag:Name"
    values = {{ rosa_subnets | community.general.json_query('[*].name') | to_json }}
  }
}

data "aws_subnet" "cluster_subnet" {
  for_each = toset(data.aws_subnets.cluster_subnets.ids)
  id       = each.value
}
{% endif %}
