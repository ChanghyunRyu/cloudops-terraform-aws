variable "name" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "subnet_id" {
    type = string
    description = "Public subnet for Bastion host"
}

variable "instance_type" {
    type = string
    default = "t3.medium"
}

variable "key_name" {
    type = string
    description = "SSH Key name to access bastion"
}

variable "default_tags" {
    type = map(string)
}

variable "cluster_name" {
    type = string
}

variable "region" {
    type = string
    default = "ap-northeast-2"
}