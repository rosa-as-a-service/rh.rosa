locals {
  public_subnet = cidrsubnets(var.public_vpc_cidr, 8, 8)
  private_subnet = cidrsubnets(var.private_vpc_cidr, 8, 8, 8)
}

resource "aws_vpc" "public_vpc" {
  cidr_block = var.public_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = join("-", [var.cluster_name, "public"])
    cluster-name = var.cluster_name
  }
}

resource "aws_subnet" "public_subnet_int" {
  vpc_id = aws_vpc.public_vpc.id
  cidr_block = local.public_subnet[0]
  tags = {
    Name = join("-", [var.cluster_name, "public", "int"])
    cluster-name = var.cluster_name
  }
}

resource "aws_subnet" "public_subnet_ext" {
  vpc_id = aws_vpc.public_vpc.id
  cidr_block = local.public_subnet[1]
  tags = {
    Name = join("-", [var.cluster_name, "public", "ext"])
    cluster-name = var.cluster_name
  }
}

#################################################################
#
#
# TODO
# - NAT Gateway
# - Internet Gateway
# - Route table for int (Default route to NAT Gateway)
# - Default route to Internet Gateway
# 
#
#################################################################
resource "aws_internet_gateway" "internet_gateway_ext" {
  vpc_id = aws_vpc.public_vpc.id
}

resource "aws_eip" "nat_gw_ip" {  
  depends_on = [ aws_internet_gateway.internet_gateway_ext ]
}

resource "aws_nat_gateway" "nat_gateway_ext" {
  subnet_id = aws_subnet.public_subnet_ext.id
  allocation_id = aws_eip.nat_gw_ip.id
  depends_on = [
    aws_nat_gateway.nat_gateway_ext
  ]
}

resource "aws_route_table" "public_subnet_int_route_table" {
  vpc_id = aws_vpc.public_vpc.id
  tags = {
    "Name" = join("-", [var.cluster_name, "public", "int"])
  }
}

resource "aws_route_table" "public_subnet_ext_route_table" {
  vpc_id = aws_vpc.public_vpc.id
  tags = {
    "Name" = join("-", [var.cluster_name, "public", "ext"])
  }
}

resource "aws_route_table_association" "public_subnet_int_route_association" {
  route_table_id = aws_route_table.public_subnet_int_route_table.id
  subnet_id = aws_subnet.public_subnet_int.id
}

resource "aws_route_table_association" "public_subnet_ext_route_association" {
  route_table_id = aws_route_table.public_subnet_ext_route_table.id
  subnet_id = aws_subnet.public_subnet_ext.id
}

#################################################################
#
# Private subnets
#
#################################################################
resource "aws_vpc" "private_vpc" {
  cidr_block = var.private_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = join("-", [var.cluster_name, "private"])
    cluster-name = var.cluster_name
  }
}

resource "aws_subnet" "private_subnets" {
  count = "${length(data.aws_availability_zones.private_zones.names)}"
  vpc_id = aws_vpc.private_vpc.id
  cidr_block = local.private_subnet[count.index]
  availability_zone= "${data.aws_availability_zones.private_zones.names[count.index]}"
  map_public_ip_on_launch = false
  tags = {
    Name = join("-", [var.cluster_name, "private", "${data.aws_availability_zones.private_zones.names[count.index]}"])
  }
}

#################################################################
#
# Transit gateway and associations
#
#################################################################

resource "aws_ec2_transit_gateway" "transit_gateway" {
  description = "Transit gateway for ROSA"
  tags = {
    Name = join("-", [var.cluster_name, "transit-gateway"])
  }
}

resource "time_sleep" "wait_for_transit_gateway" {
  create_duration = "60s"
  depends_on = [
    aws_ec2_transit_gateway.transit_gateway
  ]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "private_transit_gateway_vpc_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id = aws_vpc.private_vpc.id
  subnet_ids = [for subnet_id in aws_subnet.private_subnets : subnet_id.id]
  tags = {
    Name = join("-", [var.cluster_name, "private-vpc-attachment"])
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "public_transit_gateway_vpc_attachment" {
  transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  vpc_id = aws_vpc.public_vpc.id
  subnet_ids = [aws_subnet.public_subnet_int.id]
  tags = {
    Name = join("-", [var.cluster_name, "public-vpc-attachment"])
  }
}


#################################################################
#
# Routing
#
#################################################################

resource "aws_ec2_transit_gateway_route" "transit_gateway_default_route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.public_transit_gateway_vpc_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.transit_gateway.association_default_route_table_id
  depends_on = [
    time_sleep.wait_for_transit_gateway
  ]
}

resource "aws_route" "private_default_route" {
  route_table_id = aws_vpc.private_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  depends_on = [
    time_sleep.wait_for_transit_gateway
  ]
}

resource "aws_route" "public_int_default_route" {
  route_table_id = aws_route_table.public_subnet_int_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway_ext.id
  depends_on = [
    time_sleep.wait_for_transit_gateway
  ]
}

resource "aws_route" "public_ext_default_route" {
  route_table_id = aws_route_table.public_subnet_ext_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gateway_ext.id
  depends_on = [
    time_sleep.wait_for_transit_gateway
  ]
}

resource "aws_route" "public_ext_private_route" {
  route_table_id = aws_route_table.public_subnet_ext_route_table.id
  destination_cidr_block = aws_vpc.private_vpc.cidr_block
  gateway_id = aws_ec2_transit_gateway.transit_gateway.id
  depends_on = [
    time_sleep.wait_for_transit_gateway
  ]
}

#resource "aws_route" "public_int_private_route" {
#  route_table_id = aws_route_table.public_subnet_int_route_table.id
#  destination_cidr_block = aws_vpc.private_vpc.cidr_block
#  gateway_id = aws_ec2_transit_gateway.transit_gateway.id
#  depends_on = [
#    aws_ec2_transit_gateway.transit_gateway
#  ]
#}
#
#resource "aws_route" "transit_gateway_default_route" {
#  route_table_id = aws_ec2_transit_gateway_vpc_attachment.public_transit_gateway_vpc_attachment.id
#  destination_cidr_block = "0.0.0.0/0"
#  gateway_id = aws_ec2_transit_gateway_vpc_attachment.public_transit_gateway_vpc_attachment.id
#}