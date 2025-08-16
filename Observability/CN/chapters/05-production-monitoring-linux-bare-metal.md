# 生产级监控配置方案（Linux 裸机）

## 1. 目标
- 系统级指标（CPU/MEM/Load/磁盘/网卡） → **node_exporter**
- 进程级指标（nginx/redis/postgres/xcontrol-server 等） → **process-exporter**
- 本地历史保底（即使 Prometheus 挂掉也能事后回放） → **atop + sysstat**
- 安全/加固：统一安装目录、专用用户、systemd 管理、端口限制、日志留存策略

## 2. 目录 & 用户规划
```
# 安装目录
/opt/metrics-agent/
  ├─ node_exporter
  ├─ process_exporter
  └─ process_exporter.yml

# 日志目录
/var/log/atop/
/var/log/sysstat/

# 专用用户
useradd --system --no-create-home --shell /usr/sbin/nologin metrics
```

## 3. Node Exporter（系统级）
### 安装
```bash
cd /opt/metrics-agent
curl -L https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz \
  | tar xz --strip-components=1 -C /opt/metrics-agent --wildcards '*/node_exporter'
```

### systemd 单元 `/etc/systemd/system/node-exporter.service`
```ini
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=metrics
Group=metrics
ExecStart=/opt/metrics-agent/node_exporter \
  --web.listen-address=127.0.0.1:9100 \
  --collector.processes \
  --collector.filesystem.ignored-mount-points="^/(sys|proc|dev|run|var/lib/docker/.+)($|/)"
Restart=always

[Install]
WantedBy=multi-user.target
```
> 绑定 127.0.0.1，避免直接暴露公网，建议 Prometheus 通过内网采集或加反代。

## 4. Process Exporter（进程级）
### 安装
```bash
cd /opt/metrics-agent
curl -L https://github.com/ncabatoff/process-exporter/releases/download/v0.7.10/process-exporter-0.7.10.linux-amd64.tar.gz \
  | tar xz --strip-components=1 -C /opt/metrics-agent --wildcards '*/process-exporter'
```

### 配置文件 `/opt/metrics-agent/process_exporter.yml`
```yaml
process_names:
  - name: "nginx"
    exe: ["^/usr/local/openresty/nginx/sbin/nginx$"]
    comm: ["^nginx$"]
    cmdline: ["nginx"]

  - name: "redis"
    exe: [".*/redis-server$"]
    comm: ["^redis-server$"]
    cmdline: ["redis-server"]

  - name: "postgres"
    exe: [".*/postgres$", ".*/postmaster$"]
    comm: ["^postgres$", "^postmaster$"]
    cmdline: ["postgres", "postmaster"]

  - name: "xcontrol-server"
    exe: ["^/usr/bin/xcontrol-server$"]
    comm: ["^xcontrol-server$"]
    cmdline: ["xcontrol-server"]

  - name: "other"
    cmdline: [".+"]
```

### systemd 单元 `/etc/systemd/system/process-exporter.service`
```ini
[Unit]
Description=Prometheus Process Exporter
After=network.target

[Service]
User=metrics
Group=metrics
ExecStart=/opt/metrics-agent/process-exporter \
  --config.path=/opt/metrics-agent/process_exporter.yml \
  --web.listen-address=127.0.0.1:9256
Restart=always

[Install]
WantedBy=multi-user.target
```

## 5. 本地保底（atop + sysstat）
```bash
apt-get update
apt-get install -y atop sysstat

# sysstat: 每分钟采样，保留30天
sed -ri 's/^ENABLED=.*/ENABLED="true"/' /etc/default/sysstat
sed -ri 's/^HISTORY=.*/HISTORY=30/' /etc/default/sysstat
echo '* * * * * root sa1 60 1' > /etc/cron.d/sysstat
systemctl enable --now sysstat

# atop: 每分钟采样，保留30天
sed -ri 's/^LOGINTERVAL=.*/LOGINTERVAL=60/' /etc/default/atop || true
sed -ri 's/^LOGGENERATIONS=.*/LOGGENERATIONS=30/' /etc/default/atop || true
systemctl enable --now atop
```
回放命令
```bash
atop -r /var/log/atop/atop_$(date +%Y%m%d)
sar -u -f /var/log/sysstat/sa16   # 16日的CPU历史
```

## 6. Prometheus 抓取配置
```yaml
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['<vm-ip>:9100']

  - job_name: 'process'
    static_configs:
      - targets: ['<vm-ip>:9256']
```

## 7. Grafana 面板
- 系统总览：CPU、MEM、Load、磁盘、网络 → node_exporter
- 进程分组：nginx/redis/postgres/xcontrol-server CPU/MEM/IO → process-exporter
- 告警规则：
  - 系统 CPU > 80% 且持续 5m
  - 内存可用 < 15%
  - 单进程组 CPU > 50% 且 Load 高
  - 磁盘 IO > 80% 饿和度

## 8. 加固要点
- 安全：exporter 绑定 127.0.0.1，Prometheus 从内网/隧道采集；外网暴露必须加 Nginx 反代 + BasicAuth/TLS
- 资源开销：node_exporter / process-exporter 常驻 <50MB 内存，CPU 几乎 0
- atop/sysstat 采样瞬时 <2% CPU，月日志 <200MB
- 高可用：Prometheus 可加远程存储（Thanos/VM）做持久化，atop+sysstat 本地兜底
- 分组精简：process-exporter 只分关键服务，避免标签爆炸

✅ 最终效果：
- 在线：Prometheus + Grafana → 时序趋势 & 告警
- 离线/断联：atop/sysstat → 回放事后诊断
- 可扩展：如需应用级指标，可加 redis_exporter、postgres_exporter、nginx-lua-prometheus
