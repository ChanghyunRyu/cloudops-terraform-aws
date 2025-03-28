# EKS와 직접 통신하는 리소스를 먼저 제거
terraform destroy -target=module.eks.module.eks_cloudwatch
terraform destroy -target=module.eks.module.lb_controller
terraform destroy -target=module.eks.module.aws_auth

# EKS 배포된 리소스 먼저 제거
terraform destroy -target=module.argocd

# 그 이후 클러스터 삭제
terraform destroy