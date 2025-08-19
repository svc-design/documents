# PostgreSQL + ClickHouse 高性能分层写入架构

## 1. 架构目标

- 模仿 GreptimeDB 的分层写入能力：热写入 PostgreSQL（TimescaleDB 扩展）并按需冷聚合到 ClickHouse。
- 支持多协议接入（REST / gRPC / OpenTelemetry / Arrow Flight）。
- 动态表结构注册，借助 JSONB 与元数据表管理 schema。
- 易于在单机 PoC、集群与存算分离之间平滑扩展。

## 2. 架构总览

```mermaid
graph TD
    subgraph Client
        A[Vector Agent]
    end

    subgraph Transport
        A --> B[Unified API (REST/gRPC/OTel)]
    end

    subgraph Storage
        B --> C1[PostgreSQL (TimescaleDB + JSONB)]
        B --> C2[ClickHouse (OLAP 聚合)]
    end

    subgraph Query
        C1 --> D[Grafana / SQL API]
        C2 --> D
    end
```

## 3. 核心组件

### 3.1 API 层
使用 Go / Rust 编写 Ingest 网关：
- `/write/metrics` → TimescaleDB
- `/write/logs` → ClickHouse
- `/schema/register` → 写入 `table_registry` 元数据表

### 3.2 PostgreSQL 写入端（实时指标）
```sql
CREATE TABLE metrics_events (
  time        TIMESTAMPTZ NOT NULL,
  app         TEXT,
  host        TEXT,
  labels      JSONB,
  value       DOUBLE PRECISION,
  trace_id    TEXT,
  level       TEXT
);
SELECT create_hypertable('metrics_events', 'time');
```

### 3.3 ClickHouse 写入端（归档聚合）
```sql
CREATE TABLE logs_events (
  timestamp DateTime,
  app       String,
  host      String,
  trace_id  String,
  message   String,
  labels    Nested(k String, v String)
) ENGINE = MergeTree()
PARTITION BY toYYYYMMDD(timestamp)
ORDER BY (timestamp, app);
```

### 3.4 Schema 管理
```sql
CREATE TABLE table_registry (
  table_name TEXT PRIMARY KEY,
  schema     JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);
```
注册示例：
```json
{
  "columns": [
    {"name": "time",   "type": "timestamp"},
    {"name": "value",  "type": "double"},
    {"name": "labels", "type": "jsonb"}
  ]
}
```

## 4. 参考配置

### 4.1 Vector 采集配置
```toml
[sources.prom]
type = "prometheus_scrape"
endpoints = ["http://localhost:9100/metrics"]

[sources.logs]
type = "journald"

[transforms.jsonify_logs]
type = "remap"
inputs = ["logs"]
source = '''
.structured = parse_json!(string!(.message))
'''

[sinks.pg]
type = "postgresql"
inputs = ["prom", "jsonify_logs"]
database = "metrics"
endpoint = "postgresql://user:pass@pg:5432/metrics"
table = "observability_events"
mode = "insert"
compression = "zstd"

[sinks.ch]
type = "clickhouse"
inputs = ["jsonify_logs"]
endpoint = "http://clickhouse:8123"
database = "default"
table = "logs"
compression = "gzip"
```

### 4.2 Grafana 查询示例
- **PostgreSQL 数据源**
```sql
SELECT time_bucket('1 minute', event_time) AS ts, COUNT(*)
FROM observability_events
WHERE node = $__variable_node
  AND raw->>'source' = $__variable_source_type
  AND $__timeFilter(event_time)
GROUP BY ts
ORDER BY ts;
```

- **ClickHouse 数据源**
```sql
SELECT node, count() AS total
FROM logs
WHERE timestamp >= $__from AND timestamp <= $__to
GROUP BY node
ORDER BY total DESC
LIMIT 5;
```

## 5. 部署演进路径

| 阶段 | 特性 | 说明 |
| --- | --- | --- |
| 单节点一体化 | 所有组件运行在一台主机 | 适合 PoC / 开发环境 |
| 多副本集群 | API、PG、CH 分别部署为独立节点，可接入负载均衡 | 支持横向扩展与高可用 |
| 存算分离 | 引入 Kafka 等缓冲层，PG/CH 采用分布式与 Replication | 写入与查询解耦，适合大规模场景 |

## 6. 测试验证方案

### 6.1 测试目标

| 目标类别 | 说明 |
| --- | --- |
| 💾 吞吐能力 | 是否能支撑 50K+ IOPS 持续写入并在高峰期达到 100K/s |
| 🧠 查询能力 | 事件查询/统计分析响应稳定在 100~500ms |
| 🔁 分层写入正确性 | 标签/类型是否正确路由至 PostgreSQL 与 ClickHouse |
| 🔐 数据一致性 | PostgreSQL 中 Trace、事件无漏写 |
| 📈 可观测性 | Vector/PG/CH 与系统资源均可监控 |

### 6.2 基础环境准备

**数据源模拟**

| 工具 | 用途 |
| --- | --- |
| vector generator / log-generator | 模拟高负载日志流 |
| OpenTelemetry demo | 生成 Trace 数据 |
| prometheus-testgen | 生成 Metrics 样本 |

**写入目标部署**

| 系统 | 推荐配置 |
| --- | --- |
| PostgreSQL | 16+ + TimescaleDB + pg_partman |
| ClickHouse | 24.4+ + ReplicatedMergeTree |
| Vector | 支持 transforms 路由、sink 至 PG/CH |
| 监控组件 | node_exporter、pg_exporter、vector internal、CH monitor |

### 6.3 测试维度与方法

#### 6.3.1 吞吐验证

| 项目 | 方法 | 期望 |
| --- | --- | --- |
| 最大持续写入 | 持续向 Vector 发送 JSON logs @ 50K/s，观察是否丢包 | ACK latency < 500ms |
| 高峰瞬时写入 | 峰值 100K/s 持续 1 min，观察 PG/CH 报错情况 | 无错误、吞吐稳定 |
| 网络抖动模拟 | 通过 `tc` 注入延迟/丢包，观察重试 | 数据无丢失 |

#### 6.3.2 数据分层准确性

| 验证点 | 检查项 |
| --- | --- |
| Trace 事件 → PostgreSQL | 是否按时间/traceID 正确分区落表 |
| 普通日志 → ClickHouse | 是否按标签写入 MergeTree 表 |
| 异常标签 | 是否触发 fallback/dead-letter |

#### 6.3.3 查询验证

| 类型 | 查询目标 | 预期性能 |
| --- | --- | --- |
| PostgreSQL | 精确事件 → TraceID 查询 | <200ms |
| ClickHouse | 日志聚合 → app error rate | <1s |
| 联合 | Trace + 日志聚合视图 | <1.5s |

#### 6.3.4 资源使用验证

| 组件 | 监控项 | 期望值 |
| --- | --- | --- |
| Vector | CPU < 300m、Mem < 300MB | ✅ |
| PostgreSQL | IOPS < 40K / WAL flush latency | ✅ |
| ClickHouse | Merge 负载、后台线程瓶颈 | ✅ |

#### 6.3.5 自动化脚本示例

```go
for i := 0; i < 100000; i++ {
  body := map[string]interface{}{
    "app": "auth", "trace_id": fmt.Sprintf("t-%d", i), "message": "log",
    "ts": time.Now().UnixNano() / 1e6,
  }
  jsonBody, _ := json.Marshal(body)
  http.Post("http://localhost:9000/my-pg-sink", "application/json", bytes.NewBuffer(jsonBody))
}
```

### 6.4 异常与恢复测试

| 验证目标 | 方案 | 期望指标 |
| --- | --- | --- |
| Vector 重启/崩溃 | 高负载写入时重启 Vector，观察数据补写 | 无重复或漏写 |
| PG/CH 停机 | 短暂下线数据库，观察 Vector 缓冲 | 自动重试，恢复后数据一致 |
| 网络断连恢复 | 使用 netem 模拟断网，检查重连 | 不丢失、不时序异常 |

### 6.5 可观测性与告警

| 验证目标 | 方案 | 期望指标 |
| --- | --- | --- |
| 指标完备性 | 检查 Vector、PG、CH、OS 指标 | 覆盖率 > 95% |
| 告警规则有效性 | 模拟 CPU/延迟异常触发告警 | 告警及时 |
| 日志追踪 | 通过集中日志跟踪关键事件 | 故障可快速定位 |

### 6.6 验证成功标准

| 维度 | 成功判定 |
| --- | --- |
| 写入链路 | ≥ 95% 写入无丢失，ACK latency 稳定 |
| 数据正确性 | PG 与 CH 数据能联查对齐，时间戳正确 |
| 系统资源 | 单节点 PG/CH/Vector CPU < 50%，无 OOM |
| 查询性能 | 常用 Trace 查询 <500ms |
| 异常处理 | 标签异常可自动 fallback 或告警记录 |

### 6.7 可选增强场景

- 断点恢复测试：模拟 Vector 中断、PG WAL 积压后的补写能力  
- 导入真实日志样本：使用历史 prod 日志替代模拟器  
- 滚动升级兼容性：升级 Vector/CH 时验证数据路径稳定性  
- 跨地域部署：验证跨区复制对写入与查询的影响

## 7. 结语
通过 PostgreSQL + ClickHouse 的分层写入方案，可以在保证实时查询能力的同时实现高吞吐归档和聚合分析，为可观测性平台提供灵活、可扩展的存储基础。

