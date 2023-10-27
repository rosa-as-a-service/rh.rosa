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
  description = "Allow Kubernetes API inbound traffic from {{ rosa_cluster_name }}"
  security_group_id = "${data.aws_security_group.hub_master_security_group.id}"
  from_port        = 6443
  to_port          = 6443
  protocol         = "tcp"
  type             = "ingress"
  cidr_blocks      = ["${data.aws_vpc.spoke_vpc.cidr_block}"]

}

resource "aws_lb" "spoke_lb" {
  name                       = "{{ rosa_cluster_name }}-api"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = [for subnet in data.aws_subnet.spoke_subnet : subnet.id]
  enable_deletion_protection = false
  tags = {
    cluster-name = "{{ rosa_cluster_name }}"
  }
}

resource "aws_lb_target_group" "spoke_api_target_group" {
  name        = "{{ rosa_cluster_name }}-api"
  port        = 6443
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.spoke_vpc.id
  tags = {
    cluster-name = "{{ rosa_cluster_name }}"
  }
}

resource "aws_lb_target_group_attachment" "spoke_api_target_group_attach_1" {
  target_group_arn  = aws_lb_target_group.spoke_api_target_group.arn
  target_id         = data.aws_network_interface.master_0.private_ip
  port              = 6443
}

resource "aws_lb_target_group_attachment" "spoke_api_target_group_attach_2" {
  target_group_arn  = aws_lb_target_group.spoke_api_target_group.arn
  target_id         = data.aws_network_interface.master_1.private_ip
  port              = 6443
}

resource "aws_lb_target_group_attachment" "spoke_api_target_group_attach_3" {
  target_group_arn  = aws_lb_target_group.spoke_api_target_group.arn
  target_id         = data.aws_network_interface.master_2.private_ip
  port              = 6443
}

resource "aws_lb_listener" "spoke_api_listener" {
  load_balancer_arn = aws_lb.spoke_lb.arn
  port              = "6443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spoke_api_target_group.arn
  }
  tags = {
    cluster-name = "{{ rosa_cluster_name }}"
  }
}

resource "aws_vpc_endpoint_service" "spoke_endpoint_service" {
  acceptance_required        = false
  network_load_balancer_arns = ["${aws_lb.spoke_lb.arn}"]
  private_dns_name           = "*.{{ rosa_cluster_name }}.{{ _rosa_base_domain }}"
  tags = {
    cluster-name = "{{ rosa_cluster_name }}"
  }
}

resource "aws_route53_record" "spoke_base_domain_verification" {
  zone_id = "${data.aws_route53_zone.spoke_hosted_zone.zone_id}"
  name    = "${aws_vpc_endpoint_service.spoke_endpoint_service.private_dns_name_configuration[0].name}"
  records   = ["${aws_vpc_endpoint_service.spoke_endpoint_service.private_dns_name_configuration[0].value}"]
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
  subnet_ids          = [for subnet in data.aws_subnet.spoke_subnet : subnet.id]
  private_dns_enabled = true
  tags = {
    cluster-name = "{{ rosa_cluster_name }}"
  }
}

## Create a VPC Endpoint in the Hub to consume 6443/tcp from the Spoke via PrivateLink
resource "aws_vpc_endpoint" "spoke_endpoint" {
  vpc_id            = "${data.aws_vpc.hub_vpc.id}"
  service_name      = "${aws_vpc_endpoint_service.spoke_endpoint_service.service_name}"
  vpc_endpoint_type = "Interface"
  subnet_ids          = ["{{ rosa_hub_public_subnet_id }}"]
  security_group_ids = ["${data.aws_security_group.hub_master_security_group.id}"]
  private_dns_enabled = true
  tags = {
    cluster-name = "{{ rosa_cluster_name }}"
  }
}