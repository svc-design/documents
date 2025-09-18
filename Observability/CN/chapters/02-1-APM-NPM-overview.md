
# 概述

- **APM（Application Performance Monitoring）**：聚焦应用层性能与稳定性（调用链、错误率、数据库/外部依赖耗时、CPU/内存剖析等）。
- **NPM（Network Performance Monitoring）**：聚焦网络与流量（L3–L7 时延、丢包、吞吐、拓扑依赖、抓包/取证）。
- **eBPF 的地位**：作为**内核侧“零侵入”采集基座**，贯通 NPM 与 APM 数据面；K8s 场景中与 **OpenTelemetry（OTel）** 形成“**eBPF + OTel**”双轨标准。

# APM / NPM 一览

![请在此添加图片描述](https://developer.qcloudimg.com/http-save/yehe-2810186/29fc2b469c527388d566f2f0db1ba754.png?qc_blockWidth=769&qc_blockHeight=769)

**象限定位（X=APM 强度，Y=NPM 强度）**

- 右上：**Datadog、Dynatrace**；**DeepFlow**更靠上（网络更强）；“**Grafana Stack + Cilium/Hubble**”组合接近右上
- 右下：**New Relic、SkyWalking、SigNoz**
- 左上：**Colasoft、Cilium+Hubble、Pixie**（**DeepFlow**亦可视为偏此）
- 中间偏右：**DataBuff**
- 标准件：**OTel**（采集层，属于标准，不列入）

| 产品/厂商 | 类型定位 | APM 能力（应用） | NPM 能力（网络） | 亮点 / 差异 |
|:----|:----|:----|:----|:----|
| 乘云数字 DataBuff | 综合型 | 有（链路追踪、AI 辅助） | 有（依赖/拓扑） | 国产化与行业落地（成本/合规友好） |
| DeepFlow | NPM 起家 | 有一定（eBPF 侧采集） | 强（eBPF+流量/拓扑/pcap） | 零侵入、流量级全栈关联 |
| 科莱 Colasoft | NPM 为主 | 弱 | 强（抓包、协议解析、取证） | 传统网络与取证场景 |
| Dynatrace | APM 为主 | 强（OneAgent、因果分析、数据湖仓） | 中（网络依赖/集成） | 自动化一体化强，企业级 |
| Datadog | 综合型 | 强（APM/Trace/RUM/Profiler） | 中–强（USM/eBPF） | 模块丰富、生态广 |
| New Relic | APM 为主 | 强（全栈 APM） | 中 | 免费层友好、易上手 |
| Apache SkyWalking | APM 为主 | 强（Trace/Metrics/Logs） | 中（Rover eBPF Profiling） | 开源可控，国产替代佳 |
| OpenTelemetry（OTel） | 采集标准 | N/A（SDK/Collector） | N/A | 统一三信号采集；需搭配后端 |
| Grafana Labs（LGTM+Pyroscope） | 平台拼装 | Tempo=Trace（Grafana UI） | Loki/Mimir 为主（可联动 Cilium/Hubble） | 自建成本友好、组件化灵活 |
| Rancher（Monitoring 组合） | 多集群集成 | 接 OTel/Tempo/Prometheus | 接 Prom/Loki（非专职 NPM） | 多集群可观测与运维整合 |
| SigNoz（开源） | APM 为主 | 强（OTel 原生） | 中（应用侧为主） | “开源 Datadog 替代”路线 |
| Cilium + Hubble（开源） | NPM 为主 | 弱 | 强（L3–L7 拓扑/依赖） | K8s eBPF 网络观测标配 |
| Pixie（开源） | NPM/运行时 | 中（运行时剖析） | 强（eBPF 自动采集） | 零代码采集，研发/调试友好 |


# 国内（代表性做法）

- **eBPF 无侵入 + 全栈观测**
中国移动 PaaS、腾讯等在生产使用 **DeepFlow** 做“零侵入”链路与网络观测，覆盖多语言与复杂平台；典型做法是用 eBPF 统一拿到网络与调用数据，再与既有监控/Trace 系统打通。 [DeepFlow](https://deepflow.io/docs/about/users/?utm_source=chatgpt.com)
- **云厂商自研平台 + OTel 生态**
阿里云 **ARMS** 提供端到端 APM/前端/后端诊断，并给出采样、Thread Profiling、日志与 Trace 关联等最佳实践；企业侧常把 ARMS 与 OTel/Prometheus 结合，用于混合场景。 [阿里云](https://www.alibabacloud.com/help/en/arms/arms-practice-tutorial?utm_source=chatgpt.com)
- **大规模场景的融合观测**
金融/运营商把\*\*网络流量可观测（NPM）+ 调用链（APM）\*\*合并做根因定位：如银行/运营商案例用 vTap/流量侧数据＋指标/Trace 组合，强化对“网络或应用谁更慢”的判定。 （公开案例汇总页面可见行业分布） [DeepFlow](https://deepflow.io/docs/about/users/?utm_source=chatgpt.com)
- **数据库/中间件专项观测深耕**
国内互联网公司（如美团）对数据库在 K8s 的**专项监控与告警**做了深度集成，强调与原生监控体系融合（指标—>早预警—>自动化处置链）。 [kubeblocks.io](https://kubeblocks.io/blog/run-databases-on-k8s-insights-from-leading-chinese-internet-companies?utm_source=chatgpt.com)

| 公司 | APM（应用观测） | NPM/网络侧 | 主要栈/产品 | 公开亮点（摘） |
|:----|:----|:----|:----|:----|
| 字节跳动 | 自研/对外产品 APMPlus（火山引擎），内外统一用 OTel 采集；内部有 BytedTrace（统一 Tracing/Logging/Metrics 的平台化方案） | （公开资料以应用侧为主，网络侧细节披露较少） | APMPlus + OTel Collector（自动注入/接入）、CloudWeGo 生态 | APMPlus 是字节内部大规模实践沉淀，对外提供全链路 APM；APMPlus×CloudWeGo 打造“一站式开发与观测”；OTel Collector 组件化部署。volcengine.com+2火山引擎开发者社区+2 另有 BytedTrace 作为内部一体化可观测方案报道。  |
| 京东 / 京东物流 | 自研 APM（京东云 APM 产品线、金融/物流落地），分布式链路追踪在金融/物流场景大规模推行 | （公开材料更多聚焦业务/链路，不特指 eBPF 网络侧） | 京东云 APM、金融场景分布式追踪实践（SGM 等）、大规模实时监控+AIOps | 金融场景“分批接入、快速见效”，APM 与告警/认证/CMDB 体系打通；物流线 AIOps + APM 保障大促稳定。 |
| 美团 | CAT（自研开源 APM，日处理百 TB 级数据）+ 终端日志平台 Logan；还有“可视化全链路日志追踪”的体系文章 | （公开文更多在应用/日志/终端侧） | CAT、Logan、可视化链路日志方案（与 ELK 辅助） | CAT 深耕多年、规模化 APM 的代表；终端实时日志 Logan 提升客户端问题定位；对“日志→链路”可视化方法有系统沉淀。 |
| 滴滴 | 早期自研 DD-Falcon/夜莺(Nightingale) 体系覆盖监控与告警，含分布式调用链、异常检测、压测平台等整体可观测构件 | 有提到“网络/数据通道/日志平台”配合，但细节披露以平台化监控为主 | DD-Falcon/夜莺（Nightingale）+ ES/实时数据通道 + 可观测架构多阶段演进 | 公开演讲/文稿显示：从监控系统到异常检测、压测平台的全链路能力；夜莺作为分布式高可用监控系统在混合云/K8s 场景落地。pic.huodongjia.com+2知乎专栏+2 |


>  说明：NPM（网络观测）层的公开披露在国内通常**更少**，不少公司把网络侧能力融合在平台里（如流量证据、依赖拓扑、网格可视化等），但未必单独称“NPM”。如果要专看“网络/eBPF/流量侧”的公开国产案例，**DeepFlow 在运营商/银行/云厂商**的实践文章较多
>

# 国外（代表性做法）

- **自研底座 + 开源生态并用**
Uber：自研 **M3**（指标）+ 开源 **Jaeger**（追踪）+ 内部采样服务组合治理可观测成本与效果，是“大规模微服务”常见路径。 [Uber](https://www.uber.com/blog/optimizing-observability/?utm_source=chatgpt.com)
Netflix：自研 **Atlas** 做维度时序数据的近实时遥测，满足高并发场景的运维分析。 [techblog.netflix.com+2netflix.github.io+2](https://techblog.netflix.com/2014/12/introducing-atlas-netflixs-primary.html?utm_source=chatgpt.com)
Lyft：以 **Envoy** 为服务网格/网关基石，天然强化可观测指标/日志/追踪（后端常接 OTel/Jaeger/Tempo）。 [Lyft Engineering](https://eng.lyft.com/announcing-envoy-c-l7-proxy-and-communication-bus-92520b6c8191?utm_source=chatgpt.com)
- **开放标准 OTel 为核心“采集层”**
海外主流团队把 **OpenTelemetry** 视为“统一采集+语义标准”，后端选择灵活（Tempo/Jaeger/Elastic/New Relic/Dynatrace 等）。 [Uptrace](https://uptrace.dev/comparisons/jaeger-vs-opentelemetry?utm_source=chatgpt.com)

# 国外互联网大厂可观测实践：APM / NPM & 技术栈对比

| 公司 | APM（应用观测） | NPM / 网络侧 | 主体技术栈 / 组件 | 亮点与取舍 |
|:----|:----|:----|:----|:----|
| Uber | Jaeger（自研并捐赠 CNCF；大规模分布式追踪） jaegertracing.io+1 | Mesh/边车与网络指标结合（公开资料以应用侧为主） | M3（超大规模指标平台）+ Jaeger + 自研采样与告警链路（uMonitor/Neris） Uber+3Uber+3M3+3 | “自研核心 + 开源输出”路线：百万级指标与大规模追踪并行，重采样与告警可扩展性。 |
| Netflix | 以 Atlas 为主的运行时遥测，APM 由多组件协同（Tracing 常接 OTel/Jaeger/Tempo） netflix.github.io+2netflix.github.io+2 | Envoy/Istio 等网格遥测配合（公开资料多在指标/平台侧） | Atlas（维度时序、近实时运维洞察）+ Mesh 遥测接 OTel 后端 netflix.github.io+1 | “指标为王”的实时运营视角：极强的在线查询与维度切片能力，Tracing 后端可插拔。 |
| Google | 以 OTel 标准为采集统一面（Cloud Operations/Stackdriver 体系） | Istio/Envoy 遥测 + 云探针（ThousandEyes 等为行业常见补充） | Monarch 星球级 TSDB（论文）+ OTel 采集 + Mesh 遥测 VLDB+1 | “标准化采集 + 超大规模时序库”：统一三信号语义，后端服务化运营。 |
| Meta（Facebook） | 内部一体化观测（公开论文偏指标） | 网络侧细节对外较少 | Gorilla 内存 TSDB（论文）作为核心指标基座 VLDB+1 | “指标压缩与近线价值”理念：高压缩、低延迟，强调近期数据的重要性。 |
| Lyft | 基于 OTel/Jaeger 等开源链路 | Envoy（自研，后捐开源） 提供 L7 遥测/依赖拓扑 | Envoy + OTel/Jaeger（或 Tempo）链路后端 envoyproxy.io+1 | “以网格为基础设施”的观测：网络/应用边界自然打通。 |
| Airbnb | 大量采用 Datadog（APM/告警/仪表） Datadog+1 | Datadog NPM/合规探针配合（公开分享以 APM/告警为主） | Datadog SaaS 平台（监控即代码、统一告警） Datadog | “SaaS 化省心”路线：工程团队聚焦业务，代价是规模化成本需精算。 |
| SaaS 用户如 Slack/Shopify | 常见于 Datadog / New Relic / Dynatrace 组合（厂商公开案例） | NPM / Synthetics 结合 APM 使用 | 商用一体化平台 + OTel 接入 | 快速落地与运营省心，对数据量/留存的成本治理要求高。 |
| Grafana 社区路线（Spotify 等） | OTel + Tempo（Trace） | Loki/Mimir + Cilium-Hubble（网络可视） | “开源拼装”：OTel → Tempo/Jaeger；Logs→Loki；Metrics→Mimir/Cortex；NPM→Hubble | “开源优先 + 成本可控”：需要更强的自运维与采样/留存策略。 |


----

# 快速对照（APM / NPM 归类视角）

| 区域 | APM 主线（应用可观测） | NPM 主线（网络/流量可观测） | 一体化趋势 |
|:----|:----|:----|:----|
| 国内 | 阿里云 ARMS、自研 + OTel/SkyWalking；部分采用商用平台 | DeepFlow、Cilium/Hubble 在云原生里普及；运营商/金融偏爱流量侧证据链 | 更强调无侵入 eBPF + 统一数据面，兼顾合规与私有化落地。  |
| 国外 | 自研（Netflix Atlas、Uber M3）+ 开源（Jaeger/OTel）+ 商用（Datadog/Dynatrace/New Relic） | Envoy / Service Mesh + 流量遥测；NPM 与 APM 共同驱动 SLO | OTel 标准化采集成共识，后端/可视化自由拼装。  |


# 共同趋势

1. eBPF 上位、数据面“内核化”: 以零侵入内核态采集作为地基，贯通网络 ↔ 应用的断点，兼顾性能与覆盖。（国内：DeepFlow；海外：Pixie / 各厂 eBPF 模块） 采集标准化（OpenTelemetry），后端多样化
2. 统一（Metrics/Logs/Traces）与语义，解耦采集与存储/分析，降低厂商锁定。后端按成本与能力自由组合（Tempo/Jaeger/Mimir/Loki、或商用；也有 Uptrace 这类一体化选择）。
3. 成本治理成为刚需
- 采样：tail-based / 规则化采样，优先保留有价值的 Trace。
- 分层：冷热数据分层、短保留（原始）+ 指标化长保留（降粒度）。
- 存算与留存策略与告警价值挂钩，面向大规模可用性。
4. Trace 作为“上下文总线”:
- 以 Trace 串联指标与日志，携带服务/调用上下文，帮助做跨组件与跨团队的 RCA（根因分析）。
- “网络证据 + 应用 Trace”合并判定，提升定位效率与置信度。
5. 平台一体化 + AIOps: 
- 从“自己拼零件”转向“用平台”，内置降噪、因果/异常检测与自动化修复。在海量场景下，以策略引擎和知识/因果图谱降低噪声，闭环故障处理。
