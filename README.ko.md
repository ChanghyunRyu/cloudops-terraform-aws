# terraform aws platform

> 🇺🇸 [View this in English](./README.md)

Terraform을 이용하여 AWS 기반 인프라를 코드로 자동화한 프로젝트입니다.  
개별 환경(`dev`, `prod`, `shared`)은 분리된 구성을 통해 독립적으로 관리되며, 모든 인프라는 모듈화되어 재사용 가능한 형태로 설계되어 있습니다.

---

## 📐 프로젝트 아키텍처 개요

이 프로젝트는 다음과 같은 인프라 구성 요소를 자동화합니다:

- VPC 및 서브넷 구조 (Public, Private Subnet 분리)
- NAT Gateway 및 Route Table 자동 구성
- EKS 클러스터 (Private Endpoint Only)
- Bastion Host를 통한 `kubectl` 접근
- Fluent Bit 기반 로그 수집 및 CloudWatch 연동
- (추가 예정)

<!-- 추후 아키텍처 다이어그램 이미지 삽입 예정 -->
<!-- ![architecture](docs/architecture.png) -->

---

## 🧱 모듈 구성 개요

이 프로젝트는 다음과 같은 Terraform 모듈로 구성되어 있습니다:

### `modules/vpc`
- VPC, IGW, NAT Gateway, 서브넷 및 라우팅 자동 생성
- CIDR 자동 분할 기능 제공
- VPC 피어링 기능은 `modules/vpc/modules/peering` 하위 모듈로 분리

### `modules/eks`
- EKS 클러스터 자동 생성
- private-only endpoint 구성
- IAM Role, Security Group 자동 설정
- Helm Provider를 통해 EKS 상에 Fluent Bit, AWS Load Balancer Controller 등의 도구 자동 배포

### `modules/security_group`
- 재사용 가능한 SG 구성 정의
- EKS, Bastion Host 등에 맞춤 설정 가능

각 모듈과 하위 모듈에 대한 상세한 설명은 해당 모듈 디렉토리의 `README.md`에 포함되어 있습니다.

---

## 🔧 환경별 디렉토리 구조

```bash
terraform-aws-platform/
├── modules/                # 재사용 가능한 모듈 정의
├── environments/
│   ├── dev/                # 개발 환경 구성
│   ├── shared/             # 공통 인프라(VPC 등)
│   └── prod/               # 운영 환경 구성
└── README.md
