# 2. 设计目标与架构原则 (Design Goals and Architectural Principles)

## 2.1 多云环境管理 (Multi-Cloud Management)

AWS vs 阿里云 Landing Zone 对比


# Landing Zone 落地形态对比（AWS 国际 / AWS 中国 / 阿里云）

| 功能域       | AWS 国际                                | AWS 中国（北京/宁夏区域）                        | 阿里云                                   |
| ------------ | --------------------------------------- | ------------------------------------------------ | ---------------------------------------- |
| 多账号组织   | AWS Organizations + Control Tower       | Organizations（受限）<br>Control Tower 尚未落地  | 资源目录 (Resource Directory)             |
| **多账号治理**   | AWS Organizations + Account Factory     | AWS Organizations，功能不完整                    | Resource Directory（资源目录，多账号层级） |
| 身份管理     | IAM + AWS SSO                           | IAM（部分功能受限）<br>SSO 未完全提供            | RAM + 访问控制                            |
| 审计日志     | CloudTrail                              | CloudTrail（部分事件缺失）                       | ActionTrail                               |
| 合规检测     | Config + Security Hub                   | Config（功能缩减）<br>Security Hub 未落地        | Config + 云安全中心                       |
| 网络基线     | VPC、Transit Gateway、PrivateLink       | VPC（支持）<br>部分服务如 TGW/PrivateLink 受限   | VPC、专有网络、云企业网 (CEN)             |
| IaC          | CloudFormation / Terraform              | CloudFormation（区域落地较慢）<br>Terraform 支持 | ROS / Terraform                           |
| 成本管理     | AWS Budgets / Cost Explorer             | 成本管理（功能有限，部分未开放）                 | 费用中心 / 成本管控                       |
| 自动化落地   | AWS Control Tower（按钮式启用）         | 无 Control Tower，只能手工基建/脚本化            | 解决方案模板（需执行 ROS/Terraform）      |
| **合规侧重点**   | 全球合规（CIS、ISO、HIPAA、FedRAMP 等） | 中国可用功能有限，部分合规需手动实现             | 中国本地合规（等保 2.0、金融、政企规范）  |
| **适用人群**     | 跨国企业、云原生团队                    | 在华跨国企业（需接受功能残缺）                   | 中国本地企业（金融、能源、政企客户）      |

- **AWS 国际** → 最成熟，Control Tower = 企业级自动化
- **AWS 中国** → 功能缩水版，没有 Control Tower，要靠自己拼装
- **阿里云** → 模板化解决方案，更贴合中国本地合规，但没有一键托管服务

# Landing Zone 最小化清单对比（AWS 国际 / AWS 中国 / 阿里云 + 个人场景建议）

| 功能域        | AWS 国际  | AWS 中国 | 阿里云 | 个人/学习场景最小化建议 |
|--------       |-----------|-----------|---------|-------------------------|
| **身份与访问控制** | - Root 开启 MFA  <br> - IAM 用户 + 组（Admin/DevOps）<br> - Access Key 管理 CLI/SDK | - 同 AWS 国际 <br> - SSO / Directory 功能受限 | - 主账号开启 MFA <br> - RAM 用户（管理员/运维）<br> - AK/SK 管理 | **必做**：主账号开 MFA + 创建子用户操作。学习环境只需 1 管理员 + 1 运维用户。 |
| **日志与审计** | - CloudTrail 开启 → S3 + CloudWatch Logs | - CloudTrail 可用但区域覆盖有限 | - ActionTrail → OSS + SLS <br> - OSS Bucket 日志 | **最小化**：开启 CloudTrail/ActionTrail，保存到对象存储（S3/OSS）即可。学习用不用长期保存。 |
| **安全与合规** | - Config 基础规则 <br> - Security Hub <br> - GuardDuty（可选付费） | - Config 可用 <br> - Security Hub、GuardDuty 受限 | - Config（基础规则） <br> - 云安全中心（免费版） | **建议**：只开 Config 基础规则（禁止 0.0.0.0:22），安全中心/GuardDuty 免费版够用，学习不用买付费版。 |
| **网络基线** | - VPC + 子网（Prod/Test） <br> - NAT Gateway <br> - 禁用默认安全组全放行 | - 同 AWS 国际，部分网络服务缺 | - VPC + 子网（生产/测试隔离） <br> - NAT 网关/弹性公网 IP | **精简**：只建 1 个 VPC + 2 个子网（Prod/Test），安全组按需放行。NAT 网关学习环境可省（用直连公网 IP）。 |
| **资源与成本控制** | - Tags（Env=Dev/Prod, Owner=User）<br> - Budgets + Cost Explorer | - Tags 可用 <br> - Budgets 支持有限 | - 标签管理（Env, Owner）<br> - 费用中心预算 + 告警 | **必须**：加标签方便清理资源。预算告警可选（个人小规模不一定超额）。 |
| **自动化与 IaC** | - CloudFormation / Terraform 模板 | - Terraform 可用 <br> - CloudFormation 部分受限 | - ROS / Terraform 模板 | **推荐**：写一个最小化 Terraform/ROS 模板（VPC + 用户 + 审计），以后建环境一键复用。 |

---

## 📋 个人/学习版「一步到位清单」

- **身份安全**：开 MFA，创建 1 个管理员 + 1 个运维用户。
- **操作留痕**：开启 CloudTrail/ActionTrail，日志存 S3/OSS 即可。
- **安全基线**：开 Config 基础规则，安全中心/GuardDuty 免费版即可。
- **网络隔离**：建 1 个 VPC，2 个子网（Prod/Test），安全组按需放行。
- **费用管控**：用标签区分环境，预算告警可选。
- **自动化**：准备一个 Terraform/ROS 脚本，快速复用最小化环境。


## 2.2 环境隔离与安全控制 (Environment Isolation and Security Control)
TODO: Add content

## 2.3 跨云平台身份认证与统一角色管理 (Cross-Cloud Identity and Role Management)

## 2.4 自动化与合规性 (Automation and Compliance)
TODO: Add content

## 2.5 灵活性与扩展性 (Flexibility and Scalability)
TODO: Add content

## 2.6 简化操作与资源管理 (Simplification of Operations and Resource Management)
TODO: Add content
