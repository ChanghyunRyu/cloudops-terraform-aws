# cloudops-terraform-aws

🇰🇷  이 문서의 [한국어 버전](README.ko.md)을 보시려면 클릭하세요.

## Overview

- This is a template project designed to provision `shared` / `dev` / `prod` environments using Terraform in an automated and structured manner.
- It is built on custom Terraform modules to configure key AWS resources such as VPC, EKS, S3, IAM, CloudWatch, and ArgoCD. The structure is intended to be extensible for future components.
- The overall architecture is designed with real-world production environments in mind, emphasizing modularity and environment separation. Some configurations may require adjustment depending on the target project.

## Project Structure

### # Architecture Diagram

![Image](https://github.com/user-attachments/assets/2f622f64-0c0a-4a23-857c-6ee5e5b82433)

### # Directory Layout

```
modules/
├── vpc/
├── eks/
├── s3/
└── ...

environments/
├── shared/
├── dev/
└── prod/
```

### # Environment Separation Strategy

- **VPC Isolation**: Each environment (shared / dev / prod) resides in a separate VPC.
- **VPC Peering**: Peering is configured between dev-shared and prod-shared environments.

---

## Usage

For detailed usage instructions, refer to the README files under each environment directory (e.g., `environments/dev`). Please follow the deployment order carefully to prevent potential issues during resource teardown.

```
cd environments/shared
./deploy.sh
```

### # Requirements

- Terraform >= 1.x
- AWS CLI configured
- Sufficient AWS IAM permissions (e.g., VPC, EKS, S3 resource creation)

### # Considerations

| Item             | Notes                                                                 |
|------------------|-----------------------------------------------------------------------|
| Estimated Time   | TBD (to be added later)                                              |
| Cost Estimate    | TBD (to be added later)                                              |
| IAM Permissions  | Admin-level for setup; follow least-privilege for operation          |
| State Management | Separate state files per environment; state is not shared            |