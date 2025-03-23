variable "name" {
    type = string
}

variable "cidr_block" {
    type = string
}

variable "enable_dns_support" {
    type = bool
    default = true
}

variable "enable_dns_hostnames" {
    type = bool
    default = true
}

variable "default_tags" {
    type = map(string)
}

variable "azs" {
    type = list(string)
}