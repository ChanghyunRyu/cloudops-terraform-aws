# terraform aws platform

> 🇰🇷 [한국어로 보기](./README.ko.md)

This project automates AWS infrastructure using Terraform.  
Each environment (`dev`, `prod`, `shared`) is managed independently with isolated configurations. All infrastructure components are modularized for reusability and maintainability.

---

## 📐 Architecture Overview

This project automates the provisioning of the following AWS infrastructure components:

- VPC and Subnet structure (Public and Private Subnets)
- NAT Gateways and Route Table configuration
- EKS Cluster with Private Endpoint only
- Bastion Host for secure `kubectl` access
- Fluent Bit for log collection and integration with CloudWatch
- (More to be added)

<!-- Architecture diagram image will be added later -->
<!-- ![architecture](docs/architecture.png) -->

---

## 🧱 Module Overview

This project is composed of the following Terraform modules:

### `modules/vpc`
- Creates VPC, Internet Gateway, NAT Gateway, subnets, and route tables
- Supports automatic CIDR splitting
- Includes a separate submodule `modules/vpc/modules/peering` for VPC peering

### `modules/eks`
- Creates an EKS cluster with private-only endpoint
- Manages IAM roles and security groups
- Uses the Helm Provider to install Fluent Bit, AWS Load Balancer Controller, and other EKS tools

### `modules/security_group`
- Defines reusable security groups
- Configurable for EKS, Bastion Hosts, and other resources

For more details, refer to the `README.md` in each module directory.

---

## 🔧 Environment Directory Structure

```bash
terraform-aws-platform/
├── modules/                # Reusable Terraform modules
├── environments/
│   ├── dev/                # Development environment
│   ├── shared/             # Shared infrastructure (e.g., base VPC)
│   └── prod/               # Production environment
└── README.md
