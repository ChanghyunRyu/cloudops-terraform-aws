# EKS Module

🇰🇷  이 문서의 [한국어 버전](README.ko.md)을 보시려면 클릭하세요.

This is a top-level module for provisioning an EKS cluster environment automatically.  
It combines several submodules to provision a complete EKS infrastructure, including the cluster itself, node groups, IAM authentication, Bastion Host, CloudWatch integration, and Load Balancer Controller.

## 🚀 Usage

```hcl
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
```

---

## Variables

| Name                | Type           | Required | Description                                                                 |
|---------------------|----------------|----------|-----------------------------------------------------------------------------|
| `name`              | `string`       | ✅        | Prefix for the EKS cluster name                                             |
| `region`            | `string`       | ✅        | AWS region                                                                  |
| `vpc_id`            | `string`       | ✅        | VPC ID where the EKS cluster will be deployed                               |
| `subnet_ids`        | `list(string)` | ✅        | List of subnet IDs to be used by the EKS cluster                            |
| `cluster_version`   | `string`       | ❌        | Kubernetes version of the EKS cluster                                       |
| `node_groups_config`| `map(object)`  | ❌        | Node group configuration (desired/min/max size, instance types, etc.)      |
| `tags`              | `map(string)`  | ❌        | Common tags (optional)                                                      |

- Non-required variables (except `tags`) have default values preconfigured.

## Submodules

| Submodule              | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| `cluster`              | Creates the `aws_eks_cluster` resource to provision the EKS cluster         |
| `node_group`           | Configures managed node groups using `aws_eks_node_group`                   |
| `aws_auth`             | Maps IAM users and roles to Kubernetes users                                |
| `bastion`              | Deploys a bastion host in the public subnet for secure access to the cluster|
| `eks-cloudwatch`       | Enables logging and metrics using the `amazon-cloudwatch-observability` add-on |
| `eks-lb-controller`    | Deploys the AWS Load Balancer Controller to support ALB/ELB integration     |

---

## Notes

- Since this module configures the provider without relying on `kubectl`, you may encounter provider cache errors if you re-run it without any changes after initial provisioning.

