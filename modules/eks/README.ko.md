# EKS Module

🇺🇸 [Click here](README.md) to view this document in English.

EKS 클러스터 환경을 자동으로 구성하기 위한 상위 모듈입니다.  
하위 모듈들을 조합하여 클러스터, 노드 그룹, IAM 인증 구성, Bastion Host, CloudWatch 통합, Load Balancer Controller까지 포함한 EKS 인프라를 구성합니다.


## Usage

~~~hcl
module "eks" {
  source = "./eks"

  name                = "my-eks"
  region              = "ap-northeast-2"
  vpc_id              = module.vpc.id
  subnet_ids          = module.vpc.private_subnet_ids
  cluster_version     = "1.29"

  node_groups_config = {
    default = {
      desired_size   = 2
      max_size       = 3
      min_size       = 1
      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Environment = "dev"
    Team        = "cloud"
  }
}
~~~

---

## 변수 설명 (Variables)

| 변수명           | 타입           | 필수 여부 | 설명                                   |
|------------------|----------------|------------|----------------------------------------|
| `name`           | `string`       | ✅         | EKS 클러스터 이름 접두사               |
| `region`         | `string`       | ✅         | AWS 리전                               |
| `vpc_id`         | `string`       | ✅         | EKS 클러스터가 배치될 VPC ID           |
| `subnet_ids`     | `list(string)` | ✅         | EKS가 사용하는 서브넷 ID 목록          |
| `cluster_version`| `string`       | ❌         | EKS Kubernetes 버전                     |
| `node_groups_config`    | `map(object)`  | ❌         | 노드 그룹 구성 (desired/min/max size 등)|
| `tags`           | `map(string)`  | ❌         | 공통 태그 (선택)                        |

- tags를 제외한 필수가 아닌 variable은 default 값으로 입력됩니다.


## 하위 모듈 설명

| 하위 모듈             | 설명 |
|------------------------|------|
| `cluster`              | `aws_eks_cluster` 리소스를 생성하여 클러스터를 구성합니다. |
| `node_group`           | `aws_eks_node_group`을 통해 관리형 노드 그룹을 구성합니다. |
| `aws_auth`             | IAM 사용자 및 역할을 Kubernetes 사용자로 매핑합니다. |
| `bastion`              | bastion host를 퍼블릭 서브넷에 구성하여 클러스터 접근을 지원합니다. |
| `eks-cloudwatch`       | `amazon-cloudwatch-observability` 애드온을 통해 로그/메트릭 수집을 설정합니다. |
| `eks-lb-controller`    | AWS Load Balancer Controller를 배포하여 ALB/ELB 연동을 지원합니다. |

---

## 참고 사항

- 해당 모듈은 kubectl 없이 provider를 형성하기 때문에 생성 후 변경점 없이 실행됐을 때 provider 캐시 문제로 오류가 발생할 수 있습니다.
