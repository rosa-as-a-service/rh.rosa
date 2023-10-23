
################################
# OCM SHARED
################################

variable "AWS_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
  default = ""
}

variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
  default = ""
}

variable "AWS_DEFAULT_REGION" {
  type      = string
  sensitive = true
  default = ""
}