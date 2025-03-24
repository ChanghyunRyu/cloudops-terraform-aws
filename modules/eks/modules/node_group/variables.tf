variable "name" {
    type = string
}

variable "cluster_name" {
    type = string
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "default_tags" {
    type = map(string)
}

variable "instance_types" {
    type = list(string)
    default = ["t3.medium"]
}

variable "disk_size" {
    type = number
    default = 30
}

variable "desired_size" {
    type = number
    default = 2
}

variable "max_size" {
    type = number
    default = 6
}

variable "min_size" {
    type = number
    default = 1
}