## 🧰 二面（Automation / DevOps / Architecture Design）

**目标：** 评估自动化体系与可观测性设计能力。

### 🧩 题目 1：Ansible 自动化
**Q:** 如何批量推送配置并验证结果？

**A:** 通过 playbook + roles：
```yaml
- hosts: all
  tasks:
    - copy: src=ntp.conf dest=/etc/ntp.conf
    - service: name=ntpd state=restarted
```
执行 `--check` 验证，使用 `ansible all -a` 复查状态。

---

### 🧩 题目 2：CI/CD Pipeline
**Q:** 如何设计高可用 CI/CD？

**A:** 采用 GitOps 模式：
- 工具：GitHub Actions + ArgoCD + Helm；
- 策略：Blue-Green / Canary 部署；
- 可追溯：版本控制 + 自动回滚。

---

### 🧩 题目 3：Observability Stack
**Q:** 如何构建全栈可观测性？

**A:**
- Metrics: Prometheus + exporters；
- Logs: Loki / ELK；
- Traces: Tempo / Jaeger；
- Dashboard: Grafana；
- 告警：AlertManager + webhook。

---

### 🧩 题目 4：系统架构题
**Q:** 设计全球工厂混合云（AWS + On-Prem）Linux 运维架构。

**A:**
- IaC：Terraform + Ansible；
- CI/CD：GitHub Actions + ArgoCD；
- Observability：Prometheus + Grafana + Loki；
- Security：Vault + IAM + MFA；
- HA：Region Failover + Global DNS；
- Incident：PagerDuty + AlertManager。

---

## 🌍 三面（Behavioral / Ownership / System Thinking）

**目标：** 评估责任心、沟通协作与系统思维。

### 💬 题目 1：Incident Handling
**Q:** 请分享一次你处理重大生产故障的经历。

**A（STAR 模型）：**
- **S:** 数据库连接中断影响业务。
- **T:** 负责快速恢复生产。
- **A:** 立即隔离节点、回滚配置、修复健康检查逻辑。
- **R:** 15 分钟恢复，撰写 Postmortem，总结改进措施。

---

### 💬 题目 2：Ownership
**Q:** “You build it, you run it” 对你意味着什么？

**A:** 工程师需全程负责系统生命周期，从开发到上线及稳定运行，对 **可用性、安全性与可靠性** 负完全责任。

---

### 💬 题目 3：Collaboration
**Q:** 团队出现技术分歧时如何处理？

**A:** 基于数据和实验验证，优先进行小规模试点；保持异步沟通（RFC、Slack），聚焦问题本身而非立场。

---

### 💬 题目 4：Reliability Metrics
**Q:** 如何定义和改进系统可靠性？

**A:**
- 制定 SLO/SLI：uptime、latency、error rate；
- 跟踪 MTTR/MTBF 指标；
- 实施 post-incident review；
- 自动化 runbook 降低人为失误。

---

## ✅ 重点复习领域

| 模块 | 工具与知识点 |
|------|---------------|
| **Linux 核心** | systemd · strace · perf · iostat · vmstat · netstat |
| **自动化工具** | Ansible · Terraform · Jenkins · GitHub Actions |
| **容器平台** | Kubernetes · Helm · ArgoCD |
| **监控与日志** | Prometheus · Grafana · DeepFlow · Datadog · AlertManager |
| **安全与网络** | SELinux · iptables · TLS · PKI · SSH Hardening |
| **Incident 响应** | SLO/SLI · Root Cause Analysis · Postmortem Review |
| **沟通表达** | STAR 模型 · 英文技术表达 · Global team collaboration |

---

📘 **建议：**
- 每个模块准备 2~3 个具体案例（包含指标、结果、改进）。
- 练习英文表达简洁流畅，强调 impact 与 ownership。
- 对比 JD 中的关键词（Linux / Automation / Reliability / Observability），确保面试回答覆盖。


# Sr. System Engineer (Linux) — 二/三面模拟对话脚本（可直接演练）

> 用法：两人对练（面试官 I / 候选人 C）。每题含：标准问法 → 追问分支 → 优秀回答要点（中英要点）→ 常见踩坑/红旗 → 可量化指标与落地命令。可按岗位 JD（Linux/Automation/Reliability/Observability）挑选模块。

---

## 🧰 二面（Automation / DevOps / Architecture Design）
**目标：** 验证自动化体系、交付可靠性、可观测与混合云架构设计能力。

### 2.1 Ansible 自动化（配置分发 & 幂等验证）
**I（开场）**：团队需要在 300 台主机上下发 `chrony.conf` 并验证生效，同时避免抖动。你会怎么做？

**C（优秀作答骨架）**：
- **结构**：Inventory 分组（生产/灰度）→ Roles（template/handler/notify）→ `serial` 渐进 → `check_mode` 预演 → `assert` 校验。
- **要点**：
  - 幂等：`template` + Jinja2 渲染 → 变更触发 `notify: restart chronyd`；
  - **渐进发布**：`serial: 10` + `max_fail_percentage: 10`；
  - **验收**：`shell: chronyc sources` + `changed_when`/`failed_when`；
  - **回滚**：以版本化模版（git tag）+ `block/rescue/always`；
  - **审计**：`--diff --check` 先行，`callback_whitelist=json` 产出执行证据。

**I（追问 1）**：如何在执行前做“配置漂移检测”？
- **C**：`setup` facts + `slurp` 现网文件 → `assert`/`diff`；也可接入 `ansible-lint` & `policy as code`（如 Conftest/OPA）。

**I（追问 2）**：如何避免 SSH 扇出导致控制端瓶颈？
- **C**：合理设置 `forks`；利用 **Pipelining**；大规模时改用 **AWX/Ansible Controller**，或对只读任务切换到 **Salt/Simple SSH fanout**；重复下发内容放 CDN/对象存储，主机上仅拉取 Hash 变更。

**示例 Playbook 片段**：
```yaml
- hosts: prod
  serial: 10
  max_fail_percentage: 10
  vars:
    ntp_servers: ["time.aws.com","ntp.aliyun.com"]
  tasks:
    - name: Render chrony
      template:
        src: chrony.conf.j2
        dest: /etc/chrony.conf
        owner: root
        group: root
        mode: '0644'
      notify: restart chronyd
    - name: Validate NTP
      command: chronyc tracking
      register: out
      changed_when: false
      failed_when: out.rc != 0 or (out.stdout is search('Not synchronised'))
  handlers:
    - name: restart chronyd
      service: { name: chronyd, state: restarted }
```
**英述关键句**：
> *“I’d roll out with `serial` batches, use `--check --diff` for a dry run, and add assertions to verify `chronyc tracking` shows `synchronised`. Handlers ensure idempotence and controlled restarts.”*

**红旗**：无 `serial/handler/assert`；直接 `copy` 破坏幂等；缺少验证与回滚。

---

### 2.2 CI/CD（GitOps + 回滚设计）
**I**：我们使用 GitHub Actions + Argo CD。如何设计 **可回滚** 的交付流程并缩短 MTTR？

**C（骨架）**：
- **三库拆分**：`app`（源码）/`manifest`（声明式 K8s）/`infra`（Terraform）。
- **版本与回滚**：Helm Chart + `app.kubernetes.io/version`，ArgoCD **Application** 指向带 tag 的 Git commit；失败自动 `rollback to previous healthy revision`。
- **防护**：`progressDeadlineSeconds`、`maxSurge`/`maxUnavailable`、`startupProbe`、`podDisruptionBudget`。
- **策略**：Blue-Green / Canary（Argo Rollouts）+ **分析**（PromQL/HTTP check）。
- **证据链**：PR 必经 CI（lint/tests/sbom/attestations）→ 产物签名（Sigstore/Cosign）→ Admission 控制（Policy）→ Argo 巡检。

**I（追问）**：如何处理**数据库迁移**的可回滚？
- **C**：向前兼容迁移（expand → code switch → contract）；分阶段 PR；影子读；备份/快照；`liquibase`/`prisma migrate` 带 down 脚本；读写分离限流。

**英述关键句**：
> *“We separate source and manifests, tag immutable artifacts, and let Argo track revisions. Rollbacks are one-click to a healthy commit, while database changes follow expand/contract to remain backward compatible.”*

**红旗**：手动改集群不回写 Git；镜像无不可变标签；回滚需要 SSH。

---

### 2.3 Observability（SLO/SLI + 三件套 + eBPF）
**I**：如何为入口网关设定 SLO，并用观测数据进行金丝雀判定？

**C（骨架）**：
- **SLI**：P99 延迟、成功率、可用性（error budget 消耗率）。
- **数据源**：Prometheus 指标（`histogram: request_duration_seconds`）、Loki 日志抽取错误码、Tempo/Jaeger 链路分析。
- **判定**：Argo Rollouts **分析模板**，PromQL 比较新旧版本误差阈值（如 `rate(http_requests_total{status!~"2.."}[5m])`）。
- **告警**：基于 **Error Budget**（多层：服务 → 业务）而非裸阈值；抑制风暴（告警路由、抑制树、分级升级）。
- **深挖**：当 P99 升高，用 eBPF（`profile`/`tcptrace`/`runqlat`）定位 syscall/hot function。

**英述关键句**：
> *“We tie rollouts to SLOs via Argo analysis templates. If the new revision burns error budget faster, we auto-abort and roll back.”*

**红旗**：只堆叠仪表板；无 SLO 与 error budget；金丝雀靠体感。

---

### 2.4 全球工厂混合云（AWS + On‑Prem）架构设计
**I**：请给出一套面向全球工厂的混合云 Linux 运维架构，重点在 **一致性、合规与低带宽下的可用性**。

**C（骨架）**：
- **控制面**：多区域 GitOps（只出站联网），中心化 **Artifact/镜像/Helm 仓库**（区域镜像/本地缓存）。
- **网络**：SD-WAN/Cloud WAN；最小入站策略（互信通过 MTLS + SPIFFE/SPIRE）。
- **身份与密钥**：短期凭证（OIDC，IRSA/Workload Identity）+ Vault 动态密钥。
- **配置一致性**：基础镜像/OS baseline（CIS benchmark），Ansible `facts` 驱动配置差异；不可变镜像 + cloud-init。
- **断网容错**：本地 Argo agent + pull 模式；局部缓存（registry mirror，apt/yum mirror）。
- **可观测**：分层收集（边缘→区域→中心），长保留在对象存储；事件总线汇聚（Kafka/OTel Collector）。
- **演练**：灾备（区域级）+ 断链路压测；变更窗口与冻结策略。

**英述关键句**：
> *“We keep the control-plane pull-based and identity short-lived. Artifacts are mirrored regionally, and observability is tiered to cope with low bandwidth and data sovereignty.”*

**红旗**：中心依赖单点；入站管理口暴露；明文持久化密钥。

---

### 2.5 成本与容量（可选）
**I**：如何做容量规划与成本优化？
- **C**：以 SLO 为锚做负载曲线 → 离线压测（WRK/K6）+ 生产回放 → **容量模型**（QPS, P99, 并发, 队列）→ 混部与 Spot，自动关停；**存储**冷热分层；网络对等/跨区费用评估。

---

## 🌍 三面（Behavioral / Ownership / System Thinking）
**目标：** 事故处置、端到端 Owner 意识、跨团队协作、系统性改进。

### 3.1 Incident Handling（重大故障复盘）
**I**：说一次你主导的“生产事故”，你做了哪些关键决策？

**C（STAR 优秀范式）**：
- **S**：黑峰值期间 API 错误率飙升（5xx 达 12%），P99 从 350ms 升到 2.8s。
- **T**：15 分钟内恢复 <1% 错误率，保留排障证据。
- **A**：
  1) **止血**：网关限流 10%，开灰度回滚上一稳定版；
  2) **定位**：PromQL 发现单一版本 `pod` 错误集中；`rollouts abort`；
  3) **根因**：`perf + ebpf` 定位 TLS 会话复用回退触发 CPU 抖动；
  4) **长期**：引入 **分析模板** 与 **预检**；TLS 参数回归测试；容量留白 30%。
- **R**：15 分钟恢复（MTTR 15m），次日回归上线；30 天错误预算使用率下降 40%。

**英述关键句**：
> *“I separated mitigation from root-cause work, kept a clean timeline, and ensured permanent fixes were tracked with owners and deadlines.”*

**追问分支**：如何保证“证据链”？— 只读镜像保留、变更与告警快照、`kubectl get events --watch`/审计日志。

**红旗**：一上来甩锅；无回滚策略；未量化影响；无长期改进项。

---

### 3.2 Ownership（You build it, you run it）
**I**：这句话对你意味着什么？
- **C（要点）**：
  - **端到端**：从设计、容量、韧性测试到运行指标负责；
  - **可运维性优先**：可观测、Feature flag、灰度、回滚同等重要；
  - **轮值机制**：on-call runbook、错误预算驱动优先级；
  - **事后复盘**：无责文化 + 行动清单闭环。

**英述关键句**：
> *“It means designing for operability, owning on-call, and letting error budgets influence roadmap priorities.”*

**红旗**：把稳定性完全交给 SRE；只谈开发不谈运行。

---

### 3.3 Collaboration（跨团队分歧）
**I**：当后端与安全团队对 TLS 策略有分歧时如何推进？
- **C（要点）**：
  - 建立 **事实表**：现网兼容矩阵、性能数据；
  - **小流量实验**：真实流量 A/B；
  - 形成 RFC，明确 **决策人（DRI）** 与时间线；
  - 记录异议，给回滚路径与复盘点。

**英述关键句**：
> *“I de-escalate to data. We run time‑boxed experiments, document trade‑offs in an RFC, and assign a DRI for the decision.”*

**红旗**：只靠投票；缺乏实验与证据。

---

### 3.4 Reliability Metrics（如何定义并提升可靠性）
**I**：如何落地 SLO/SLI 与错误预算，并推动组织采纳？
- **C（要点）**：
  - 自上而下设目标（业务指标耦合），自下而上提供可观测数据；
  - **门禁**：新特性必须提供 SLI；
  - **阶段推进**：先灰度系统 → 再全量服务；
  - **预算管理**：超支自动降低变更频率，冻结大变更；
  - **公开看板**：减少“感觉驱动”。

**英述关键句**：
> *“Error budgets create an objective trade‑off between velocity and reliability. When we overspend, we slow changes by policy.”*

**红旗**：将 SLO 当成阈值报警；无预算管理策略。

---

## 🎯 快速口语卡（中英要点）
- **幂等/Idempotence**："Idempotent playbooks with handlers and assertions prevent config drift and unnecessary restarts."
- **回滚/Rollback**："Roll back to a known‑good Git revision; artifacts are immutable and signed."
- **SLO/SLI**："We measure P99 latency and availability; error budgets govern rollout speed."
- **eBPF**："For hard cases, we sample kernel events to correlate syscall latency with user‑space code paths."

---

## 🧪 面试现场演练脚本（计时版）
- **5 分钟**：快速白板画 CI/CD 与回滚 → 说出 3 个关键门禁（测试、签名、策略）。
- **8 分钟**：按照模板给出一次 Incident STAR 复盘（含指标）。
- **7 分钟**：Ansible 渐进发布 + 验证 + 回滚小样（口述或伪代码）。

---

## ✅ 评分 Rubric（面试官参考）
| 维度 | 1 分 | 3 分 | 5 分 |
|---|---|---|---|
| 自动化/幂等 | 只会脚本 | 会 roles/handlers | 幂等+渐进+验证+回滚闭环 |
| 交付/回滚 | 手工改生产 | 基本 CI/CD | GitOps、版本化、自动回滚、数据库兼容迁移 |
| 可观测/SLO | 会做图表 | 基本告警 | 以 SLO/预算驱动、指标闭环到发布策略 |
| 事故处置 | 情绪化 | 能回滚 | 止血-定位-根因-改进有证据链 |
| 沟通/协作 | 争执 | 折中 | 数据驱动、RFC、DRI、时间盒 |

---

> 如需，我可以继续补充“英文全量对话脚本版本”、或针对贵司栈（例如 RHEL/Ansible/AWS + EKS + Argo Rollouts/Service Mesh）生成专属题库与演练清单。
