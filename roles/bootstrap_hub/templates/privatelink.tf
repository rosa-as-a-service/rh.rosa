resource "aws_lb" "hub_lb" {
  name                       = "{{ rosa_cluster_name }}-api"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = [for subnet in data.aws_subnet.hub_subnet : subnet.id]
  enable_deletion_protection = false
  tags = {
    cluster-name = "{{ rosa_cluster_name }}"
  }
}

resource "aws_lb_target_group" "hub_api_target_group" {
  name        = "{{ rosa_cluster_name }}-api"
  port        = 6443
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.hub_vpc.id
}

resource "aws_lb_target_group_attachment" "hub_api_target_group_attach_1" {
  target_group_arn  = aws_lb_target_group.hub_api_target_group.arn
  target_id         = data.aws_network_interface.master_0.private_ip
  port              = 6443
}

resource "aws_lb_target_group_attachment" "hub_api_target_group_attach_2" {
  target_group_arn  = aws_lb_target_group.hub_api_target_group.arn
  target_id         = data.aws_network_interface.master_1.private_ip
  port              = 6443
}

resource "aws_lb_target_group_attachment" "hub_api_target_group_attach_3" {
  target_group_arn  = aws_lb_target_group.hub_api_target_group.arn
  target_id         = data.aws_network_interface.master_2.private_ip
  port              = 6443
}

resource "aws_lb_listener" "hub_api_listener" {
  load_balancer_arn = aws_lb.hub_lb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hub_api_target_group.arn
  }
}

resource "aws_vpc_endpoint_service" "hub_endpoint_service" {
  acceptance_required        = false
  network_load_balancer_arns = ["${aws_lb.hub_lb.arn}"]
  private_dns_name           = "*.{{ rosa_cluster_name }}.{{ _rosa_base_domain }}"
}

resource "aws_route53_record" "hub_base_domain_verification" {
  zone_id = "${data.aws_route53_zone.hub_hosted_zone.zone_id}"
  name    = "${aws_vpc_endpoint_service.hub_endpoint_service.private_dns_name_configuration[0].name}"
  records   = ["${aws_vpc_endpoint_service.hub_endpoint_service.private_dns_name_configuration[0].value}"]
  type    = "TXT"
  ttl     = 1800
}

resource "time_sleep" "wait_for_base_domain_dns_propogration" {
  depends_on      = [aws_route53_record.hub_base_domain_verification]
  create_duration = "180s"
}