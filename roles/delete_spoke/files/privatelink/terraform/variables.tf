
################################
# OCM SHARED
################################

variable "AWS_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
  default   = ""
}

variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
  default   = ""
}

variable "AWS_DEFAULT_REGION" {
  type      = string
  sensitive = true
  default   = ""
}

variable "rosa_cluster_name" {
  type    = string
  default = ""
}

variable "rosa_vpc_name" {
  type    = string
  default = ""
}

variable "rosa_hub_cluster_infra_id" {
  type    = string
  default = ""
}

variable "rosa_base_domain" {
  type    = string
  default = ""
}