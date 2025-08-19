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

## 6. 结语
通过 PostgreSQL + ClickHouse 的分层写入方案，可以在保证实时查询能力的同时实现高吞吐归档和聚合分析，为可观测性平台提供灵活、可扩展的存储基础。

