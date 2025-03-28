variable "name" {
    type = string
}

variable "cluster_name" {
    type = string
}

variable "addon_version" {
    type = string
    default = "v3.5.0-eksbuild.1"
}

variable "default_tags" {
    type = map(string)
}

variable "irsa_role_name" {
  type = string
}

variable "irsa_role_arn" {
  type = string
}