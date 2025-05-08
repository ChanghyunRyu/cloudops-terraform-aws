locals {
    # 공통 태그 정의: 사용자 정의 태그와 병합
    default_tags = merge({
        "Project" = var.name
        "ManagedBy" = "Terraform"
    },
    var.tags)

    # private 서브넷 CIDR 계산(az 개수만큼 생성)
    public_subnet_cidrs = [
        for i in range(length(var.azs)) :
        cidrsubnet(var.cidr_block, 8, i)
    ]

    # public 서브넷 CIDR 계산(az 개수만큼 생성)
    private_subnet_cidrs = [
        for i in range(length(var.azs)) :
        cidrsubnet(var.cidr_block, 8, i + length(var.azs))
    ]

    # NAT Gateway를 하나만 쓸 경우 첫 번째 AZ만 사용, 아니면 전체 AZ
    nat_gateway_azs = var.single_nat_gateway ? [var.azs[0]] : var.azs

    # 사용자 정의 서브넷 태그 분기
    public_subnet_tags = try(var.custom_subnet_tags["public"], {})
    private_subnet_tags = try(var.custom_subnet_tags["private"], {})

    # 퍼블릭 서브넷 이름 생성
    public_subnet_names = [
        for az in var.azs :
        "${var.name}-public-${az}"
     ]

    # 프라이빗 서브넷 이름 생성
    private_subnet_names = [
        for az in var.azs :
        "${var.name}-private-${az}"
    ]
}