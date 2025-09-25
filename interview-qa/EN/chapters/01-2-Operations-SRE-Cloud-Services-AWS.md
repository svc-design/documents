AWS 面试速查表（中英文对照）

| 类别 (Category) | 服务 (Services) | 关键要点 (Key Points) |
|:----|:----|:----|
| 计算 (Compute) | EC2 | 弹性计算实例，支持按需/预留/SpotElastic Compute Cloud, supports On-Demand/Reserved/Spot |
| ​ | Lambda | 无服务器函数，事件驱动Serverless function, event-driven |
| ​ | ECS / EKS | 容器编排，EKS = Kubernetes 托管服务Container orchestration, EKS = Managed Kubernetes |
| ​ | Elastic Beanstalk | PaaS，快速部署应用（了解即可）PaaS for quick deployment (basic knowledge) |
| 存储 (Storage) | S3 | 对象存储，存储类型（Standard, IA, Glacier），生命周期策略Object storage, storage classes (Standard, IA, Glacier), lifecycle policy |
| ​ | EBS | 块存储，挂载到 EC2Block storage, attachable to EC2 |
| ​ | EFS | 跨实例共享文件系统Shared file system across instances |
| 网络 (Networking) | VPC | 虚拟私有云，子网、公有/私有网络、路由表Virtual Private Cloud, subnets, public/private, route table |
| ​ | ELB (ALB/NLB/CLB) | 负载均衡，7层/4层Load balancing, L7/L4 |
| ​ | CloudFront | 全球 CDN 加速Global CDN |
| ​ | Direct Connect / VPN | 混合云连接Hybrid cloud connectivity |
| 数据库 (Database) | RDS | 托管关系型数据库，支持 MySQL/Postgres/AuroraManaged relational DB, MySQL/Postgres/Aurora |
| ​ | DynamoDB | NoSQL，高可用低延迟NoSQL, highly available & low latency |
| ​ | Aurora | AWS 自研数据库，兼容 MySQL/PostgresAWS-managed DB, MySQL/Postgres-compatible |
| ​ | ElastiCache | Redis / Memcached 缓存Redis/Memcached cache |
| 安全 (Identity & Security) | IAM | 用户、角色、策略，最小权限原则Users, roles, policies, least privilege |
| ​ | KMS | 密钥管理，加密Key Management Service, encryption |
| ​ | Cognito | 应用用户认证User identity and authentication |
| ​ | GuardDuty / WAF / Shield | 威胁检测与防护Threat detection and protection |
| 监控与运维 (Monitoring & Ops) | CloudWatch | 指标、日志、告警Metrics, logs, alerts |
| ​ | CloudTrail | 审计 API 调用Audit API calls |
| ​ | Config | 合规检查，追踪资源变化Compliance check, resource change tracking |
| ​ | Systems Manager (SSM) | 批量运维、参数存储Ops automation, parameter store |
| DevOps / IaC | CloudFormation | AWS 原生 IaCAWS-native IaC |
| ​ | Terraform | 第三方 IaC，多云支持3rd-party IaC, multi-cloud support |
| ​ | CodePipeline / CodeBuild / CodeDeploy | AWS CI/CD 工具链AWS CI/CD toolchain |
| ​ | GitHub Actions + ArgoCD | 常用组合：CI 在 GitHub，CD 用 GitOpsCommon setup: CI in GitHub, CD with GitOps (ArgoCD) |


## 1. AWS 基础与架构设计

**Q:** 你最常用的 AWS 服务有哪些？
 **Q:** Which AWS services do you use most often?

**A:**
 我主要用 **EC2、S3、RDS、EKS、IAM 和 CloudWatch**。EC2 和 EKS 是计算核心，S3 用于存储，RDS 管理数据库，IAM 做访问控制，CloudWatch 用于监控和告警。
 I mostly use **EC2, S3, RDS, EKS, IAM, and CloudWatch**. EC2 and EKS for compute, S3 for storage, RDS for database management, IAM for access control, and CloudWatch for monitoring and alerting.

----

**Q:** 你会如何在 AWS 上设计一个高可用的三层应用架构？
 **Q:** How would you design a highly available 3-tier application architecture on AWS?

**A:**

-  Web 层：放在 ALB 背后，跨多个 AZ 的 EC2 或 EKS 节点。

-  应用层：EKS/ECS 托管容器，使用 Auto Scaling。

-  数据层：RDS Multi-AZ 或 Aurora，读写分离。

-  配合 CloudFront 加速，CloudWatch + GuardDuty 做监控与安全。

-  Web: Behind ALB, across multi-AZ EC2 or EKS nodes.

-  App: Managed containers on EKS/ECS with Auto Scaling.

-  DB: RDS Multi-AZ or Aurora with read replicas.

-  Plus CloudFront for acceleration, CloudWatch + GuardDuty for monitoring & security.


----

## 2. IaC 与自动化

**Q:** 你如何用 Terraform 管理 AWS 资源？
 **Q:** How do you manage AWS resources with Terraform?

**A:**
 我会把 VPC、EKS、RDS 分别写成模块，状态存到 S3 + DynamoDB。代码走 GitHub PR，合并后用 GitHub Actions 触发 `terraform plan` 和 `apply`。
 I modularize VPC, EKS, and RDS, store state in S3 + DynamoDB. All changes go through GitHub PR, and GitHub Actions runs `terraform plan` and `apply` after merge.

----

**Q:** 你怎么比较 Terraform 和 CloudFormation？
 **Q:** How do you compare Terraform with CloudFormation?

**A:**
 Terraform 跨云能力更强，社区资源多；CloudFormation 深度集成 AWS，适合纯 AWS 环境。
 Terraform is multi-cloud and has richer modules; CloudFormation is AWS-native and integrates better in AWS-only environments.

----

## 3. CI/CD

**Q:** 你会如何用 GitHub Actions 做 CI？
 **Q:** How do you design CI pipelines with GitHub Actions?

**A:**

-  步骤：代码检查 → 单元测试 → 构建镜像 → 推送到 ECR。

-  用 cache 缓存依赖，加速构建。

-  Matrix build 支持多版本测试。

-  Steps: code lint → unit test → build Docker image → push to ECR.

-  Use cache for dependencies to speed up builds.

-  Use matrix builds for multi-version testing.


----

**Q:** 你如何用 ArgoCD 做 CD？
 **Q:** How do you implement CD with ArgoCD?

**A:**

-  采用 GitOps 模式，ArgoCD 监控 Git 仓库的 Helm/manifest 改动，自动同步到集群。

-  好处：自动回滚、漂移检测、UI 可视化。

-  我也结合 Argo Rollouts 做 Canary 部署。

-  Use GitOps: ArgoCD watches Git repo for Helm/manifests changes, syncs to cluster automatically.

-  Benefits: rollback, drift detection, UI visibility.

-  Combined with Argo Rollouts for Canary deployments.


----

## 4. 监控与运维

**Q:** 你如何监控 CI/CD 流水线？
 **Q:** How do you monitor CI/CD pipelines?

**A:**
 我会用 GitHub Actions 的构建状态通知到 Slack，ArgoCD 的 sync 状态通过 Alertmanager 报警。Prometheus + Grafana 监控部署时的延迟和错误率。
 I send GitHub Actions build status to Slack, monitor ArgoCD sync status via Alertmanager. Prometheus + Grafana track latency and error rate during deployments.

----

**Q:** 你遇到过 Terraform 或 CI/CD 故障吗？怎么处理？
 **Q:** Have you faced Terraform or CI/CD failures? How did you handle them?

**A:**
 Terraform apply 出错时，我会先跑 `terraform plan` 找差异；CI/CD 失败时，先检查日志，看是测试失败还是配置错误，再决定回滚或修复。
 When Terraform apply fails, I first run `terraform plan` to check diffs; for CI/CD failures, I check logs to see if it’s test failure or config issue, then decide rollback or fix.

----

## 5. 行为题

**Q:** 遇到开发团队和 SRE 对方案有分歧，你会怎么做？
 **Q:** How would you handle conflicts between Dev and SRE teams?

**A:**
 先听取双方意见，把问题数据化，比如 SLO、性能指标、成本。用数据支撑讨论，找到折中方案，比如逐步灰度优化。
 I listen to both sides, translate issues into data like SLOs, performance metrics, or cost. Use data to guide discussion, and propose compromise, e.g., gradual canary rollout.

----

⚡ 建议：

-  技术题回答时用 **结构化思路 (What → How → Example)**。
-  行为题用 **STAR 法 (Situation, Task, Action, Result)**。
-  英文回答不求复杂，关键是 **清晰、简洁、自信**。
