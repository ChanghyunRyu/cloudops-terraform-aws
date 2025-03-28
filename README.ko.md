# cloudops-terraform-aws

🇺🇸 [Click here](README.md) to view this document in English.

## 개요

- Terraform을 이용해 shared/ dev/ prod 환경을 자동화된 방식으로 구성하기 위한 템플릿 프로젝트입니다.
- 직접 작성한 모듈을 기반으로 VPC, EKS, S3, IAM, CloudWatch, ArgoCD 등을 설정하며, 구성요소는 향후 확장될 수 있습니다.
- 상기 기술 구성을 실무 환경에서 적용할 것을 가정하고 구성했으며, 기본적인 환경 분리 및 모듈화를 통해 실무에 근접한 구조로 구현했습니다. 일부 구성은 프로젝트에 맞게 조정이 필요할 수 있습니다.

## 구성 구조

### # 아키텍처 다이어그램

![Image](https://github.com/user-attachments/assets/2f622f64-0c0a-4a23-857c-6ee5e5b82433)

### # 디렉토리 구조

~~~
modules/
├── vpc/
├── eks/
├── s3/
└── ...

environments/
├── shared/
├── dev/
└── prod/
~~~

### # 환경 분리 전략

- VPC 분리: shared / dev / prod는 각기 다른 VPC에 구성
- VPC Peering: dev-shared, prod-shared 간 통신 연결

---

## 사용 방법

각 환경 별 자세한 사용법은 environments/ 환경 디렉토리의 README를 참고해주세요. 정해진 순서대로 배포하지 않을 경우, 환경 삭제 시에 문제가 발생할 수 있습니다.
~~~
cd environments/shared
./deploy.sh
~~~

### # 요구 조건

- Terraform >= 1.x
- AWS CLI 설정 
- AWS IAM 권한 (VPC, EKS, S3 등 생성 가능 수준)

### # 사전 고려 사항

| 항목     | 비고              |
| ------ | --------------- |
| 소요 시간  | TBD (추후 추가)     |
| 비용 예측  | TBD (추후 추가)     |
| IAM 권한 | 관리자 수준 또는 제한 명시 |
| State 관리 | 환경별로 상태파일 분리, 같은 state를 공유하지 않음|

