################################
# RHCS / OCM
################################

variable "token" {
  type      = string
  sensitive = true
}

variable "url" {
  type    = string
  default = "https://api.openshift.com"
}

################################
# AWS
################################

variable "cloud_region" {
  type = string
}

variable "account_role_prefix" {
  type = string
}

variable "operator_role_prefix" {
  type = string
}

################################
# Cluster
################################

variable "rosa_cluster_name" {
  type = string
}

variable "ocp_version" {
  type    = string
  default = "4.18.0"
}

variable "rosa_worker_nodes" {
  type    = number
  default = 2
}

variable "compute_machine_type" {
  type    = string
  default = "m5.xlarge"
}

variable "private" {
  type    = bool
  default = false
}

variable "host_prefix" {
  type    = number
  default = 23
}

variable "pod_cidr" {
  type    = string
  default = "10.128.0.0/14"
}

variable "service_cidr" {
  type    = string
  default = "172.30.0.0/16"
}

variable "machine_cidr" {
  type    = string
  default = null
}

variable "etcd_encryption" {
  type    = bool
  default = false
}

variable "fips" {
  type    = bool
  default = false
}

variable "channel_group" {
  type    = string
  default = "stable"
}

variable "rosa_admin_username" {
  type    = string
  default = "cluster-admin"
}

variable "rosa_admin_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "path" {
  type    = string
  default = "/"
}

variable "permissions_boundary" {
  type    = string
  default = ""
}

variable "destroy_timeout" {
  type    = number
  default = 60
}
