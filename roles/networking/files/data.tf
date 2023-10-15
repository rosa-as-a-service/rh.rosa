data "aws_availability_zones" "private_zones" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_availability_zone" "private_zone" {
  for_each = toset(data.aws_availability_zones.private_zones.names)
  name = each.value
}