---
# We need logic to validate the Endpoint Service DNS for PrivateDNS
## This logic will need to include creating the TXT DNS record in the
## public subnet of the Spoke# (eg <_dns_verification_name>.spoke#.<base_domain>) in Route53
##
## Once that is complete, then we can enable PrivateDNS on the Endpoints (automatically done below)
# Using this to modify the existing Endpoint Service might do all the heavy lifting for us

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service
## Modify the Spoke's Endpoint Service


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
## Modify spoke#-uuid-master securitygroup to allow the Hub subnet to consume 6443/tcp
resource "aws_security_group" "allow_hub" {
  name        = "allow_hub"
  description = "Allow Kubernetes API inbound traffic"
  vpc_id      = data.aws_vpc.spoke_vpc.id

  ingress {
    description      = "Kubernetes API from Spoke"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.hub_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_hub"
  }
}

## Modify hub#-uuid-master securitygroup to allow the Spoke subnet to consume 6443/tcp
resource "aws_security_group" "allow_{{ rosa_cluster_name }}" {
  name        = "allow_{{ rosa_cluster_name }}"
  description = "Allow Kubernetes API inbound traffic"
  vpc_id      = data.aws_vpc.hub_vpc.id

  ingress {
    description      = "Kubernetes API from {{ rosa_cluster_name }}"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.spoke_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_{{ rosa_cluster_name }}"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint
## Create a VPC Endpoint in the Spoke to consume 6443/tcp from the Hub via PrivateLink
resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-west-2.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg1.id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint_service" "example" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.example.arn]
}

## Create a VPC Endpoint in the Hub to consume 6443/tcp from the Spoke# via PrivateLink
resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-west-2.ec2"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg1.id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint_service" "example" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.example.arn]
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_connection_accepter
# resource "aws_vpc_endpoint" "example" {
#   provider = aws.alternate

#   vpc_id              = aws_vpc.test_alternate.id
#   service_name        = aws_vpc_endpoint_service.test.service_name
#   vpc_endpoint_type   = "Interface"
#   private_dns_enabled = false

#   security_group_ids = [
#     aws_security_group.test.id,
#   ]
# }

# resource "aws_vpc_endpoint_connection_accepter" "example" {
#   vpc_endpoint_service_id = aws_vpc_endpoint_service.example.id
#   vpc_endpoint_id         = aws_vpc_endpoint.example.id
# }

resource "rhcs_cluster_rosa_classic" "rosa_sts_cluster" {
  name                        = var.rosa_cluster_name
  cloud_region                = var.cloud_region
  aws_account_id              = data.aws_caller_identity.current.account_id
  version                     = var.ocp_version
  sts                         = local.sts_roles
  machine_cidr                = data.aws_vpc.tenent_vpc.cidr_block
  aws_private_link            = true
  private                     = true
  aws_subnet_ids              = length(data.aws_subnet.tenent_subnet_id) >= 3 ? [for subnet_id in data.aws_subnet.tenent_subnet_id : subnet_id.id] : [data.aws_subnet.tenent_subnet_id[keys(data.aws_subnet.tenent_subnet_id)[0]].id]
  availability_zones          = length(data.aws_subnet.tenent_subnet_id) >= 3 ? [for subnet_id in data.aws_subnet.tenent_subnet_id : subnet_id.availability_zone] : [data.aws_subnet.tenent_subnet_id[keys(data.aws_subnet.tenent_subnet_id)[0]].availability_zone]
  multi_az                    = length(data.aws_subnet.tenent_subnet_id) >= 3 ? true : false
  pod_cidr                    = "10.128.0.0/14"
  service_cidr                = "172.30.0.0/16"
  channel_group               = "stable"
  compute_machine_type        = var.compute_machine_type
  default_mp_labels           = {}
  destroy_timeout             = 60
  disable_scp_checks          = false
  disable_waiting_in_destroy  = false
  disable_workload_monitoring = false
  fips                        = false
  host_prefix                 = 23
  etcd_encryption             = false
  autoscaling_enabled         = false
  ec2_metadata_http_tokens    = null
  external_id                 = null
  kms_key_arn                 = null
  max_replicas                = null
  min_replicas                = null
  replicas                    = var.rosa_worker_nodes
  proxy                       = null
  tags                        = {}
  properties = {
    rosa_creator_arn = data.aws_caller_identity.current.arn
  }
  depends_on = [
    resource.time_sleep.wait_for_role_propagation
  ]
  admin_credentials = {
    username = var.rosa_admin_username
    password = var.rosa_admin_password
  }
}

resource "rhcs_cluster_wait" "rosa_sts_cluster" {
  cluster = rhcs_cluster_rosa_classic.rosa_sts_cluster.id
  timeout = 60
}

module "operator_roles" {
  source  = "terraform-redhat/rosa-sts/aws"
  version = "0.0.11"
  create_operator_roles = true
  create_oidc_provider  = true
  create_account_roles  = false
  cluster_id                  = rhcs_cluster_rosa_classic.rosa_sts_cluster.id
  rh_oidc_provider_thumbprint = rhcs_cluster_rosa_classic.rosa_sts_cluster.sts.thumbprint
  rh_oidc_provider_url        = rhcs_cluster_rosa_classic.rosa_sts_cluster.sts.oidc_endpoint_url
  operator_roles_properties   = data.rhcs_rosa_operator_roles.operator_roles.operator_iam_roles
  tags                        = var.tags
}

resource "time_sleep" "wait_for_role_propagation" {
  create_duration = "60s"
  depends_on = [
    module.create_account_roles
  ]
}

module "create_account_roles" {
  count   = var.create_account_roles == true ? 1 : 0
  source  = "terraform-redhat/rosa-sts/aws"
  version = "0.0.11"
  create_operator_roles  = false
  create_oidc_provider   = false
  create_account_roles   = true
  rosa_openshift_version = var.ocp_version
  all_versions           = data.rhcs_versions.all
  account_role_prefix    = var.account_role_prefix
  ocm_environment        = var.ocm_environment
  account_role_policies  = data.rhcs_policies.all_policies.account_role_policies
  operator_role_policies = data.rhcs_policies.all_policies.operator_role_policies
  path                   = var.path
}
