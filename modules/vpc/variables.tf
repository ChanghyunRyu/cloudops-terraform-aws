variable "name" {
    description = "VPC 및 관련 리소스 이름 prefix"
    type = string
}

variable "cidr_block" {
    description = "CIDR block"
    type = string
}

variable "azs" {
    description = "available zones (ex: [\"ap-northeast-2a\", \"ap-northeast-2c\"])"
    type = list(string)
}

variable "public_subnet_count" {
    description = "AZ 당 public subnet 수"
    type = number
    default = 1
}

variable "private_subnet_count" {
    description = "AZ 당 private subnet 수"
    type = number
    default = 1
}

variable "enable_nat_gateway" {
  description = "NAT Gateway를 생성할지 여부"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "true일 경우 하나의 NAT Gateway만 생성 (비용 절감)"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "VPC에서 DNS 지원 활성화 여부"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "VPC에서 DNS hostname 활성화 여부"
  type        = bool
  default     = true
}

variable "tags" {
  description = "common tag sets"
  type        = map(string)
  default     = {}
}

variable "custom_subnet_tags" {
  type = map(map(string))
  default = {}
}