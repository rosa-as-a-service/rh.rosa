data "aws_caller_identity" "current" {}

locals {
  sts_roles = {
    role_arn         = aws_iam_role.account_role[0].arn
    support_role_arn = aws_iam_role.account_role[1].arn
    instance_iam_roles = {
      worker_role_arn = aws_iam_role.account_role[2].arn
    }
    operator_role_prefix = var.operator_role_prefix
    oidc_config_id       = rhcs_rosa_oidc_config.oidc_config.id
  }
}

resource "rhcs_cluster_rosa_hcp" "cluster" {
  name               = var.rosa_cluster_name
  cloud_region       = var.cloud_region
  aws_account_id     = data.aws_caller_identity.current.account_id
  aws_billing_account_id = data.aws_caller_identity.current.account_id
  aws_subnet_ids     = [for s in data.aws_subnet.cluster_subnet : s.id]
  availability_zones = distinct([for s in data.aws_subnet.cluster_subnet : s.availability_zone])
  replicas           = var.rosa_worker_nodes
  version            = var.ocp_version
  channel_group      = var.channel_group
  compute_machine_type = var.compute_machine_type
  machine_cidr       = var.machine_cidr
  pod_cidr           = var.pod_cidr
  service_cidr       = var.service_cidr
  host_prefix        = var.host_prefix
  etcd_encryption    = var.etcd_encryption
  fips               = var.fips
  private            = var.private
  destroy_timeout    = var.destroy_timeout
  tags               = var.tags
  sts                = local.sts_roles

  properties = {
    rosa_creator_arn = data.aws_caller_identity.current.arn
  }

  wait_for_create_complete            = true
  wait_for_std_compute_nodes_complete = true

  admin_credentials = var.rosa_admin_password != "" ? {
    username = var.rosa_admin_username
    password = var.rosa_admin_password
  } : null

  depends_on = [
    time_sleep.account_iam_resources_wait,
    time_sleep.oidc_resources_wait,
    time_sleep.operator_roles_wait,
  ]
}
