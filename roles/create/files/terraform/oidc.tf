module "oidc_config" {

  token                = var.token
  url                  = var.url
  source               = "./modules/oidc-provider-modules"
  managed              = true
  operator_role_prefix = var.operator_role_prefix
  account_role_prefix  = var.account_role_prefix
  tags                 = var.tags
  cloud_region         = var.cloud_region

  depends_on = [
    resource.rhcs_cluster_wait.rosa_sts_cluster
  ]
}