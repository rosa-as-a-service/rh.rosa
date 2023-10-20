locals {
  sts_roles = {
    role_arn         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_prefix}-Installer-Role",
    support_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_prefix}-Support-Role",
    instance_iam_roles = {
      master_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_prefix}-ControlPlane-Role",
      worker_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_role_prefix}-Worker-Role"
    },
    operator_role_prefix = var.operator_role_prefix,
  }
}

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
  tags                        = var.tags
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
  version = "0.0.15"
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
