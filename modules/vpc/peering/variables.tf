# accepter vpc가 모듈에서 생성된 vpc_id
# requester vpc는 사용자한테 입력받는 vpc_id

variable "requester_vpc_id" {
  description = "요청자 VPC의 ID"
  type        = string
}

variable "accepter_vpc_id" {
  description = "수락자 VPC의 ID"
  type        = string
}

variable "requester_vpc_cidr" {
  description = "요청자 VPC의 CIDR 블록"
  type        = string
}

variable "accepter_vpc_cidr" {
  description = "수락자 VPC의 CIDR 블록"
  type        = string
}

variable "requester_route_table_ids" {
  description = "요청자 VPC의 라우트 테이블 ID 목록"
  type        = list(string)
}

variable "accepter_route_table_ids" {
  description = "수락자 VPC의 라우트 테이블 ID 목록"
  type        = map(string)
}

locals {
  accepter_route_table_id_list = values(var.accepter_route_table_ids)
}
