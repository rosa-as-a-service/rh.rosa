variable "public_vpc_cidr" {
  type = string
  default = "{{public_vpc_cidr}}"
}
variable "private_vpc_cidr" {
  type = string
  default = "{{private_vpc_cidr}}"
}
variable "cluster_name" {
  type = string
  default = "{{rosa_vpc_name}}"
}

variable "AWS_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
  default = "{{ aws_access_key_id }}"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
  default = "{{ aws_secret_access_key }}"
}

variable "AWS_DEFAULT_REGION" {
  type      = string
  sensitive = true
  default = "{{ rosa_region }}"
}
