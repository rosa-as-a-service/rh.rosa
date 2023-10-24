# We need logic to validate the Endpoint Service DNS for PrivateDNS
## This logic will need to include creating the TXT DNS record in the
## public subnet of the Spoke# (eg <_dns_verification_name>.spoke#.<base_domain>) in Route53
##
## Once that is complete, then we can enable PrivateDNS on the Endpoints (automatically done below)
# Using this to modify the existing Endpoint Service might do all the heavy lifting for us

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service
## Modify the Spoke's Endpoint Service


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
## Modify spoke#-infraid-master-sg securitygroup to allow the Hub subnet to consume 6443/tcp
resource "aws_security_group_rule" "allow_hub" {
  name        = "allow_hub"
  description = "Allow Kubernetes API inbound traffic"
  vpc_id      = "${aws_vpc.spoke_vpc.id}"

    description      = "Kubernetes API from Spoke"
    from_port        = any
    to_port          = 6443
    protocol         = "tcp"
    type             = "Custom TCP"
    cidr_blocks      = ["${aws_vpc.hub_vpc.cidr_block}"]

  tags = {
    Name = "allow_hub"
  }
}

## Modify hub-infraid-master-sg securitygroup to allow the Spoke subnet to consume 6443/tcp
resource "aws_security_group_rule" "allow_$${ var.rosa_cluster_name }" {
  name        = "allow_${ var.rosa_cluster_name }"
  description = "Allow Kubernetes API inbound traffic"
  vpc_id      = "${aws_vpc.hub_vpc.id}""

  ingress {
    description      = "Kubernetes API from ${ var.rosa_cluster_name }"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = ["${aws_vpc.spoke_vpc.cidr_block}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_${ var.rosa_cluster_name }"
  }
}

## Need to associate security groups with the `master` nodes

# need to enable PrivateDNS - unsure how to automate the validation
resource "aws_vpc_endpoint_service" "$${ var.rosa_cluster_name }" {
  acceptance_required        = false
  network_load_balancer_arns = ["${aws_lb.spoke_lb.arn}"]
  private_dns_name           = "*.${ var.rosa_base_domain }"
}

resource "aws_route53_record" "spoke_base_domain_verification" {
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.rosa_cluster_name }.private_dns_name_configuration.name"
  value   = "${var.rosa_cluster_name }.private_dns_name_configuration.value"
  type    = "TXT"
  ttl     = 1800
}

resource "time_sleep" "wait_for_base_domain_dns_propogration" {
  depends_on      = [${aws_route53_record.spoke_base_domain_verification}]
  create_duration = "180s"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
## Create a VPC Endpoint in the Spoke to consume 6443/tcp from the Hub via PrivateLink
resource "aws_vpc_endpoint" "hub" {
  vpc_id            = ${data.aws_vpc.spoke_vpc.id}
  service_name      = "${data.aws_vpc_endpoint_service.hub_endpoint_service.name}"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    ${aws_security_group.allow_hub.id},
  ]

  private_dns_enabled = true
}

## Create a VPC Endpoint in the Hub to consume 6443/tcp from the Spoke# via PrivateLink
resource "aws_vpc_endpoint" "$${ var.rosa_cluster_name }" {
  vpc_id            = aws_vpc.hub_vpc.id
  service_name      = "${data.aws_vpc_endpoint_service.spoke_endpoint_service.name}"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    ${aws_security_group.allow_${ var.rosa_cluster_name }.id},
  ]

  private_dns_enabled = true
}