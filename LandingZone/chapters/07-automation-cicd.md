# 7. 自动化与 CI/CD 流程 (Automation and CI/CD Processes)

覆盖 Terraform 在 GitHub Actions 与 GitLab CI 的流水线：环境（dit/uat/prod）、分支（main/dev）、如何引用 env、如何管控敏感信息、以及如何复用模块与模板（pipeline-template + Python + git-config-repo + env + secret-env）。

1) 目录与分层建议

infra/
├─ modules/                     # 复用模块（或单独仓库 iac-modules）
│  ├─ vpc/
│  └─ eks/
├─ envs/                        # 按环境分层
│  ├─ dit/
│  │  ├─ backend.hcl           # 仅存储后端与锁表信息（无密钥）
│  │  ├─ terraform.tfvars      # 非敏感配置（地域/实例数阈值等）
│  │  └─ providers.tf          # 使用 OIDC/临时凭证，不写死密钥
│  ├─ uat/
│  └─ prod/
├─ stacks/                      # 业务栈（组合多个模块）
│  ├─ network/
│  │  └─ main.tf               # 引用 modules/*
│  └─ app/
│     └─ main.tf
├─ pipeline/
│  ├─ template.common.yml      # 通用流水线模板（被 GitHub/GitLab 共用的命令片段）
│  └─ render_backend.py        # 生成/渲染 backend.hcl、env 变量的辅助脚本
└─ README.md

2) 模块复用（版本可控）

在业务栈里引用模块时，固定 tag/commit，避免漂移：

module "vpc" {
  source = "git::ssh://git@github.com/your-org/iac-modules.git//vpc?ref=v0.3.2"
  name   = var.name
  cidr   = var.vpc_cidr
}


若模块单仓库：用 Release Tag 管控版本，流水线里允许通过输入 MODULES_REF 覆盖。

3) 环境变量与后端（Backend）处理

backend.hcl 只写非机密后端信息：

AWS：bucket, key, region, dynamodb_table

阿里云：bucket, prefix, region（Terraform OSS 后端）

机密（如凭证）不放 backend.hcl，用 OIDC/临时凭证 或 CI Secret 注入。

通过 TF CLI Config 文件（~/.terraformrc）或 TF_REGISTRY_CLIENT_... 处理私有模块/私有 registry 的 token（由 CI Secret 注入）。

4) 敏感信息管理（推荐优先级）

OIDC + 云端角色扮演（AssumeRole）：CI 不存长期密钥（最佳实践）。

Vault/SOPS：把 *.tfvars.enc 解密为临时文件（作业结束清理）。

CI Secret/Protected Variables：以 TF_VAR_xxx 注入（变量名即 Terraform 变量）。

规则：

不提交任何明文密钥到仓库。

terraform.tfvars 只放非敏感参数；敏感项走 TF_VAR_* 注入或解密出来的临时 secret.auto.tfvars。

prod 的变量/凭证用 Protected / 环境级别 Secret，且需要审批。

## 7.1 自动化 Landing Zone 部署 (Automated Landing Zone Deployment)
TODO: Add content

## 7.2 使用 Terraform、CloudFormation 等工具 (Using Terraform, CloudFormation, etc.)
TODO: Add content

## 7.3 跨云平台的资源配置自动化 (Cross-Cloud Resource Configuration Automation)
TODO: Add content

## 7.4 CI/CD 集成与多云自动化管理 (CI/CD Integration and Multi-Cloud Automation)
TODO: Add content




## 7.5 合规性和安全性的自动化验证 (Automated Compliance and Security Validation)
TODO: Add content
