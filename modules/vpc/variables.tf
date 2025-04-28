variable "name" {
    description = "VPC 및 관련 리소스 이름 prefix"
    type = string

    validation {
      condition = (
        length(var.name) > 0 && length(var.name) <= 50
      )
      error_message = "name 변수는 1자 이상 50자 이하의 문자열이어야 합니다."
    }
}

variable "cidr_block" {
    description = "CIDR block"
    type = string
    
    validation {
      condition = can(cidrhost(var.cidr_block, 0))
      error_message = "cidr_block 변수는 유효한 CIDR 형식(예: 10.0.0.0/16)이어야 합니다."
    }
}

variable "azs" {
    description = "available zones (ex: [\"ap-northeast-2a\", \"ap-northeast-2c\"])"
    type = list(string)

    validation {
      condition = length(var.azs) > 0
      error_message = "azs 변수는 최소 1개 이상의 AZ를 지정해야 합니다."
    }
}

variable "public_subnet_count" {
    description = "AZ 당 public subnet 수"
    type = number
    default = 1

    validation {
      condition = var.public_subnet_count >= 1
      error_message = "AZ당 최소 1개 이상의 public subnet을 지정해야 합니다."
    }
}

variable "private_subnet_count" {
    description = "AZ 당 private subnet 수"
    type = number
    default = 1

    validation {
      condition = var.private_subnet_count >= 1
      error_message = "AZ당 최소 1개 이상의 private subnet을 지정해야 합니다."
    }
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

variable "enable_peering" {
  type = bool
  default = false
}

variable "peer_vpc_id" {
  type = string
  default = null

  validation {
    condition = (
      var.enable_peering == false || (var.enable_peering == true && var.peer_vpc_id != null && length(var.peer_vpc_id) >0)
      error_message = "Peering을 활성화할 경우(peer_vpc_id)는 반드시 지정해야 합니다."
    )
  }
}

variable "peer_cidr_block" {
  type = string
  default = null
  validation {
    condition = (
      var.enable_peering == false || (var.enable_peering == true && var.peer_cidr_block != null && can(cidrhost(var.peer_cidr_block, 0)))
    )
    error_message = "Peering을 활성화할 경우(peer_cidr_block)는 유효한 CIDR 형식이어야 합니다."
  }
}

variable "peer_route_table_ids" {
  type = list(string)
  default = null
  validation {
    condition = (
      var.enable_peering == false || (var.enable_peering == true && var.peer_route_table_ids != null && length(var.peer_route_table_ids) > 0)
    )
    error_message = "Peering을 활성화할 경우(peer_route_table_ids)는 최소 1개 이상 입력해야 합니다."
  }
}