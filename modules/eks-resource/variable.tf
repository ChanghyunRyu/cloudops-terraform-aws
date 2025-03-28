variable "name" {
    type = string
}

variable "tags" {
    type = map(string)
}

variable "eks_cluster_endpoint" {
    type = string
}

variable "eks_cluster_name" {
    type = string
}

variable "eks_cluster_certificate_authority" {
    type = string
}

variable "node_group_role_arn" {
    type = string
}

variable "enable_bastion" {
    type = bool
    default = false
}

variable "vpc_id" {
    type = string
}

variable "subnet_id" {
    type = string
    default = null
}

variable "key_name" {
    type = string
    description = "SSH Key name to access bastion"
    default = null
}

variable "region" {
    type = string
    default = "ap-northeast-2"
}
