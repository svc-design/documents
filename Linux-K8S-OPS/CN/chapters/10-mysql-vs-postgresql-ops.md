# MySQL vs PostgreSQL 资源占用与维护脚本对比

下面只聚焦两点：资源占用 & 维护脚本/可运维性，给出 MySQL vs PostgreSQL 的实战对比与脚本要点。

## 一、资源占用（内存/CPU/IO/连接）

| 维度 | MySQL（以 InnoDB 为主） | PostgreSQL |
| --- | --- | --- |
| **基础内存** | 主要由 `innodb_buffer_pool_size` 决定，单一“大池”更好估算；低配机器上可控性好 | 由 `shared_buffers`、`work_mem`（每会话/每排序）、`maintenance_work_mem`、`effective_cache_size` 等组成，参数更多、场景化调优空间更大 |
| **连接模型** | 传统“一连接一线程”（8.x 支持线程池特性但社区版常见为单线程）；高并发下线程切换成本上升，可上 线程池 | 一连接一进程；大量连接时进程数多、内存开销更高。建议配 PgBouncer（事务池/会话池）做连接复用 |
| **查询内存** | 多数操作走 buffer pool；复杂查询的临时空间由 `tmp_table_size`/`max_heap_table_size` 等 | 每个排序/哈希操作消耗 `work_mem`（可能多次叠加）。`work_mem` 设过大易爆内存；建议按并行数×复杂度核算 |
| **写放大/IO** | InnoDB 双写缓冲 + redo/undo，写放大适中；自增主键写入顺序友好 | WAL 顺序写，配合 `full_page_writes`；大量 UPDATE/DELETE 产生 行版本（MVCC），需要 autovacuum 清理，写放大高峰期出现在清理与重建索引 |
| **磁盘占用** | 表+索引集中在表空间，碎片通常通过 `OPTIMIZE TABLE`/`ALTER TABLE…` 处理 | MVCC 造成膨胀，需 autovacuum 与周期性 `VACUUM (FULL)`/`REINDEX`；合理 autovacuum 参数可控 |
| **复制开销** | Binlog（row-based 常用），网络占用与写流量线性相关；只读从库内存较少 | WAL 物理复制；逻辑复制需解码；从库也需 autovacuum。物理复制高效、稳定 |
| **JSON/全文检索** | JSON 功能进步很大，内存占用相对可控；全文检索常交给外部（ES等） | JSONB/全文检索能力强，但建索引（GIN/GiST）会显著增加内存/磁盘与 autovacuum 压力 |

**简评**

- 轻量/低内存/少参数 → MySQL 更容易“开箱即用”。
- 复杂查询/强索引/向量/全文/函数化 → PG 更强，但需要更严格的内存与 autovacuum 规划。
- 连接很多 → 两者都建议前置连接池：MySQL 线程池 / PG PgBouncer。

## 二、维护脚本与可运维性（备份/迁移/例行任务）

### 1) 备份与恢复

#### MySQL

- **逻辑**：`mysqldump`（轻量、通用；大库慢）
- **物理**：`xtrabackup`（热备、增量、速度快；推荐生产）
- **PITR**：全量备份 + binlog（易理解，脚本体系成熟）

**一键示例**

```bash
# 全量
mysqldump --single-transaction --routines --triggers -u root -p mydb | gzip > mydb_$(date +%F).sql.gz
# xtrabackup
xtrabackup --backup --target-dir=/backup/full_$(date +%F)
```

#### PostgreSQL

- **逻辑**：`pg_dump`（可并行 -Fd 格式 + `pg_restore -j`）
- **物理**：`pg_basebackup`（热备，结合归档 WAL）
- **PITR**：全量备份 + WAL 归档（更严谨；脚本略复杂）

**一键示例**

```bash
# 并行目录格式
pg_dump -Fd -j 4 -U app -d mydb -f dumpdir/
pg_restore -j 4 -U app -d mydb dumpdir/
```

**对比**

- 快速增量物理备份：MySQL 倾向 xtrabackup；PG 用 `pg_basebackup + WAL` 也很稳。
- 异机构/跨版本迁移：两者逻辑备份都好用；PG 的 `pg_dump/pg_restore` 并行更友好。

### 2) 复制与切换

#### MySQL

- 原生异步复制（半同步可选）；MGR/Galera 进一步 HA。
- 脚本生态成熟：`CHANGE MASTER TO…` 一套拉起；管理工具多。

#### PostgreSQL

- 物理流复制 + `recovery.conf`（PG12+ 为 `standby.signal`）；`pg_rewind` 切换回主从。
- 逻辑复制（发布/订阅）方便数据子集或跨版本迁移。
- 常用运维：`repmgr`、`patroni` 自动故障转移。

**对比**

- 快速上手：MySQL 更“少脚本立即可用”。
- 复杂拓扑/部分表同步/跨版本：PG 逻辑复制优势明显。

### 3) 例行维护（autovacuum / 清理 / 优化）

#### MySQL（InnoDB）

- 常见脚本：`ANALYZE TABLE`、`OPTIMIZE TABLE`、定期 `pt-online-schema-change` 在线 DDL。
- 只要 buffer pool 规划得当，常规维护脚本较少。

#### PostgreSQL

- autovacuum 是重头：需根据表写入频率调整 `autovacuum_vacuum_cost_limit`、`autovacuum_vacuum_scale_factor`、`autovacuum_analyze_scale_factor`、`max_worker` 等；避免膨胀与冻结表风险。
- 大型表推荐：分区、`VACUUM (FULL)` 的维护窗口、`REINDEX CONCURRENTLY`。
- 在线 DDL：多数支持 `CONCURRENTLY`（建索引/重建索引），脚本要留意 LOCK 风险。

**对比**

- 运维脚本复杂度：PG 明显更高，但换来的是更丰富的索引与查询能力。
- 在线变更：两个都有成熟方案；PG 原生 `CONCURRENTLY` 很香，MySQL 用 `pt-osc` 更稳。

### 4) 监控与告警

- **MySQL**：`performance_schema`、`information_schema`、`SHOW ENGINE INNODB STATUS`，加上 Percona 工具链，脚本直接抓指标很方便。
- **PG**：`pg_stat_statements`、`pg_stat_activity`、`pg_stat_all_tables/...`，指标维度更细，脚本需要做汇总聚合；建议配合 `auto_explain`、`pgBadger`。

## 三、脚本模板（可直接用/改）

### MySQL：全量 + binlog 清理

```bash
#!/usr/bin/env bash
set -euo pipefail
DAY=$(date +%F)
mysqldump --single-transaction --routines --triggers -u root -pSECRET mydb \
  | gzip > /backup/mydb_${DAY}.sql.gz
# 清理7天前
find /backup -name "mydb_*.sql.gz" -mtime +7 -delete
# binlog 轮转（示例）
mysql -uroot -pSECRET -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY)"
```

### PostgreSQL：并行逻辑备份 + WAL 轮转

```bash
#!/usr/bin/env bash
set -euo pipefail
DAY=$(date +%F)
OUT=/backup/dump_${DAY}
pg_dump -Fd -j 4 -U app -d mydb -f "${OUT}"
tar czf "${OUT}.tar.gz" -C /backup "dump_${DAY}"
rm -rf "${OUT}"
# 可结合 WAL 归档目录做清理（示意）
find /pgwal/archive -type f -mtime +7 -delete
```

### PostgreSQL：拉起物理从库

```bash
#!/usr/bin/env bash
set -euo pipefail
systemctl stop postgresql
rm -rf /var/lib/postgresql/14/main/*
pg_basebackup -h MASTER_HOST -U repl -D /var/lib/postgresql/14/main -R -P
systemctl start postgresql
```

## 选择建议（按最常见需求）

- 低内存、轻量部署、对 SQL 功能要求一般 → MySQL（InnoDB）更省心，脚本简单、备份工具成熟。
- 复杂查询、多索引类型、JSONB/全文/向量检索、强一致语义 → PostgreSQL，但要接受 autovacuum 与内存参数 的学习成本，配好 PgBouncer。
- 跨版本/异构迁移频繁 → 两者逻辑备份都可；PG 的 发布/订阅（逻辑复制）会更灵活。
- 高并发短连接 → 两者都加连接池：MySQL 线程池 / PG PgBouncer（事务池模式）。
