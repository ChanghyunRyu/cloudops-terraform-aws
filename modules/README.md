# Terraform Modules

🇰🇷  이 문서의 [한국어 버전](README.ko.md)을 보시려면 클릭하세요.

This directory contains reusable Terraform modules that are composed together to build complete infrastructure environments such as `shared`, `dev`, and `prod`.

Each module is self-contained and focuses on a specific infrastructure component (e.g., VPC, EKS, S3), promoting reusability and maintainability.

Detailed usage instructions and variable definitions can be found in each module's respective `README.md` file.

---

## 📁 Directory Structure

```
modules/
├── vpc/               # VPC provisioning module
├── eks/               # EKS cluster module (includes cluster, nodes, IAM, addons)
├── argocd/            # argocd module
```

---

## 📚 Module Documentation Format

Each module includes its own `README.md`, typically following the structure below:

| Section        | Description                                                                 |
|----------------|-----------------------------------------------------------------------------|
| Header         | Module name, optional language toggle link (e.g., 🇰🇷 한글 버전 링크)             |
| Overview       | What this module does and which infrastructure components it manages       |
| Usage          | Terraform usage example with module input configuration                    |
| Variables      | Table describing input variables, types, required status, and descriptions |
| Submodules     | (If applicable) Explanation of internal structure and nested modules       |
| Notes          | Any warnings, tips, provider caveats, or special behavior to be aware of   |

This format ensures consistency across modules and makes it easy for users to understand and apply each module in different environments.