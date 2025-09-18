# Observability

Overview for observability practices and tools.


APM vs NPM 一览对比（Fennel 风格）
产品/厂商	类型定位	APM 能力（应用可观测）	NPM 能力（网络可观测）	特点 / 差异
乘云数字 DataBuff	综合型	有（应用链路追踪、AI 异常检测、TraceX 全量存储）	有（基础网络依赖、调用拓扑）	中国厂商，强调低成本存储 + AI 驱动（OpsGPT），合规/信创友好
DeepFlow	NPM 起家	有一定（结合 eBPF 做调用链采集）	强（eBPF + 流日志/指标/pcap，网络流量可观测）	中国厂商，突出 无侵入、流量级全栈观测
科莱 Colasoft	NPM 为主	弱（非主打 APM）	强（抓包、流量分析、取证）	偏传统网络分析，主场景在 网络安全、取证
Dynatrace	APM 为主	强（OneAgent 自动拓扑、根因分析、Grail 数据湖）	中（基础网络依赖、扩展集成）	国际老牌，全栈自动化强，成本偏高
Datadog	综合型	强（APM、分布式 Trace、RUM、Profiler）	中/强（USM 基于 eBPF，网络依赖发现）	模块多，生态最广，计费灵活但易滚雪球
New Relic	APM 为主	强（全栈 APM、100GB/月 免费层、OTel 支持）	中（部分网络依赖，可结合第三方）	入门门槛低，适合中小团队，计费按数据量+用户
Apache SkyWalking	APM 为主	强（开源 APM、Trace、Metrics、Logs）	中（Rover eBPF Profiling，有限网络指标）	开源免费，需自建存储，适合二次开发/国产替代
🌿 总结（Fennel 风格）

APM 主打：Dynatrace、Datadog、New Relic、SkyWalking

NPM 主打：DeepFlow、科莱 Colasoft

综合平衡：乘云数字 DataBuff（APM + NPM 都兼顾，强调国产化与低成本）

👉 一句话对比：

国际派：Dynatrace 全栈自动化，Datadog 模块灵活，New Relic 性价比，SkyWalking 开源可控。

国内派：DataBuff AI 驱动观测，DeepFlow 流量级全栈，科莱侧重网络取证。




开源可观测性/监控工具在 APM 与 NPM 维度上的代表：

🔎 开源 APM 方向

（关注应用性能、调用链、Trace、日志、指标）

OpenTelemetry (OTel)

CNCF 毕业项目，统一采集标准（metrics/logs/traces），本身不做存储与 UI，常配合后端（Tempo、Jaeger、Grafana、SkyWalking 等）。

相当于“观测数据的采集层标准件”。

Apache SkyWalking

开源全栈 APM，Trace/Metrics/Logs 一体化，UI 完备。

支持 eBPF Profiling（Rover），国产化落地较多。

Jaeger

CNCF 项目，专注分布式追踪。

常和 OTel Collector 配合，用于 Trace 存储/查询。

Pinpoint（韩国 NAVER 开源）

面向 Java 系生态的 APM，早期流行，特长是大规模调用链可视化。

Zabbix APM 插件 / Elastic APM

Zabbix 有扩展能力，但偏传统监控。

Elastic APM（ELK 家族）能做应用调用链 + 日志/指标统一。

🔎 开源 NPM 方向

（关注网络性能、流量、可视化、抓包）

DeepFlow

国内开源，eBPF 驱动，全栈观测，强调“零侵入”。

科来（Colasoft）社区版

传统抓包/网络分析。

Cilium / Hubble

基于 eBPF 的容器网络与可观测性，Hubble 提供服务依赖、流量拓扑可视化。

ntop / ntopng

网络流量可视化与性能监控。

Wireshark

经典网络抓包工具，更多是诊断用，不是平台。

🔎 Grafana Labs 家族（APM + NPM 融合）

Grafana Tempo：分布式追踪后端（和 OTel 配合）。

Grafana Loki：日志聚合。

Grafana Mimir / Cortex：指标存储。

Grafana Agent / Alloy：轻量化采集。
👉 Grafana Labs 其实把 OTel 的采集层和自家存储/UI 结合，构成一个“观测平台拼装套件”。

🔎 Rancher 鹰眼（Eyes）

SUSE Rancher 的可观测性方案（有叫 Rancher Eyes 或 Neuvector Observability）。

聚合 Prometheus / Loki / Tempo / OTel Collector，面向多集群管理。

定位更像是 集成套件，不是自研内核。

🔎 还有哪些值得关注

SigNoz

开源 APM，基于 OTel，界面类似 Datadog/New Relic。

自带存储/查询，开发者友好。

OpenObserve (Opni)

统一日志/指标/Trace，号称“Elastic 替代品”。

Lightstep (已被 ServiceNow 收购，核心是 OTel)

曾经的 OTel 强推者，部分功能开源。

Pixie (CNCF Sandbox，New Relic 捐赠)

eBPF 驱动的 Kubernetes 可观测平台，强调无侵入。

🌿 总结（APM vs NPM）

APM 主打：SkyWalking、Jaeger、Pinpoint、Elastic APM、SigNoz、OTel（采集标准）、Grafana Tempo

NPM 主打：DeepFlow、Cilium/Hubble、ntopng、Wireshark、Colasoft

综合/平台化：Grafana Stack（Tempo+Loki+Mimir）、Rancher Eyes
