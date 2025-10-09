# Observability Platform Selection Whitepaper (AWS / GCP, Azure, Alibaba Cloud / DeepFlow / Datadog / Other Commercial / Open Source Comparison)

- Version: 2025 Edition
- Author: Cloud Native Workshop (svc.plus)
- Goals

This whitepaper aims to provide decision guidance for selecting observability platforms in 2025. Objectives include:

- Unified telemetry: consolidate metrics, logs, traces and events across multi‑cloud and hybrid environments.
- Zero‑instrumentation & standardized ingestion: adopt eBPF and OpenTelemetry for auto topology discovery and reduced overhead.
- AI‑assisted root cause analysis: leverage AI and automation to detect anomalies, predict issues, and provide actionable insights[1].
- Cost & compliance management: optimize data retention via hot/warm/cold tiers and open formats to reduce storage costs[2].
- Visualization & alert integration: support unified dashboards via Grafana/Kibana and integrate with alerting tools.

# Table of contents:

1. Three‑layer architecture comparison
2. Draw.io hierarchical diagram
3. Pros & cons matrix
4. Selection decision tree
5. Typical deployment blueprints
6. Conclusions & recommendations
7. Future trends (2025–2027)

# Three‑Layer Architecture Comparison

Layering
Collection layer: application SDKs, OpenTelemetry, agents, eBPF probes, and native cloud exporters.
Pipeline layer: standardized collection & forwarding (OpenTelemetry Collector, vendor agents like CloudWatch Agent, OpsAgent, ARMS Collector, FluentBit, Kafka).
Analytics layer: observability platforms such as AWS CloudWatch+X‑Ray+OpenSearch, GCP Operations Suite, Azure Monitor+AppInsights+LogAnalytics, Alibaba Cloud ARMS+SLS+CloudMonitor, DeepFlow+Grafana+Prom/VM/Loki/Tempo, Datadog, open‑source Prom+Loki+Tempo, other commercial products (New Relic, Dynatrace, Grafana Cloud, Elastic Observability).

# Cross‑Platform Architecture Diagram (Mermaid)
flowchart TD
  subgraph Collection Layer
    A1[App SDK / OpenTelemetry]
    A2[eBPF Collector]
    A3[Cloud Native Exporter]
  end

  subgraph Pipeline Layer
    B1[OpenTelemetry Collector]
    B2[Vendor Agents (CloudWatch / OpsAgent / ARMS)]
    B3[Queue & Stream (FluentBit / Kafka)]
  end

  subgraph Analytics Layer
    C1[AWS CloudWatch + X-Ray + OpenSearch]
    C2[GCP Monitoring + Logging + Trace]
    C3[Azure Monitor + AppInsights + LogAnalytics]
    C4[Alibaba Cloud ARMS + SLS + CloudMonitor + Managed Prom/Grafana]
    C5[DeepFlow + Grafana + VM/Loki/Tempo]
    C6[Datadog SaaS]
    C7[Open Source (Prom + Loki + Tempo + Grafana)]
    C8[Other Commercial (New Relic / Dynatrace / Grafana Cloud / Elastic)]
  end

  A1 --> B1
  A2 --> B2
  A3 --> B1
  B1 --> C1 & C2 & C3 & C4 & C5 & C6 & C7 & C8
  B2 --> C1 & C3 & C4
  B3 --> C5 & C7

# Draw.io Hierarchical Diagram

The following text can be imported into draw.io via Arrange → Insert → Advanced → From Text:
Observability Platform Selection
├── Collection Layer
│   ├── SDK & OpenTelemetry
│   ├── Agents (CloudWatch Agent / OpsAgent / ARMS Agent)
│   ├── eBPF (DeepFlow / Pixie)
│   └── Exporters (Prometheus / Cloud Exporter)
├── Pipeline Layer
│   ├── OpenTelemetry Collector
│   ├── CloudWatch Agent / OpsAgent / ARMS Agent
│   ├── FluentBit / Kafka / PubSub / EventHub
│   └── DeepFlow Core
└── Analytics Layer
    ├── AWS CloudWatch + X-Ray + OpenSearch
    ├── GCP Operations Suite (Monitoring + Logging + Trace + BigQuery)
    ├── Azure Monitor + AppInsights + LogAnalytics
    ├── Alibaba Cloud ARMS + SLS + CloudMonitor + Managed Prom/Grafana
    ├── DeepFlow + Grafana + VM / Loki / Tempo
    ├── Datadog SaaS Observability
    ├── Other Commercial (New Relic / Dynatrace / Grafana Cloud / Elastic)
    └── Open Source (Prometheus + Loki + Tempo + Grafana)

# Pros & Cons Matrix

Platform	Positioning	Collection	Topology discovery	AI root cause	Deployment	Pricing Model	Suitable scenarios
AWS CloudWatch + X‑Ray + OpenSearch	Cloud‑native unified stack	Agent + SDK	ServiceLens auto	Yes (DevOps Guru)	Managed	Pay‑as‑you‑go	AWS‑centric systems
GCP Operations Suite	Deep GKE/GCE integration	OpsAgent + OTel	Visual service map	Yes (Cloud AIOps)	Managed	Project‑based	Data analytics focus
Azure Monitor + AppInsights + LogAnalytics	APM‑focused	Azure Agent + OTel	Automatic topology	Yes (Smart diagnostics)	Managed	Resource‑based	Microsoft ecosystem
Alibaba Cloud ARMS + SLS + CloudMonitor	Full‑stack observability for China	ARMS Agent + OTel	Global topology	Yes (Profiling & LLM alert correlation)	Managed or hybrid	Flow + node pricing	China compliance / rapid adoption
DeepFlow + Grafana + VM/Loki/Tempo	eBPF zero‑instrumentation	eBPF + OTel	L3–L7 topology	Yes (DeepFlow Insight)	Self‑hosted or hybrid	Node/flow based	Hybrid / private clouds
Datadog	Full‑stack SaaS	Agent + OTel	Auto service map	Yes (Watchdog AI)	SaaS	Host + data volume	Multi‑cloud SaaS companies
Other Commercial (New Relic / Dynatrace / Grafana Cloud / Elastic)	Commercial unified observability	Agent + SDK / OTel	Auto or manual	Yes (e.g., Dynatrace Davis)	SaaS / hybrid	Subscription	Medium to large enterprises
Open Source (Prom + Loki + Tempo + Grafana)	Cloud‑neutral & flexible	Exporter + OTel	Manual	No (need DIY AI)	Self‑hosted	Self‑managed	DevOps teams / cost‑sensitive

# Selection Decision Tree
graph TD
  A[Decision constraints] --> B1[Single cloud]
  A --> B2[Multi‑cloud or hybrid]
  A --> B3[China compliance]

  B1 --> C1[AWS‑centric: choose AWS CloudWatch + X‑Ray + OpenSearch]
  B2 --> D1[Is budget ample?]
  D1 -->|Yes| E1[SaaS commercial (Datadog / Dynatrace)]
  D1 -->|No| E2[Self‑hosted or semi‑managed (DeepFlow + Prom/Loki/Tempo)]
  B3 --> F1[Need rapid adoption?]
  F1 -->|Yes| G1[Alibaba Cloud ARMS + SLS + Managed Prom/Grafana]
  F1 -->|No| G2[Zero‑instrumentation self‑hosting (DeepFlow + OTel Collector + local storage)]

# Typical Deployment Blueprints

## AWS Native Solution

Collection: CloudWatch Agent / AWS Distro for OpenTelemetry SDK.
Logs: CloudWatch Logs → OpenSearch for search & Kibana dashboards.
Metrics: CloudWatch Metrics → CloudWatch Dashboards or Managed Grafana.
Traces: X‑Ray → ServiceLens ties metrics & logs.
Visualization: CloudWatch Dashboards / Managed Grafana.
Strengths: Out‑of‑the‑box integration; deep AWS service hooks.
Caveats: Cross‑region/account aggregation is complex; costs can be high.

## GCP Solution

Collection: Ops Agent / OpenTelemetry.
Logs: Cloud Logging → can export to BigQuery for SQL analytics[3].
Metrics: Cloud Monitoring; built‑in SLO/SLI.
Traces: Cloud Trace / Profiler.
Visualization: Console, Managed Grafana, or Looker Studio.
Azure Solution

Collection: Azure Monitor Agent / OTel.
Logs: Log Analytics with powerful KQL.
Metrics: Azure Monitor Metrics.
Traces/APM: Application Insights.
Visualization: Azure Dashboards / Power BI / Managed Grafana.

## Alibaba Cloud Native Solution
Collection: ARMS Agent + OpenTelemetry SDK.
Logs: Log Service (SLS) with real‑time search, pipeline processing, and data delivery.
Metrics: CloudMonitor + Managed Prometheus.
Traces: ARMS distributed tracing, compatible with OTel.
Visualization: Managed Grafana or SLS dashboards; data can be delivered to OSS for tiered storage.

## DeepFlow Hybrid Solution

Collection: DeepFlow eBPF Collector + OpenTelemetry Collector.
Metrics: Export to VictoriaMetrics / Prometheus.
Logs: Logtail → Loki; supports auto‑parsing of flow logs and application logs.
Traces: Tempo / Jaeger; DeepFlow auto‑generates spans.
Visualization: Grafana + DeepFlow Insight; unified topology across clouds and private clusters.
Strengths: Zero‑instrumentation, L3–L7 topology, AI root cause analysis.

## Datadog SaaS Solution

Collection: Datadog Agent + OpenTelemetry.
Telemetry: Metrics, logs, and traces feed into Datadog SaaS; 600+ integrations.
Visualization: Built‑in dashboards & notebooks; automatic service map.
Strengths: Fully managed, intelligent Watchdog AI.
Weaknesses: High cost; data residency considerations.

## Open Source Self‑Hosted

Collection: OpenTelemetry Collector + exporters.
Metrics: Prometheus or VictoriaMetrics.
Logs: Loki, with FluentBit for ingestion.
Traces: Tempo or Jaeger.
Visualization: Grafana; alerting via Alertmanager.
Strengths: Flexible, cloud‑neutral, cost‑controlled.
Drawbacks: Requires operational effort; no built‑in AI.

# Conclusions & Recommendations

Organization type	Recommended platform	Rationale
AWS‑centric startups/SMBs	AWS CloudWatch + X‑Ray + OpenSearch	High integration, rapid setup, minimal operations.
Multi‑cloud / hybrid enterprises	DeepFlow + Grafana + Prom/Loki/Tempo	eBPF zero‑instrumentation, automatic topology across clouds, unified OTel ingestion.
SaaS companies with ample budget	Datadog / Dynatrace	Fully managed AIOps with rich ecosystem.
China‑focused or compliance‑driven	Alibaba Cloud ARMS + SLS + Managed Prom/Grafana	Local compliance, mature engineering, LLM‑powered alert correlation.
Data analytics‑oriented or GKE‑centric	GCP Operations Suite + BigQuery	Supports direct SQL analysis of logs/telemetry[3].
Microsoft ecosystem / APM emphasis	Azure Monitor + AppInsights + LogAnalytics	Strong KQL and out‑of‑the‑box APM.
Cost‑sensitive with ops capacity	Open Source (Prom + Loki + Tempo + OTel + Grafana)	Fully customizable, multi‑cloud unified, cost‑controlled.

# Future Trends (2025–2027)

OpenTelemetry becomes de facto: by 2025 OTel reached critical mass; stable language SDKs and auto‑instrumentation allow instrument once, export anywhere[4].
Open formats break data silos: adoption of Iceberg/Parquet enables direct SQL queries and vendor‑agnostic data retention[3].
Edge & IoT observability: edge computing and IoT drive observability closer to devices, capturing real user experience and reducing bandwidth[5].
AI transforms observability: AI predicts future issues, optimizes data retention, and offers natural language query interfaces[1]. AWS AgentCore Observability integrates CloudWatch to monitor AI agent actions[6].
Continuous profiling as the fourth pillar: OpenTelemetry introduces continuous profiling, adding CPU and memory hotspots to metrics/logs/traces[7].
eBPF adoption: eBPF becomes mainstream, providing deep visibility into network flows and system calls without code changes[8].
Open data architecture & cost optimization: hybrid storage architectures combine hot TSDB, warm columnar object storage, and cold compressed archives[2].
Security & compliance: observability platforms integrate security analytics and compliance reporting.
Generative AI & agent observability: as AI agents proliferate, platforms will offer dedicated monitoring, vector storage support, and agent behaviour visualization to track model accuracy and resource usage.

This whitepaper offers comprehensive comparisons and guidance for teams to make informed decisions, design architectures, and prepare reports.

[1] [2] [3] [4] [5] [7] [8] Observability trends in 2025 | InfluxData
https://www.influxdata.com/glossary/observability-trends-2025/
[6] AWS launches agentic AI tools and major cloud service upgrades
https://www.aboutamazon.com/news/aws/aws-summit-agentic-ai-innovations-2025

