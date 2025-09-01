
# **目录结构**

---

## **概述（Overview）**

### **01-overview.md**
- **1.1 引言**
- **1.2 内容简介**
- **1.3 目标读者**

---

## **数据类型与指标**

### **2. 可观测性数据类型总览（Telemetry Overview）**

#### **02-telemetry-overview.md**
- **2.1 指标（Metrics）**
- **2.2 日志（Logs）**
- **2.3 追踪（Traces）**
- **2.4 事件（Events）**
- **2.5 性能剖析（Profiles）**
- **2.6 网络元组（Network Tuples）**
- **2.7 SLA / SLO / SLI**

---

## **eBPF 技术与应用**

### **03-bpf-overview.md**
- **3.1 概述**
- **3.2 对比**
- **3.3 场景**

---

## **应用系统故障排查**

### **4.1 故障排查整体流程**

#### **4.1.1 从客户端到服务端的请求路径**
- DNS 解析
- TCP 连接建立
- TLS 握手（如适用）
- 请求发送与响应接收

#### **4.1.2 分层排查思路**
- 应用层
- 服务层
- 网络层
- 物理层

---

### **4.2 应用请求关联指标的排查**

#### **4.2.1 响应时间**
- 慢请求分析
- 依赖服务性能

#### **4.2.2 错误率**
- 服务端异常 vs 客户端异常
- HTTP 状态码分析

#### **4.2.3 系统资源使用率**
- CPU 和内存监控
- 资源泄漏检测

#### **4.2.4 用户留存率**
- 用户行为分析
- 功能可用性检查

#### **4.2.5 吞吐量**
- 负载测试
- 扩展能力评估

---

### **4.3 网络关键指标的排查**

#### **4.3.1 带宽利用率**
- 流量监控
- 异常流量检测

#### **4.3.2 延迟**
- 网络路径优化
- 地理位置影响

#### **4.3.3 丢包率**
- 链路质量
- 设备故障排查

#### **4.3.4 网络抖动**
- 实时应用影响
- 网络稳定性提升

#### **4.3.5 网络可用性**
- 冗余设计
- 故障切换机制

#### **4.3.6 重传率**
- 拥塞控制
- 传输优化

#### **4.3.7 TCP 连接时间**
- 握手延迟分析
- 服务器性能

#### **4.3.8 DNS 查询时间**
- DNS 服务优化
- 缓存策略

#### **4.3.9 HTTP 请求成功率**
- 服务器健康检查
- 网络异常处理

---

### **4.4 日志分析与故障定位**

#### **4.4.1 网络日志分析**
- 流日志
- 数据包日志

#### **4.4.2 服务日志分析**
- 调用链追踪
- 接口性能监控

#### **4.4.3 应用日志分析**
- 错误堆栈
- 业务逻辑验证

---

### **4.5 典型故障场景与案例分析**

#### **4.5.1 服务端异常**
- 资源耗尽
- 依赖服务故障

#### **4.5.2 客户端异常**
- 请求格式错误
- 网络连接失败

#### **4.5.3 综合案例**
- 从问题描述到根因定位

---

## **附录**

### **5.1 术语表**
### **5.2 参考资料**
### **5.3 工具与资源**
### **5.4 生产级监控配置方案（Linux 裸机）**
#### **05-production-monitoring-linux-bare-metal.md**
- 系统与进程指标采集、历史保底以及安全加固实践
### **5.5 Vector 统一采集架构与 DeepFlow 对比**
#### **05-vector-unified-collector-architecture.md**
- Vector 汇聚多类 exporter，比较 DeepFlow 与 Vector 的功能与部署策略，并给出后端存储选型建议

### **5.6 PostgreSQL + ClickHouse 分层写入架构**
#### **05-postgres-clickhouse-layered-architecture.md**
- 使用 TimescaleDB + ClickHouse 构建热写冷存的可观测性存储，实现高并发写入与 OLAP 聚合

---

## **架构设计与容灾**

### **6.1 技术选型对比（Technology Selection Comparison）**
#### **06-technical-selection-comparison.md**
- 边缘采集对比
- 网关对比
- 存储对比
- 分析层对比

### **6.2 总体架构设计**
#### **07-overall-architecture-design.md**
- 边缘采集与缓冲
- 区域网关与扇出
- 存储与分析层
- 双链路（近线检索 + Kafka 回放）

### **6.3 多区域架构与区域内拓扑**
#### **08-multi-region-architecture-topology.md**
- 区域内拓扑（单区示例）
- 多区域部署模式（主区 + 从区）
- 联邦查询与统一入口

### **6.4 端到端可靠传输设计（At-least-once 语义）**
#### **09-end-to-end-reliable-transmission-design.md**
- 多级持久化链（Vector → OTel → Kafka → OpenObserve）
- 扇出与去重策略（event_id + UPSERT）
- SRE 可观测与演练方法

### **6.5 PostgreSQL 二级分析域**
#### **10-postgresql-secondary-analysis-domain.md**
- 时序分析（TimescaleDB 连续聚合）
- 向量检索（pgvector）
- 图查询（Apache AGE）
- 高基数与 TopK 分析（HLL/Toolkit）

### **6.6 多区域与容灾（Disaster Recovery, DR）**
#### **11-multi-region-disaster-recovery.md**
- 接入与路由（Anycast/GeoDNS）
- 跨区复制与镜像（Kafka MirrorMaker2）
- 阈值控制与降级策略
- 历史回放与灰度演练

## **监控简史（Monitoring History）**

### **7.1 漫谈监控简史到全栈可观测数据选型**
#### **12-1-monitoring-history-to-full-stack-observable-data-selection.md**

### **7.2 典型运维工作场景**
#### **12-2-typical-operations-scenarios.md**

## **可观测系统设计篇（Observability System Design）**

### **8.1 边缘采集与网关的抉择**
#### **13-1-edge-collection-vs-gateway.md**

### **8.2 OTel Gateway 的设计与思考**
#### **13-2-otel-gateway-design-considerations.md**

### **8.3 数据采集多级持久化与可重放**
#### **13-3-data-ingestion-multi-level-persistence-and-replay.md**

### **8.4 全栈可观测数据库设计**
#### **13-4-full-stack-observability-database-design.md**

### **8.5 全栈可观测数据库 ETL 设计**
#### **13-5-full-stack-observability-database-etl-design.md**

### **8.6 监控系统的多区域与容灾**
#### **13-6-monitoring-system-multi-region-and-dr.md**

## **LLM OPS Agent 设计篇（LLM OPS Agent Design）**

### **9.1 从 SSH/SCP 到 AI 驱动的 OPS Agent：落地前的思考**
#### **14-1-from-ssh-scp-to-ai-ops-agent-pre-deployment-considerations.md**

### **9.2 从 SSH/SCP 到 AI 驱动的 OPS Agent：能力清单**
#### **14-2-from-ssh-scp-to-ai-ops-agent-capability-checklist.md**

### **9.3 PostgreSQL 扩展驱动的复杂分析（向量 / 图 / 趋势）**
#### **14-3-postgresql-extension-driven-complex-analysis-vector-graph-trend.md**

### **9.4 AI-OPS Agent MVP 架构方案**
#### **14-4-ai-ops-agent-mvp-architecture.md**
