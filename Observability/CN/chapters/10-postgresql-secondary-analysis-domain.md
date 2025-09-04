# PostgreSQL 二级分析域

- 时序分析（TimescaleDB 连续聚合）
- 向量检索（pgvector）
- 图查询（Apache AGE）
- 高基数与 TopK 分析（HLL/Toolkit）

# IT咖啡馆｜全栈可观测数据库设计

> 线 I/O 面交给 OpenObserve（OO），治理/知识面沉到 PostgreSQL 栈（Timescale + AGE + pgvector）。保留明细在 OO，只把聚合、摘要、索引与证据链写回 PG：既省钱、又好查、也好演进。

---

## 摘要

本文落地一套「全栈可观测」数据库设计：明细进 OO，PG 仅存 12 张核心表（维度、定位符、指标 1m、服务调用 5m、日志指纹/计数、拓扑时态、知识库、事件/证据），并用 AGE 维护“当前服务级调用图”。给出可直接执行的 DDL、保留与压缩策略、典型查询与接入流程。

---

## 设计目标

- **最小化**：仅保 1m 指标聚合、5m 服务调用/日志计数；图仅保“当前 10 分钟活跃边”。
- **可扩展**：OO 扛明细与重计算；PG 通过加列/并行表横向扩展。
- **可解释**：事件只挂索引与证据链；需要原文用 oo\_locator 反查 OO。

### 分层原则

- **线 I/O 面（近线）**：OO（对象存 + 列式 + 低成本长期留存）。
- **治理/知识面**：PG（Timescale 连续聚合/压缩、AGE 图、pgvector 检索）。

---

## 数据模型总览（12 表 + AGE）

**维度（2）**：`dim_tenant`、`dim_resource`

**定位符（1）**：`oo_locator`（对象存路径 + 时间窗 + 查询 hint）

**聚合（3）**：`metric_1m`、`service_call_5m`、`log_pattern_5m`；

**指纹（1）**：`log_pattern`

**拓扑（1）**：`topo_edge_time`（边 + 有效期）

**知识（2）**：`kb_doc`、`kb_chunk`（HNSW 向量索引）

**事件（2）**：`event_envelope`、`evidence_link`

**图（AGE）**：仅维护“服务级调用图”的活跃子图（10 分钟窗口）。

> 注：日志明细、trace span、指标原始点位 **不入 PG**，统一留在 OO。

---

## 表设计与策略（逐表解读）

### 1）维度

- `dim_tenant`：租户/域；用 `code` 做业务唯一键。
- `dim_resource`：统一资源 URN（如 `urn:k8s:svc:ns/name`），含环境/区域/标签。

**策略**：

- 为 `type`、`labels` 建索引（B-Tree + GIN），支撑过滤与聚合。
- 跨区/多租户时，尽量靠 `tenant_id` 分片路由。

---

### 2）OO 定位符

- `oo_locator`：只存 **对象存路径**、**时间窗**、**查询 hint**，作为“回查线索”。

**策略**：

- 与聚合表通过 `sample_ref` 关联，形成“摘要 → 原文”的证据链。

---

### 3）指标聚合（1 分钟）

- `metric_1m`：按资源、指标名保 `avg/max/p95` 常用统计，Timescale Hypertable。

**策略**：

- **压缩**：7 天后压缩；
- **留存**：180 天；
- **索引**：`(resource_id, metric, bucket desc)` + `labels` GIN。

---

### 4）服务级调用聚合（5 分钟）

- `service_call_5m`：A→B 的 `rps/err_rate/p50/p95`，主键含窗口/租户/边端点。

**用途**：

- 报表/拓扑；
- 刷新 AGE “活跃调用图”。

**策略**：留存 365 天，适配容量评估与 SLO 分析。

---

### 5）日志指纹/计数（5 分钟）

- `log_pattern`：指纹模板库（去重 + 样例 + 严重级 + 抽取 schema），`pg_trgm` 支持模糊。
- `log_pattern_5m`：每 5 分钟的计数与错误计数；**不存明细**。

**策略**：

- 借 `sample_ref` 反查 OO 原文；
- 留存 180 天。

---

### 6）拓扑时态

- `topo_edge_time`：边 + 有效期 `tstzrange`，用于追溯“某时刻的拓扑”。

**策略**：

- `btree_gist` + GIST 范围索引，支持按时间窗口查询。

---

### 7）知识库 / 向量

- `kb_doc`：文档元信息（来源、标题、URL、元数据）。
- `kb_chunk`：切片 + 向量（`vector(1536)`），`USING hnsw` 建立近似检索。

**策略**：

- 以 `tenant_id/资源/时间` 作为结构化过滤条件，向量召回后再二次排序。

---

### 8）事件与证据链

- `event_envelope`：事件封套（时间/资源/严重级/类型/摘要/标签/指纹）。
- `evidence_link`：**多态引用**到 PG 记录或 `oo_locator`，串起证据链。

**关键修正**：

- PostgreSQL **主键不允许表达式**，因此 `evidence_link` 使用 **自增主键 + 唯一索引（基于 ref\_pg 的 hash + ref\_oo）** 实现“幂等去重”。详见附录 DDL。

---

## 图：只维护“当前 10 分钟活跃调用图”

- 从 `service_call_5m` 挑选近 10 分钟活跃边（按租户/边聚合），用 AGE 的 `MERGE` 同步：
    - 点：`(:Resource {tenant_id, resource_id})`
    - 边：`[:CALLS {last_seen, rps, err_rate, p95}]`
- 图用于 **k-hop、最短路、影响面**，而不是长期时序（时序仍在 `service_call_5m` & `topo_edge_time`）。

---

## 最小化接入流程

**写入**：

1. 明细 → OO（logs/traces/metrics）；
2. 近线作业在 OO 内计算聚合：写入 `metric_1m`、`service_call_5m`、`log_pattern_5m`；
3. 同步 `oo_locator`（对象路径 + 时间窗 + hint）；
4. 用聚合结果刷新 AGE 活跃调用图。

**读取**：

- 近线排障：先看 `metric_1m` / `log_pattern_5m` / `service_call_5m`；
- 影响面/最短路：走 AGE；
- 需要原文：根据 `sample_ref` / `evidence_link.ref_oo` 反查 OO。

**默认留存**：

- `metric_1m`：180 天；`service_call_5m`：365 天；`log_pattern_5m`：180 天；
- OO 明细：30–180 天或更久（对象存便宜）。

---

## 典型查询

**1）过去 30 分钟某服务下游 Top‑5 慢/错依赖**

```sql
SELECT d.urn AS dst, avg(p95_ms) AS p95, avg(err_rate) AS err
FROM service_call_5m c
JOIN dim_resource s ON s.resource_id = c.src_resource_id
JOIN dim_resource d ON d.resource_id = c.dst_resource_id
WHERE s.urn = $service_urn
  AND c.bucket >= now() - interval '30 minutes'
GROUP BY d.urn
ORDER BY p95 DESC, err DESC
LIMIT 5;
```

**2）按事件拉取证据（含 OO 回查线索）**

```sql
SELECT e.event_id, e.title, e.detected_at, r.urn,
       ev.dim, ev.ref_pg, ol.bucket, ol.object_key, ol.query_hint
FROM event_envelope e
JOIN dim_resource r ON r.resource_id = e.resource_id
LEFT JOIN evidence_link ev ON ev.event_id = e.event_id
LEFT JOIN oo_locator   ol ON ol.id = ev.ref_oo
WHERE e.event_id = $1;
```

**3）恢复“某一时刻”的服务级拓扑**

```sql
SELECT s.urn AS src, d.urn AS dst, t.relation
FROM topo_edge_time t
JOIN dim_resource s ON s.resource_id = t.src_resource_id
JOIN dim_resource d ON d.resource_id = t.dst_resource_id
WHERE t.tenant_id = $tenant
  AND t.valid @> $timestamp::timestamptz;
```

---

## 与「全塞 PG」的对比

- **成本**：明细不上 PG，写入抖动与存储爆炸显著降低；OO 对象存更省。
- **性能**：常用报表/排障命中 1m/5m 聚合；图遍历走 AGE；需要原文精准回查。
- **演进**：加维度/指标只需 **加列/新表**；图/向量索引也可独立扩展。

---

## 运维与演进建议

- **Timescale**：启用压缩 + 连续聚合（如需），按 7D/30D 切分 Chunk；
- **索引**：B‑Tree（时间倒序复合）+ GIN（labels）+ HNSW（向量）；
- **多租户**：路由以 `tenant_id` 优先；必要时做 schema‑per‑tenant；
- **幂等**：聚合写入用 `ON CONFLICT`；`evidence_link` 采用哈希唯一索引去重；
- **数据治理**：严格区分“摘要/索引/证据”与“明细”；
- **备份**：PG 常规备份；OO 走对象存生命周期策略；
- **安全**：表级 RLS（Row Level Security）可选；`labels` 与 `metadata` 控敏字段打码。

---

## 附录 A：可直接执行的 DDL（含扩展/索引/策略）

```sql
-- 0) 扩展（一次性）
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- gen_random_uuid
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS age;       -- 图扩展（服务级调用图）
LOAD 'age';
CREATE EXTENSION IF NOT EXISTS btree_gist; -- 用于时态拓扑范围索引

-- 1) 维度（2）
CREATE TABLE dim_tenant (
  tenant_id   BIGSERIAL PRIMARY KEY,
  code        TEXT UNIQUE NOT NULL,
  name        TEXT NOT NULL,
  labels      JSONB DEFAULT '{}'::jsonb,
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE dim_resource (
  resource_id BIGSERIAL PRIMARY KEY,
  tenant_id   BIGINT REFERENCES dim_tenant(tenant_id),
  urn         TEXT UNIQUE NOT NULL,
  type        TEXT NOT NULL,
  name        TEXT NOT NULL,
  env         TEXT,
  region      TEXT,
  zone        TEXT,
  labels      JSONB DEFAULT '{}'::jsonb,
  created_at  TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX idx_res_type ON dim_resource(type);
CREATE INDEX idx_res_labels_gin ON dim_resource USING GIN(labels);

-- 2) OO 定位符（1）
CREATE TABLE oo_locator (
  id          BIGSERIAL PRIMARY KEY,
  tenant_id   BIGINT REFERENCES dim_tenant(tenant_id),
  dataset     TEXT NOT NULL,             -- logs / traces / metrics
  bucket      TEXT NOT NULL,
  object_key  TEXT NOT NULL,
  t_from      TIMESTAMPTZ NOT NULL,
  t_to        TIMESTAMPTZ NOT NULL,
  query_hint  TEXT,
  attributes  JSONB DEFAULT '{}'::jsonb
);
CREATE INDEX idx_oo_time ON oo_locator(dataset, t_from, t_to);

-- 3) 指标聚合（1m，Hypertable）
CREATE TABLE metric_1m (
  bucket       TIMESTAMPTZ NOT NULL,
  tenant_id    BIGINT REFERENCES dim_tenant(tenant_id),
  resource_id  BIGINT REFERENCES dim_resource(resource_id),
  metric       TEXT NOT NULL,
  avg_val      DOUBLE PRECISION,
  max_val      DOUBLE PRECISION,
  p95_val      DOUBLE PRECISION,
  labels       JSONB DEFAULT '{}'::jsonb
);
SELECT create_hypertable('metric_1m','bucket',chunk_time_interval => interval '7 days');
CREATE INDEX idx_metric_key ON metric_1m(resource_id, metric, bucket DESC);
CREATE INDEX idx_metric_labels ON metric_1m USING GIN(labels);
ALTER TABLE metric_1m SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'resource_id, metric',
  timescaledb.compress_orderby   = 'bucket'
);
SELECT add_compression_policy('metric_1m', INTERVAL '7 days');
SELECT add_retention_policy   ('metric_1m', INTERVAL '180 days');

-- 4) 服务级调用聚合（5m，Hypertable）
CREATE TABLE service_call_5m (
  bucket          TIMESTAMPTZ NOT NULL,
  tenant_id       BIGINT REFERENCES dim_tenant(tenant_id),
  src_resource_id BIGINT REFERENCES dim_resource(resource_id),
  dst_resource_id BIGINT REFERENCES dim_resource(resource_id),
  rps             DOUBLE PRECISION,
  err_rate        DOUBLE PRECISION,
  p50_ms          DOUBLE PRECISION,
  p95_ms          DOUBLE PRECISION,
  sample_ref      BIGINT REFERENCES oo_locator(id),
  PRIMARY KEY(bucket, tenant_id, src_resource_id, dst_resource_id)
);
SELECT create_hypertable('service_call_5m','bucket',chunk_time_interval => interval '30 days');
CREATE INDEX idx_call_src_dst ON service_call_5m(src_resource_id, dst_resource_id, bucket DESC);
SELECT add_retention_policy('service_call_5m', INTERVAL '365 days');

-- 5) 日志指纹（去重）+ 5m 计数（2）
CREATE TABLE log_pattern (
  fingerprint_id  BIGSERIAL PRIMARY KEY,
  tenant_id       BIGINT REFERENCES dim_tenant(tenant_id),
  pattern         TEXT NOT NULL,
  sample_message  TEXT,
  severity        TEXT,
  attrs_schema    JSONB DEFAULT '{}'::jsonb,
  first_seen      TIMESTAMPTZ,
  last_seen       TIMESTAMPTZ
);
CREATE INDEX idx_logpat_tenant ON log_pattern(tenant_id);
CREATE INDEX idx_logpat_pattern_trgm ON log_pattern USING GIN (pattern gin_trgm_ops);

CREATE TABLE log_pattern_5m (
  bucket         TIMESTAMPTZ NOT NULL,
  tenant_id      BIGINT REFERENCES dim_tenant(tenant_id),
  resource_id    BIGINT REFERENCES dim_resource(resource_id),
  fingerprint_id BIGINT REFERENCES log_pattern(fingerprint_id),
  count_total    BIGINT NOT NULL,
  count_error    BIGINT NOT NULL DEFAULT 0,
  sample_ref     BIGINT REFERENCES oo_locator(id),
  PRIMARY KEY(bucket, tenant_id, resource_id, fingerprint_id)
);
SELECT create_hypertable('log_pattern_5m','bucket',chunk_time_interval => interval '30 days');
CREATE INDEX idx_logpat5m_res ON log_pattern_5m(resource_id, bucket DESC);
SELECT add_retention_policy('log_pattern_5m', INTERVAL '180 days');

-- 6) 拓扑时态（1）
CREATE TABLE topo_edge_time (
  tenant_id       BIGINT REFERENCES dim_tenant(tenant_id),
  src_resource_id BIGINT REFERENCES dim_resource(resource_id),
  dst_resource_id BIGINT REFERENCES dim_resource(resource_id),
  relation        TEXT NOT NULL,
  valid           tstzrange NOT NULL,  -- [from, to)
  props           JSONB DEFAULT '{}'::jsonb,
  PRIMARY KEY(tenant_id, src_resource_id, dst_resource_id, relation, valid)
);
CREATE INDEX idx_topo_valid ON topo_edge_time USING GIST (tenant_id, src_resource_id, dst_resource_id, valid);

-- 7) 知识库 / 向量（2）
CREATE TABLE kb_doc (
  doc_id     BIGSERIAL PRIMARY KEY,
  tenant_id  BIGINT REFERENCES dim_tenant(tenant_id),
  source     TEXT,
  title      TEXT,
  url        TEXT,
  metadata   JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE kb_chunk (
  chunk_id   BIGSERIAL PRIMARY KEY,
  doc_id     BIGINT REFERENCES kb_doc(doc_id) ON DELETE CASCADE,
  chunk_idx  INT NOT NULL,
  content    TEXT NOT NULL,
  embedding  vector(1536) NOT NULL,
  metadata   JSONB DEFAULT '{}'::jsonb
);
CREATE INDEX idx_kb_chunk_doc ON kb_chunk(doc_id, chunk_idx);
CREATE INDEX idx_kb_chunk_meta ON kb_chunk USING GIN(metadata);
CREATE INDEX idx_kb_vec_hnsw ON kb_chunk USING hnsw (embedding vector_l2_ops);

-- 8) 事件 & 证据链（2）
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'severity') THEN
    CREATE TYPE severity AS ENUM ('TRACE','DEBUG','INFO','WARN','ERROR','FATAL');
  END IF;
END $$;

CREATE TABLE event_envelope (
  event_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  detected_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  tenant_id    BIGINT REFERENCES dim_tenant(tenant_id),
  resource_id  BIGINT REFERENCES dim_resource(resource_id),
  severity     severity NOT NULL,
  kind         TEXT NOT NULL,     -- anomaly/slo_violation/deploy/incident/...
  title        TEXT,
  summary      TEXT,
  labels       JSONB DEFAULT '{}'::jsonb,
  fingerprints JSONB DEFAULT '{}'::jsonb
);
CREATE INDEX idx_event_time ON event_envelope(tenant_id, detected_at DESC);

-- 注意：主键不能用表达式，改为自增 + 唯一索引（ref_pg 哈希 + ref_oo）
CREATE TABLE evidence_link (
  evidence_id BIGSERIAL PRIMARY KEY,
  event_id    UUID NOT NULL REFERENCES event_envelope(event_id) ON DELETE CASCADE,
  dim         TEXT NOT NULL,  -- metric/log/trace/topo/kb
  ref_pg      JSONB,          -- {"table":"...","keys":{...}}
  ref_oo      BIGINT REFERENCES oo_locator(id),
  note        TEXT,
  ref_pg_hash TEXT GENERATED ALWAYS AS (md5(coalesce(ref_pg::text, ''))) STORED
);
CREATE UNIQUE INDEX ux_evidence_unique
  ON evidence_link(event_id, dim, ref_pg_hash, coalesce(ref_oo, 0));
CREATE INDEX idx_evidence_event ON evidence_link(event_id);

-- AGE 图：初始化（一次）
SELECT * FROM create_graph('ops');
SELECT * FROM create_vlabel('ops', 'Resource');
SELECT * FROM create_elabel('ops', 'CALLS');
```

---

## 附录 B：AGE 活跃调用图刷新（示例）

```sql
WITH active AS (
  SELECT tenant_id, src_resource_id, dst_resource_id,
         max(bucket) AS last_seen,
         avg(rps) AS rps, avg(err_rate) AS err_rate, avg(p95_ms) AS p95_ms
  FROM service_call_5m
  WHERE bucket >= now() - interval '10 minutes'
  GROUP BY 1,2,3
)
SELECT * FROM cypher('ops', $$
  UNWIND $rows AS row
  MERGE (s:Resource {tenant_id: row.tenant_id, resource_id: row.src})
  MERGE (d:Resource {tenant_id: row.tenant_id, resource_id: row.dst})
  MERGE (s)-[e:CALLS]->(d)
  ON CREATE SET e.first_seen = row.last_seen
  SET e.last_seen = row.last_seen, e.rps = row.rps, e.err_rate = row.err_rate, e.p95 = row.p95
  RETURN 1
$$) AS (ok int)
PARAMS (rows := (
  SELECT json_agg(json_build_object(
    'tenant_id', tenant_id, 'src', src_resource_id, 'dst', dst_resource_id,
    'last_seen', last_seen, 'rps', rps, 'err_rate', err_rate, 'p95', p95_ms))
  FROM active));
```

---

## 收尾

这套「OO 扛明细 + PG 扛治理」的极简方案能把近线排障、影响面分析与知识复用串成闭环：

- **快**：常用分析直接命中 1m/5m 聚合与 AGE 图；
- **省**：明细留 OO，对象存生命周期策略友好；
- **稳**：PG 只承载“可解释的摘要与证据”，长期演进不怕重构。