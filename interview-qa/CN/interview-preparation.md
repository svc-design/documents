
面试准备篇：DevOps / SRE / 运维岗位指南
🔑 关键词及定义对比
1. 运维 (Ops / Operation Engineer)

定位：传统角色，负责系统安装、配置、巡检、上线。

技能侧重：Linux、网络、数据库、中间件、Shell。

企业印象：执行型，保障稳定，人力驱动。

典型企业：传统制造业、外包公司、中小 IT 服务商。

2. 运维开发 (Ops Developer / Automation Ops Engineer)

定位：运维升级版，能写脚本/工具实现自动化。

技能侧重：Python/Golang、Ansible、Jenkins、API 调用。

企业印象：JD 中常代替 DevOps，强调“能写代码的运维”。

典型企业：金融、电商、二线互联网公司。

3. DevOps (DevOps Engineer)

定位：CI/CD、自动化交付、环境标准化，衔接开发与运维。

技能侧重：Jenkins/GitLab CI、Docker、K8s、Helm、ArgoCD、Terraform。

企业印象：

大厂：接近平台工程，偏流水线与工程效率。

中小厂：运维开发的“高配版”。

典型企业：互联网大厂、中大型 SaaS/云原生公司。

4. SRE (Site Reliability Engineer)

定位：Google 提出的可靠性工程，中国大厂广泛采纳。

职责：

系统可靠性（SLA/SLO/SI）

高可用架构、故障演练

分布式系统大规模运维

自研运维工具

技能侧重：Go/Python、K8s/Service Mesh、监控链路、可观测性、混沌工程。

企业印象：比 DevOps 高阶，强调工程思维和可靠性。

典型企业：阿里、字节、美团、腾讯。

5. 平台工程师 (Platform Engineer)

定位：近几年大厂流行，开发与维护 CI/CD + 容器云平台。

区别：

与 DevOps：更“产品化”，做统一研发平台。

与 SRE：专注工具/平台建设，不直接背 SLA。

技能侧重：K8s Operator、GitOps、云原生栈（Prometheus/Grafana/Argo）、IaC（Terraform/Pulumi）。

企业印象：DevOps 的进化版，多叫“平台部 / 工程效率部”。

典型企业：字节（PaaS）、美团（平台部）、新兴创业公司。

📊 对比总结表
关键词	英文名	定位角色	技能侧重	企业常见定义/印象
运维	Operation Engineer	传统保障型	Linux、网络、DB、Shell	保证服务稳定，执行型岗位
运维开发	Ops Developer / Automation Ops	自动化型	Python/Golang、Ansible、CI/CD	“能写代码的运维”，半自动化
DevOps	DevOps Engineer	CI/CD + 发布	Jenkins/GitLab CI、K8s、Helm	大厂是平台工程，小厂是运维开发
SRE	Site Reliability Engineer	可靠性工程	Go/Python、分布式、可观测性	高阶岗位，强调 SLA/SLO/自动化
平台工程师	Platform Engineer	平台产品化	K8s Operator、GitOps、IaC	DevOps 进化版，做研发中台
