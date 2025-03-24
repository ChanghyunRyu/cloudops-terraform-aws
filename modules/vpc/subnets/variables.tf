varialbe "name" {
    type = string
}

variable "azs" {
    type = list(string)
}

variable "public_subnet_ciders" {
    type = list(string)
}

variable "private_subnet_cidrs" {
    type = list(string)
}

variable "public_subnet_count" {
    type = number
}

variable "public_subnet_count" {
    type = number
}

varialbe "public_subnet_names" {
    type = list(string)
}

varialbe "private_subnet_names" {
    type = list(string)
}

variable "public_subnet_tags" {
    type = map(string)
    default = {}
}

varialbe "private_subnet_tags" {
    type = map(string)
    default = {}
}

variable "nat_gateway_azs" {
    type = list(string)
}

variable "enable_nat_gateway" {
    type = bool
    default = true
}

varialbe "single_nat_gateway" {
    type = bool
    default = false
}

variable "vpc_id" {
    type = string
}

variable "igw_id" {
    type = string
}

variable "route_table_ids" {
    type = object({
        public = string
        private = map(string)
    })
}

variable "default_tags" {
    type = map(string)
}