resource "rhcs_rosa_oidc_config" "oidc_config" {
  managed = true
}

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = "https://${rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url}"

  client_id_list = [
    "openshift",
    "sts.amazonaws.com",
  ]

  thumbprint_list = [rhcs_rosa_oidc_config.oidc_config.thumbprint]

  tags = var.tags
}

resource "time_sleep" "oidc_resources_wait" {
  create_duration  = "10s"
  destroy_duration = "10s"
  triggers = {
    oidc_config_id    = rhcs_rosa_oidc_config.oidc_config.id
    oidc_endpoint_url = rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url
    oidc_provider_url = aws_iam_openid_connect_provider.oidc_provider.url
  }
}
