# Grafana 12 Git Sync + Provisioning 设计

本文档描述了 Grafana 12 的 GitOps 实践：Grafana Git Sync → 本地 Git 同步 → 经典 Provisioning。
目标是将编辑入口统一到 Git（或受控 UI），运行入口统一到 Provisioning 的本地目录，同时避免回环与冲突。

## 目标与原则

- 唯一事实源：Git 仓库（dashboards、datasources、告警）。
- 生产只读：生产环境用 Provisioning 从本地目录加载，禁止 UI 改动。
- 自动同步：systemd 定时 git pull（离线友好）；预发/演示可启用 Git Sync 双向同步。
- 分环境隔离：不同环境分目录或分分支，生产锁定 main。
- 安全与审计：密钥不写死到 JSON/YAML，使用环境变量或加密文件（如 sops）。

## 架构与优先级

```
[编辑入口]            [事实源]             [运行入口]
Grafana UI  ──Git Sync──▶  Git Repo  ──git pull──▶  Local FS  ──Provisioning──▶ Grafana Runtime
     ↑                                    ▲
 (只在预发允许)                      （定时同步）
```

- **Git Sync**：最高优先——预发环境可在 UI 编辑并推回 Git。
- **本地 Git 同步**：中间层——定时将仓库内容拉取到磁盘路径。
- **经典 Provisioning**：最低层——Grafana 只读地从磁盘载入，决定线上最终渲染内容。

## Git 仓库结构（推荐）

```
grafana-as-code/
├─ dashboards/
│  ├─ _folders.yaml              # （可选）声明文件夹结构
│  ├─ infra/
│  │  ├─ linux-node-proc-groups.json
│  │  └─ network-overview.json
│  └─ app/
│     └─ xcontrol-service.json
├─ datasources/
│  └─ prometheus-ds.yaml
├─ alerts/
│  └─ rules.yaml
└─ env/
   ├─ prod/overrides.yaml        # （可选）按环境覆盖
   └─ stage/overrides.yaml
```

- 简单起步可只用 `dashboards/` + `datasources/` 两个目录。
- `_folders.yaml` 用来把 JSON 放到对应文件夹（也可依赖“按目录生成文件夹”）。

## 生产环境：经典 Provisioning + 本地 Git 同步（强烈推荐）

### 1) 在 Grafana 主机上同步仓库（每 5 分钟）

```bash
sudo mkdir -p /srv/grafana
cd /srv/grafana
git clone --depth 1 <YOUR_GIT_URL> grafana-as-code
```

`/etc/systemd/system/grafana-dash-pull.service`

```
[Unit] Description=git pull dashboards
[Service]
Type=oneshot
WorkingDirectory=/srv/grafana/grafana-as-code
ExecStart=/usr/bin/git pull --ff-only
```

`/etc/systemd/system/grafana-dash-pull.timer`

```
[Unit] Description=git pull dashboards every 5m
[Timer]
OnBootSec=30s
OnUnitActiveSec=5m
AccuracySec=30s
[Install]
WantedBy=timers.target
```

启用：

```bash
sudo systemctl enable --now grafana-dash-pull.timer
```

拉取后 Grafana 会按 `updateIntervalSeconds` 自动扫描更新，无需重启。

### 2) 仪表盘 Provisioning

`/etc/grafana/provisioning/dashboards/dashboards.yaml`

```yaml
apiVersion: 1
providers:
  - name: 'infra-dashboards'
    type: file
    disableDeletion: false
    allowUiUpdates: false            # 生产禁改
    updateIntervalSeconds: 30
    options:
      path: /srv/grafana/grafana-as-code/dashboards
      foldersFromFilesStructure: true
```

### 3) 数据源 Provisioning（Prometheus 示例）

`/etc/grafana/provisioning/datasources/datasources.yaml`

```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: ${PROM_URL}                 # 用环境变量注入
    isDefault: true
    jsonData:
      httpMethod: GET
    secureJsonData:
      httpHeaderValue1: ${PROM_AUTH}  # 需要鉴权时使用
```

注入方式：在 Grafana 服务 unit 里导入环境变量：

`/etc/systemd/system/grafana-server.service.d/env.conf`

```
[Service]
Environment=PROM_URL=http://prometheus.lan:9090
Environment=PROM_AUTH=
```

然后：

```bash
systemctl daemon-reload && systemctl restart grafana-server
```

### 4) 禁止生产 UI 篡改（强制只读）

- 上面 `allowUiUpdates: false` 已禁止对被 Provisioning 管理的仪表盘在 UI 改动。
- 如需更严格，可在 `grafana.ini` 或组织/文件夹权限中进一步收紧。

## 预发 / 演示环境：Grafana 12 Git Sync + Provisioning

- 保留 Provisioning（结构约束与兜底）。
- 打开 Grafana → Dashboards → Git Sync，连接同一仓库的 dev/stage 分支，开启 **双向**（UI 改动会推回 Git；也可选单向拉取）。
- Provisioning 仍指向 `/srv/grafana/grafana-as-code/dashboards`。
- 面板成熟后，通过 PR 合并到 `main` 分支，生产自动拉取生效。

## 安全与审计清单（最小而实用）

- 密钥/凭据：使用环境变量或 sops 加密文件，不要写进 JSON/YAML。
- 分支保护：`main` 受保护，必须 PR 审核。
- 只读生产：`allowUiUpdates: false`；仅运维管理员有写权限。
- 变更审计：Git 记录 + 标签发布（如 `dash-v2025.08.16`），回滚使用 `git revert`。
- JSON 校验：CI 中运行 `jq` 或 `gflt` 校验语法。
- 备份：定期 `git bundle` 或镜像仓库，防误删。

## 多环境做法（任选其一）

### 分支法（推荐）

- Prod：`main` 分支，Git Sync Pull-only。
- Stage：`stage` 分支，Git Sync Two-way。
- 各环境检出对应分支，Provisioning 的 `path` 不变。

### 目录法

- 同一分支下不同目录：`dashboards/prod`、`dashboards/stage`。
- 各环境的 provider 指向各自目录，Git Sync 也配置对应路径。

### 两者结合

- 目录 + 分支，最大化隔离（大团队常用）。

## 冲突与回滚策略

- **冲突**：预发 UI 编辑同时有人向 `stage` 推送时，Git Sync 会拒绝推送，需在 Git 端解决后再同步。
- **回滚**：`git revert` 某次提交；定时器 + Provisioning 约 5 分钟内生效。

## 监控与告警（GitOps 自我健康）

- 同步失败：`grafana-dash-pull.service` 写 textfile 指标（成功=1/失败=0），Prometheus 采集并告警。
- 配置漂移：比较本地 HEAD 与远端 HEAD（`git rev-parse`），不一致超过 15 分钟告警。
- 变更审计：PR 合并时 CI 校验 JSON 语法与命名规范。

## 最小操作手册

1. **改盘**：在 `stage` 分支提交 JSON 或在 UI 编辑后通过 Git Sync 推回。
2. **验收**：预发确认无误 → 提 PR 到 `main`。
3. **上线**：合并即上线（生产 5 分钟内拉取 + 30 秒内刷新）。
4. **回滚**：`git revert` 相应提交，等待自动同步完成。

## 你可以直接复用的最小文件集

- `dashboards.yaml`（上文已有）
- `datasources.yaml`（上文已有）
- systemd timer（上文已有）
