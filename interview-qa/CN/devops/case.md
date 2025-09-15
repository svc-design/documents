
DevOps 相关工作经历整理
早期阶段：Linux 发行版与自动化实践

负责 Linux 发行版的日常维护与发布。

使用 Koji、Jenkins 与 Shell 脚本搭建自动化流水线，实现软件包的自动编译、打包、版本发布与 ISO 镜像生成。

在此阶段积累了 CI/CD 基础技能，以及面向系统层的自动化实践经验。

容器化与 DevOps 理念的深化

在灵雀云参与 容器化项目交付，接触并实践了更多 DevOps 相关理念，如 持续集成、持续交付、基础设施即代码。

通过容器编排与交付项目，熟悉了 Kubernetes 与 应用流水线的结合场景。

解决方案架构师阶段：DevOps 系统设计与交付

在 UCloud 云计算 与 华讯网络任职解决方案架构师，正式承担客户侧的 DevOps 平台方案设计与落地工作，主要围绕 GitLab DevOps 平台 + IAC + 云原生架构 进行交付。

项目案例 1：先正达种业公司（AWS EKS + GitLab DevOps 平台）

总体方案：为客户设计并交付基于 AWS EKS + GitLab 的 DevOps 平台。

IAC 模块：开发 Terraform 模块与流水线模板，覆盖账户与资源的自动化创建。

CI/CD 模板：提供面向容器应用的流水线模板，实现 构建 → 验证 → 发布 的标准化。

价值：大幅缩短应用交付周期，帮助客户建立规范化的 DevOps 基础设施与应用交付流程。

项目案例 2：Roche（AWS EKS IAC Pipeline 重构与优化）

代码重构：拆分并优化 EKS Terraform 模块，补充迁移、部署、Add-on 管理、升级等完整功能。

流水线提升：原先仅能自动创建资源，升级为支持 迁移、升级、Add-on 配置与 GitOps 管理 的全生命周期自动化。

成果：交付后流水线自动化覆盖面显著提升，客户能在 EKS 环境变更 → 部署 → 运维 全流程中实现端到端自动化。

项目案例 3：特斯拉 SRE 工作（CI/CD 与 GitOps 实践）

ITSM 系统：基于 GitHub Actions 构建 CI 流程，结合 ArgoCD 实现应用的声明式部署与 GitOps 管理。

DMP 平台：利用 GitHub Actions 与 Jenkins 流水线相结合，实现数据管理平台的持续集成与多环境发布。

亮点：结合 CI/CD + GitOps，实现了运维效率与交付质量的双提升，符合 SRE 工程化运维最佳实践。

综合总结

从 Linux 发行版维护 → 容器化交付 → GitLab DevOps 平台架构设计 → SRE 工程化运维，逐步形成完整的 DevOps 技术栈与实践路径。

技术覆盖范围：CI/CD、IAC（Terraform）、容器化与 Kubernetes、GitOps（ArgoCD）、GitLab/GitHub Actions/Jenkins。

擅长将 开源工具与云平台能力结合，为企业客户交付可落地、可扩展的 DevOps 解决方案。


GitHub Actions DevOps 实践补充

在多个项目中深入使用 GitHub Actions，将其作为核心 CI/CD 引擎，支撑了从 基础设施自动化（IaC） 到 跨平台应用交付 的完整实践：

1. 基础设施即代码（IaC）自动化

Terraform / Pulumi 集成：

编写 GitHub Actions 工作流，实现 AWS、GCP 等多云环境 的自动化创建与管理。

支持模块化部署（VPC、EKS、IAM、GCP Project 等），并结合环境变量与 Secrets 管理多账户配置。

价值：提升了 多云环境交付速度，减少了人工操作与配置漂移。

2. 应用构建与测试

构建流水线：

针对 服务端容器化应用，实现自动化构建 → 单元测试 → 集成测试 → 镜像发布 → 多环境部署。

针对 桌面端应用（macOS、Linux、Windows），配置多平台矩阵构建，自动生成安装包与可执行文件。

测试集成：

在流水线中执行 单元测试、集成测试、端到端验证，确保发布质量。

对接 artifact 存储与版本控制，支持版本回滚与快速分发。

3. 部署与交付

容器化应用：结合 ArgoCD/GitOps 实现 Kubernetes 环境的自动化发布与回滚。

桌面端发布：通过 GitHub Release 自动产出 安装包/更新包，并同步至制品仓库或 CDN 分发。

部署包与同步：

自动生成部署包（tar/zip/deb/rpm 等格式），并同步至 内部制品仓库、Pulp Server 或 OSS/S3。

保证部署制品在 CI → 测试 → 生产环境 的一致性。

4. 实践亮点

在 IAC 自动化、多云交付、跨平台构建、端到端测试与发布 上形成了 完整 DevOps 流程。

善于结合 GitHub Actions + Terraform/Pulumi + 容器化/GitOps，实现 云资源与应用的全链路自动化。

覆盖了 企业级应用场景：从 桌面端客户端交付 到 服务端微服务平台上线，均可通过统一流水线管理。

👉 这样整理后，你的 DevOps 技能矩阵 就非常完整了（CI/CD、IaC、容器化、GitOps、跨平台应用交付）。
