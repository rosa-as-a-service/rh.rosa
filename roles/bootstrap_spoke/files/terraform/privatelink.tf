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
  description = "Allow Kubernetes API inbound traffic from Hub"
  security_group_id = "${data.aws_security_group.spoke_master_security_group.id}"
  from_port        = 6443
  to_port          = 6443
  protocol         = "tcp"
  type             = "ingress"
  cidr_blocks      = ["${data.aws_vpc.hub_vpc.cidr_block}"]
}

## Modify hub-infraid-master-sg securitygroup to allow the Spoke subnet to consume 6443/tcp
resource "aws_security_group_rule" "allow_spoke" {
  description = "Allow Kubernetes API inbound traffic from ${ var.rosa_cluster_name }"
  security_group_id = "${data.aws_security_group.hub_master_security_group.id}"
  from_port        = 6443
  to_port          = 6443
  protocol         = "tcp"
  type             = "ingress"
  cidr_blocks      = ["${data.aws_vpc.spoke_vpc.cidr_block}"]

}

resource "aws_vpc_endpoint_service" "spoke_endpoint_service" {
  acceptance_required        = false
  network_load_balancer_arns = ["${ data.aws_lb.spoke_lb.arn }"]
  private_dns_name           = "*.${ var.rosa_base_domain }."
}

resource "aws_route53_record" "spoke_base_domain_verification" {
  zone_id = "${ data.aws_route53_zone.spoke_hosted_zone.zone_id }"
  name    = "${ aws_vpc_endpoint_service.spoke_endpoint_service.private_dns_name_configuration[0].name }"
  records   = "${ aws_vpc_endpoint_service.spoke_endpoint_service.private_dns_name_configuration[0].value }"
  type    = "TXT"
  ttl     = 1800
}

resource "time_sleep" "wait_for_base_domain_dns_propogration" {
  depends_on      = [aws_route53_record.spoke_base_domain_verification]
  create_duration = "180s"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
## Create a VPC Endpoint in the Spoke to consume 6443/tcp from the Hub via PrivateLink
resource "aws_vpc_endpoint" "hub" {
  vpc_id            = "${data.aws_vpc.spoke_vpc.id}"
  service_name      = "${data.aws_vpc_endpoint_service.hub_endpoint_service.service_name}"
  vpc_endpoint_type = "Interface"

  security_group_ids = ["${data.aws_security_group.spoke_master_security_group.id}"]

  private_dns_enabled = true
}

## Create a VPC Endpoint in the Hub to consume 6443/tcp from the Spoke via PrivateLink
resource "aws_vpc_endpoint" "spoke_endpoint" {
  vpc_id            = "${data.aws_vpc.hub_vpc.id}"
  service_name      = "${data.aws_vpc_endpoint_service.spoke_endpoint_service.service_name}"
  vpc_endpoint_type = "Interface"

  security_group_ids = ["${data.aws_security_group.hub_master_security_group.id}"]

  private_dns_enabled = true
}