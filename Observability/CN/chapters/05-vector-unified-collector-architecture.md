# Vector 统一采集架构与 DeepFlow Agent 对比

## 1. 架构概览

Vector 可以作为统一的采集出口，将系统、进程、网络和日志数据汇聚后再转发到不同的可观测性后端。

示例链路：
```
node_exporter ─┐
process_exporter ─┤
DeepFlow Agent ──▶ Vector Agent ──▶ Loki
journald/syslog ─┘                ├─▶ Prometheus Remote Write
                                  └─▶ Tempo
```

### 核心设计
- **Sources**：`prometheus_scrape` 用于拉取 node_exporter、process-exporter 指标；`journald`/`file` 采集系统与 DeepFlow 日志。
- **Transforms**：`remap` 统一标签，如把 `instance` 改为 `host`，补充业务标签。
- **Sinks**：同时写入 Prometheus 兼容数据库、Loki、Tempo 等多种后端，支持 TLS 与鉴权。

## 2. 配置拆分与样例

Vector 支持将配置拆分为多个文件，主配置通过 `includes` 统一加载：

```
/etc/vector/
├── vector.yaml
├── sources/
│   ├── node_exporter.yaml
│   ├── process_exporter.yaml
│   └── journald.yaml
├── sinks/
│   ├── prometheus.yaml
│   └── loki.yaml
└── transforms/
    └── tags.yaml
```

**主配置 vector.yaml**
```yaml
data_dir: /var/lib/vector
includes:
  - /etc/vector/sources/*.yaml
  - /etc/vector/sinks/*.yaml
  - /etc/vector/transforms/*.yaml
```

**示例 source/sink 片段**
```yaml
# sources/node_exporter.yaml
sources:
  node_exporter:
    type: prometheus_scrape
    endpoints: ["http://localhost:9100/metrics"]
    scrape_interval_secs: 15

# sinks/prometheus.yaml
sinks:
  prometheus_out:
    type: prometheus_remote_write
    inputs: ["add_tags"]
    endpoint: "http://vm.example.com/api/v1/write"
```

拆分后可独立修改某个采集器配置，便于模块化维护和热更新。

## 3. 高负载下的可靠性机制

Vector 在高负载场景中通过多层保护减少数据丢失：

| 机制 | 说明 |
| --- | --- |
| 背压控制 | 当下游拥塞时暂停上游读取，防止爆仓 |
| 缓冲策略 | 支持内存或磁盘缓冲，`when_full = "block"` 默认阻塞而非丢弃 |
| 重试与限流 | 对 Loki、Prometheus 等 sink 内置重试与 backoff，支持 `rate_limit` |
| 降级策略 | `drop_on_full = false`，尽量保留数据 |
| 自监控指标 | `/metrics` 暴露 `events_dropped_total`、`buffer_overflows_total` 等指标供告警 |

## 4. 采集器能力对比

| 特性/组件 | node_exporter | process-exporter | DeepFlow Agent | Vector Agent |
| --- | --- | --- | --- | --- |
| 安装体积 | <20MB | <20MB | ≈70–100MB | ≈70MB |
| 资源占用 | 极低 | 低 | 中等（依赖 eBPF） | 低~中，可限内存 |
| 采集维度 | 主机资源 | 进程资源 | 网络四/七层 | 指标、日志、链路 |
| 输出能力 | Prometheus | Prometheus | DeepFlow Collector | Prometheus、Loki、Tempo 等 |
| 可靠性 | 无背压 | 无背压 | 重试有限 | 背压 + 缓冲 + 重试 |

Vector 在可靠性、可扩展性与自观测能力上相较 DeepFlow Agent 更为成熟，后者适合作为网络事件探针。

## 5. 渐进式部署路线

1. **平台自身稳定性**：部署 node_exporter、process-exporter 与 Vector，先掌握主机与关键进程状态。
2. **网络可观测**：引入 DeepFlow Agent，分析 L4/L7 流量，后端可用 ClickHouse + Grafana 展示。
3. **日志聚合**：Vector 同步写入 Loki 或其他日志系统，辅助故障排查与审计。
4. **链路追踪**：启用 Vector → Tempo 或 OTLP，将 DeepFlow 产出的 trace 信息整合展示。
5. **示例 process-exporter 配置**：
    ```yaml
    process_names:
      - name: "deepflow-agent"
        cmdline: ["deepflow-agent"]
      - name: "clickhouse"
        cmdline: ["clickhouse-server"]
    ```

## 6. Server 端存储选型

为了在后端构建统一、弹性、低成本的可观测平台，可按数据类型选用以下组件：

### Metrics：VictoriaMetrics
- **优势**：单机即可实现百万点/秒写入，兼容 PromQL，支持自动压缩并将历史数据归档到 S3/GCS。
- **采集建议**：使用 `vmagent` 或 Vector 远程写入，也可通过 otel-collector 接入 OpenTelemetry Metrics。

### Logs：Loki
- **优势**：基于标签的索引方式，运行成本低；原生支持 Vector、Fluent Bit、Promtail 等采集器，兼容结构化与非结构化日志。
- **采集建议**：通过 Vector 统一收集 journald 与文件日志，按主机和应用维度设置标签，可配置 S3 归档策略。

### Traces：Tempo
- **优势**：兼容 OTLP、Zipkin、Jaeger 协议；依赖对象存储实现冷热分层，资源占用极低，并能与 logs/metrics 自动关联。
- **采集建议**：应用直接使用 OpenTelemetry SDK，或经由 otel-collector、Vector 输出 OTLP 数据。

### 结构化数据：PostgreSQL（可选）
- **用途**：存储事件、审计、成本等业务数据，配合 Grafana 表格/统计面板做结构化分析。
- **扩展**：
  - TimescaleDB：增强时间序列查询能力。
  - pgvector：提供向量检索，可结合 AI 做相似事件分析。
  - postgres_fdw：整合多个 PostgreSQL 数据源。

### 推荐部署组合

| 数据类型 | 后端存储 | 采集/转发组件 | 说明 |
| --- | --- | --- | --- |
| Metrics | VictoriaMetrics | vmagent / Vector | 远程写入并归档到对象存储 |
| Logs | Loki | Vector | 按小时本地留存，按日归档到 S3 |
| Traces | Tempo | otel-collector / Vector | 可按需采样与压缩 |
| 结构化数据 | PostgreSQL (+Timescale) | 应用或 ETL | 用于业务事件与分析 |

### 组合优势

- **统一采集**：Vector 汇聚日志、指标、链路三类数据，再转发至不同后端。
- **安全加密**：各组件均支持 TLS 与 Token 鉴权。
- **高性能、低成本**：组件均为原生二进制部署，可使用对象存储做冷数据归档。
- **Grafana 统一展示**：VictoriaMetrics、Loki、Tempo、PostgreSQL 均为官方数据源，可在 Grafana 中集中呈现。

## 7. 总结

通过 Vector 构建统一采集出口，可在保证稳定性的同时整合指标、日志、链路与结构化数据。DeepFlow Agent 专注网络可观测，结合推荐的后端存储组件，可形成覆盖系统到业务的完整可观测体系。
