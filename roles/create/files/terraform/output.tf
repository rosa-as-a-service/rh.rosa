output "cluster_id" {
  value = rhcs_cluster_rosa_hcp.cluster.id
}

output "cluster_api_url" {
  value = rhcs_cluster_rosa_hcp.cluster.api_url
}

output "cluster_console_url" {
  value = rhcs_cluster_rosa_hcp.cluster.console_url
}

output "cluster_domain" {
  value = rhcs_cluster_rosa_hcp.cluster.domain
}

output "oidc_config_id" {
  value = rhcs_rosa_oidc_config.oidc_config.id
}

output "oidc_endpoint_url" {
  value = rhcs_rosa_oidc_config.oidc_config.oidc_endpoint_url
}
