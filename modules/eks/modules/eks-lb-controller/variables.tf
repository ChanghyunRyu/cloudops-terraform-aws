variable "name" {
    type = string
}

variable "cluster_name" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "service_account_name" {
    type = string
}

variable "region" {
    type = string
    default = "ap-northeast-2"
}

variable "lb_controller_irsa_name" {
    type = string
}

variable "lb_controller_irsa_arn" {
    type = string
}
