variable "AWS_DEFAULT_REGION" {
  description = "AWS region"
  type = string
  default = ""
}
variable "AWS_ACCESS_KEY_ID" {
  description = "AWS access ID"
  type = string
  default = ""
}
variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS access key"
  type = string
  default = ""
}
variable "subnet_id" {
  description = "Subnet in which to install the Bastion"
  type = string
  default = ""
}
variable "admin_user" {
  description = "The OpenShift admin user"
  type = string
  default = ""
  sensitive = true
}
variable "admin_password" {
  description = "The OpenShift admin password"
  type = string
  default = ""
  sensitive = true  
}
variable "domain" {
  description = "The Openshift Base domain"
  type = string
  default = ""  
}