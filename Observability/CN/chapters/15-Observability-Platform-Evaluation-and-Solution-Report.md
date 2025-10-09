# 可观测性平台选型白皮书（AWS / GCP、Azure、阿里云 / DeepFlow / Datadog / 其他商业 / 开源对比）

版本：2025 年版
作者：云原生工坊（svc.plus）

# 总体目标

本白皮书旨在为企业在 2025 年选择可观测性平台提供决策依据。目标包括：
- 统一指标、日志、追踪和事件数据，适应多云和混合环境。
- 零侵入采集与标准化采集：支持 eBPF 与 OpenTelemetry，实现自动拓扑发现并减少数据采集开销。
- 智能根因分析：结合 AI 与自动化，提高告警准确性并快速定位故障原因[1]。
- 成本与合规治理：通过热冷分层存储和开放格式优化存储成本[2]。
- 可视化与告警联动：支持 Grafana、Kibana 等统一大屏，并与消息系统或 PagerDuty 集成。
目录包括：
1. 三层架构对比
2. Draw.io 层级结构图
3. 优缺点矩阵
4. 选型决策树
5. 典型落地蓝图
6. 结论与推荐路径
7. 未来趋势（2025–2027）

# 三层架构对比

架构分层
采集层：应用 SDK、OpenTelemetry SDK、Agent、eBPF 探针、云厂商原生导出器等。
数据管道层：标准化采集和转发，如 OpenTelemetry Collector、云厂商代理（CloudWatch Agent、OpsAgent、ARMS 采集器）、FluentBit、Kafka 等。
分析平台层：各类可观测性平台，包括 AWS CloudWatch+X‑Ray+OpenSearch、GCP Operations Suite、Azure Monitor+AppInsights+LogAnalytics、阿里云 ARMS+SLS+云监控、DeepFlow+Grafana+Prom/VM/Loki/Tempo、Datadog、开源 Prom+Loki+Tempo、其他商业（New Relic、Dynatrace、Grafana Cloud、Elastic Observability）等。

# 跨平台架构图 (Mermaid)

flowchart TD
  subgraph 数据采集层
    A1[应用 SDK / OpenTelemetry]
    A2[eBPF Collector]
    A3[云原生 Exporter]
  end

  subgraph 数据管道层
    B1[OpenTelemetry Collector]
    B2[云厂商代理 (CloudWatch Agent / OpsAgent / ARMS Agent)]
    B3[消息队列 (FluentBit / Kafka)]
  end

  subgraph 分析平台层
    C1[AWS CloudWatch + X-Ray + OpenSearch]
    C2[GCP Cloud Monitoring + Logging + Trace]
    C3[Azure Monitor + AppInsights + LogAnalytics]
    C4[阿里云 ARMS + SLS + 云监控 + 托管 Prom/Grafana]
    C5[DeepFlow + Grafana + VM/Loki/Tempo]
    C6[Datadog SaaS]
    C7[开源栈 (Prom + Loki + Tempo + Grafana)]
    C8[其他商业 (New Relic / Dynatrace / Grafana Cloud / Elastic)]
  end

  A1 --> B1
  A2 --> B2
  A3 --> B1
  B1 --> C1 & C2 & C3 & C4 & C5 & C6 & C7 & C8
  B2 --> C1 & C3 & C4
  B3 --> C5 & C7
Draw.io 层级结构图
以下文本可直接导入 draw.io（Arrange → Insert → Advanced → From Text）生成图形：

# 可观测性平台选型
├── 数据采集层
│   ├── SDK & OpenTelemetry
│   ├── Agent（CloudWatch Agent / OpsAgent / ARMS Agent）
│   ├── eBPF（DeepFlow / Pixie）
│   └── Exporter（Prometheus / Cloud Exporter）
├── 数据管道层
│   ├── OpenTelemetry Collector
│   ├── CloudWatch Agent / OpsAgent / ARMS Agent
│   ├── FluentBit / Kafka / PubSub / EventHub
│   └── DeepFlow Core
└── 数据分析层
    ├── AWS CloudWatch + X-Ray + OpenSearch
    ├── GCP Operations Suite (Monitoring + Logging + Trace + BigQuery)
    ├── Azure Monitor + AppInsights + LogAnalytics
    ├── 阿里云 ARMS + SLS + 云监控 + 托管 Prom/Grafana
    ├── DeepFlow + Grafana + VM / Loki / Tempo
    ├── Datadog SaaS Observability
    ├── 其他商业 (New Relic / Dynatrace / Grafana Cloud / Elastic)
    └── 开源栈 (Prometheus + Loki + Tempo + Grafana)

# 优缺点矩阵

平台 / 特性	定位	采集方式	拓扑发现	AI 根因	部署模式	成本模式	适用场景
AWS CloudWatch + X‑Ray + OpenSearch	云原生一体化	Agent + SDK	ServiceLens 自动	有 (DevOps Guru)	托管	按量计费	AWS 专属系统
GCP Operations Suite	GKE/GCE 深度结合	OpsAgent + OTel	Cloud Trace 可视化	有 (Cloud AIOps)	托管	按项目计费	数据分析驱动
Azure Monitor + AppInsights + LogAnalytics	应用性能监控(APM)	Azure Agent + OTel	自动拓扑	有 (智能诊断)	托管	按资源计费	微软生态用户
阿里云 ARMS + SLS + 云监控	国内全栈观测	ARMS Agent + OTel	全局拓扑	有 (持续剖析、LLM 告警收敛)	托管或混合	按流量 + 节点计费	中国区 / 合规要求
DeepFlow + Grafana + VM/Loki/Tempo	eBPF 零侵入	eBPF + OTel	L3–L7 拓扑	有 (DeepFlow Insight)	自建或混合	按节点/流量	混合云 / 私有化
Datadog	全栈 SaaS 观测平台	Agent + OTel	自动 Service Map	有 (Watchdog AI)	SaaS	按 Host + 数据量	多云 SaaS 企业
其他商业 (New Relic / Dynatrace / Grafana Cloud / Elastic)	商用统一观测	Agent + SDK / OTel	自动或手动	有（如 Dynatrace Davis）	SaaS / 混合	按订阅计费	大中型企业
开源 (Prom + Loki + Tempo + Grafana)	云中立、自建灵活	Exporter + OTel	手动配置	无（需自建 AIOps）	自建	自主控制	DevOps 团队 / 成本敏感

# 选型决策树
graph TD
  A[选择约束] --> B1[单云]
  A --> B2[多云或混合]
  A --> B3[国内合规]

  B1 --> C1[AWS 内/单云：选 AWS CloudWatch + X‑Ray + OpenSearch]
  B2 --> D1[预算充足?]
  D1 -->|是| E1[SaaS 商用 (Datadog / Dynatrace)]
  D1 -->|否| E2[自建或半托管 (DeepFlow + Prom/Loki/Tempo)]
  B3 --> F1[快速上线?]
  F1 -->|是| G1[阿里云 ARMS + SLS + 托管 Prom/Grafana]
  F1 -->|否| G2[自建零侵入 (DeepFlow + OTel Collector + 本地存储)]

# 典型落地蓝图

## AWS 原生方案

采集层：CloudWatch Agent / AWS Distro for OpenTelemetry SDK。
日志：CloudWatch Logs → OpenSearch 搜索与 Kibana 展示。
指标：CloudWatch Metrics → CloudWatch Dashboard 或 Managed Grafana。
追踪：X‑Ray → ServiceLens 关联 Metrics & Logs。
可视化：CloudWatch Dashboard / Managed Grafana。
优势：开箱即用；AWS 服务深度集成。
注意：跨 Region/账号聚合复杂；成本较高。

## GCP 方案

采集层：Ops Agent / OpenTelemetry。
日志：Cloud Logging → 可导出到 BigQuery 做 SQL 分析[3]。
指标：Cloud Monitoring；支持 SLI/SLO。
追踪：Cloud Trace / Profiler。
可视化：Console 与 Managed Grafana；可用 Looker Studio。

## Azure 方案

采集层：Azure Monitor Agent / OTel。
日志：Log Analytics 使用强大的 KQL 查询。
指标：Azure Monitor Metrics。
追踪：Application Insights 自动化 APM。
可视化：Azure Dashboard / PowerBI / Managed Grafana。

## 阿里云原生方案

采集层：ARMS Agent + OpenTelemetry SDK。
日志：日志服务 SLS 支持实时查询、管道加工与投递。
指标：云监控 + 托管 Prometheus。
追踪：ARMS 分布式追踪，可与 OTel 打通。
可视化：托管 Grafana 或 SLS 大屏；数据可投递至 OSS 实现热冷分层。

## DeepFlow 混合方案

采集层：DeepFlow eBPF Collector + OpenTelemetry Collector。
指标：上报至 DeepFlow  Server/CickHouse
日志：Logtail → Loki；支持流量日志和应用日志自动解析。
追踪：Tempo / Jaeger；DeepFlow 自动生成 Span。
可视化：Grafana + DeepFlow Insight；支持跨云和私有集群统一拓扑。
优势：零侵入采集、L3–L7 自动拓扑

## Datadog SaaS 方案

采集层：Datadog Agent + OpenTelemetry。
指标/日志/追踪：统一进入 Datadog SaaS；支持 600+ 集成。
可视化：自带 Dashboard & Notebook；自动 Service Map。
优势：全托管、智能 Watchdog AI。
劣势：成本高、数据出境需注意。

## 开源自建方案

采集层：OpenTelemetry Collector + Exporters。
指标：Prometheus 或 VictoriaMetrics。
日志：Loki；可结合 FluentBit 采集。
追踪：Tempo 或 Jaeger。
可视化：Grafana；告警用 Alertmanager。
优势：灵活云中立，成本可控。
劣势：运维复杂，需要自建 AI 分析。

## 结论与推荐路径
组织类型	推荐方案	理由
AWS 为主的初创或中小团队	AWS CloudWatch + X‑Ray + OpenSearch	集成度高，快速部署，无需额外运维。
多云/混合云企业	DeepFlow + Grafana + Prom/Loki/Tempo	eBPF 零侵入，跨云拓扑自动发现，支持 OTel 统一采集。
SaaS 公司且预算充足	Datadog / Dynatrace	全托管智能 AIOps，集成生态丰富。
中国区合规且快速上线	阿里云 ARMS + SLS + 托管 Prom/Grafana	本地合规，工程化成熟，支持 LLM 告警与自动剖析。
数据分析导向或 GKE 重点	GCP Operations Suite + BigQuery	支持直接用 SQL 分析日志和监控数据[3]。
微软生态深、APM 强调	Azure Monitor + AppInsights + LogAnalytics	KQL 强大，AppInsights 自动 APM。
成本敏感、具备运维能力	开源栈 (Prom + Loki + Tempo + OTel + Grafana)	自建灵活，可多云统一，成本可控。

## 未来趋势（2025–2027）

penTelemetry 成为事实标准：2025 年 OpenTelemetry 已从早期采纳走向主流，语言 SDK 与自动插桩成熟[4]。企业通过一次接入多端输出，避免供应商锁定。
开放格式打破数据孤岛：Apache Iceberg/Parquet 等开放格式在可观测性中被广泛采用，支持直接 SQL 查询和多平台迁移[3]。
边缘与 IoT 观测：随着边缘计算与 IoT 爆发，观测从数据中心延伸到边缘设备，捕获真实用户体验并降低带宽消耗[5]。
AI 驱动全栈可观测：AI 不仅用于检测异常，更能预测未来问题、优化数据留存、通过自然语言查询生成仪表盘[1]。AWS 等厂商推出 AgentCore Observability，实现代理行为的实时跟踪[6]。
持续剖析成为第四支柱：OpenTelemetry 引入 Continuous Profiling，提供 CPU 和内存热点分析，成为继指标、日志、追踪之后的新支柱[7]。
eBPF 普及：eBPF 在 Linux 内核中的广泛应用提供细粒度网络流量和系统调用观测，2025 年已达到关键采用点[8]。
开放数据架构与成本优化：混合存储架构结合热 (高性能 TSDB)、温 (列存对象) 和冷 (压缩归档) 层，实现长期保留与成本优化[2]。
安全集成与合规治理：可观测性平台强化安全监测，结合异常流量检测与合规报告，帮助客户满足全球隐私法规。
生成式 AI 与代理观测：随着生成式 AI 与 AI 代理的普及，平台将提供专用的模型监测、向量存储支持和代理行为可视化，使系统能够追踪模型准确度和资源利用。

该白皮书提供了全面的对比与建议，可用于团队决策、技术选型及汇报展示。

[1] [2] [3] [4] [5] [7] [8] Observability trends in 2025 | InfluxData
https://www.influxdata.com/glossary/observability-trends-2025/
[6] AWS launches agentic AI tools and major cloud service upgrades
https://www.aboutamazon.com/news/aws/aws-summit-agentic-ai-innovations-2025
