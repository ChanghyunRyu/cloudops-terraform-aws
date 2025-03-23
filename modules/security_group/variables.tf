variable "name" {
  description = "Security Group의 이름 prefix"
  type        = string
}

variable "description" {
  description = "Security Group에 대한 설명"
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "Security Group이 속할 VPC ID"
  type        = string
}

variable "ingress_rules" {
    description = <<EOT
    Ingress 룰 리스트. 각 항목은 다음 형식:
    {
        from_port        = number
        to_port          = number
        protocol         = string
        cidr_blocks      = list(string)         # optional
        ipv6_cidr_blocks = list(string)         # optional
        security_groups  = list(string)         # optional
        self             = bool                 # optional, default: false
        description      = string               # optional
    }
    EOT
    type    = list(object({
        from_port        = number
        to_port          = number
        protocol         = string
        cidr_blocks      = optional(list(string))
        ipv6_cidr_blocks = optional(list(string))
        security_groups  = optional(list(string))
        self             = optional(bool)
        description      = optional(string)
    }))
    default = []
}

variable "egress_rules" {
  description = "ingress_rules와 동일한 구조"
  type        = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    security_groups  = optional(list(string))
    self             = optional(bool)
    description      = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "추가 태그 세트"
  type        = map(string)
  default     = {}
}
