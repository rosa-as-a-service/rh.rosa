#output "aws_availability_zones" {
#  value = data.aws_availability_zones.private_zones
#}
#
#output "public_vpc" {
#  value = aws_vpc.public_vpc
#}
#
#output "public_subnet_int" {
#  value = aws_subnet.public_subnet_int
#}
#
#output "public_subnet_ext" {
#  value = aws_subnet.public_subnet_ext
#}
#
#output "internet_gateway_ext" {
#  value = aws_internet_gateway.internet_gateway_ext
#}
#
#output "nat_gateway_ext" {
#  value = aws_nat_gateway.nat_gateway_ext
#}

#output "private_vpc" {
#  value = aws_vpc.private_vpc
#}

output "private_subnets" {
  value = aws_subnet.private_subnets
}

#output "availability_zone" {
#  value = data.aws_availability_zone.private_zone
#}
#
#output "public_transit_gateway_vpc_attachment" {
#  value = aws_ec2_transit_gateway_vpc_attachment.public_transit_gateway_vpc_attachment
#}