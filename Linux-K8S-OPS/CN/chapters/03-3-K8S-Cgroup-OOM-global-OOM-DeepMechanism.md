Linux / K8S 容器：Cgroup 与 OOM 深层

## 他们想查什么

从操作系统到Kubelet这条链的机理理解：谁在限制、谁在驱逐、谁在杀
你是否能定位一次真实 OOM（是容器 cgroup OOM 还是内核全局 OOM）

## 关键知识点（cgroup v2 视角）

- 限制：memory.max（硬上限）、memory.high（软限/节流）、memory.swap.max
- 计量：memory.current、memory.events、memory.stat（包含 workingset、anon、file）
- 杀进程：超 memory.max → cgroup OOM；系统整体内存紧张 → global OOM killer
- K8S QoS：Guaranteed（requests=limits）、Burstable、BestEffort
- EvictionManager（驱逐管理）：基于 cgroup/fs 信号（如 Pressure/Nodefs/Imagefs）与 --eviction-hard/--eviction-soft

为何“我明明没到limit却被杀”：page cache 回收受限、内核不可回收、内存碎片、numa 失衡、容器外内存（如 overlayfs 元数据）、JIT/hugepage

排查路径（你可以直接“背诵”）

- Pod OOM？看 Pod lastState.terminated.reason=OOMKilled 与容器 exit code 137/137
- Node OOM？dmesg -T | grep -i oom、journalctl -k
- cgroup 指标：/sys/fs/cgroup/<pod>/memory.current, memory.max, memory.events
- kubelet 驱逐：journalctl -u kubelet | grep -i eviction；描述 Node Conditions/Allocatable

旁证：pressure stall information(PSI): /proc/pressure/memory；free -h；slabtop；numactl --hardware

示例作答框架

- “我会先区分是 cgroup OOM 还是 global OOM。
- 若是 Pod 被杀，检查容器 OOMKilled、memory.current 与 memory.max 的关系；
- 若是节点全局 OOM，看 dmesg 的 oom-killer 记录与 PSI。
- 在 K8S 层，结合 QoS、requests/limits、eviction-hard，以及 imagefs/nodefs 压力。

最后给出缓解：requests≈真实峰值、limits 留余量、NUMA 绑核、GC/堆上限与 off-heap 审计、关闭不必要的内核特性或优化 page cache 命中。”


# 两类杀”—cgroup OOM vs global OOM—从 K8S → 容器运行时/ cgroup → Linux 内核 整条链路捋清：谁在限制、谁在触发、谁在动手杀，以及各层可优化点与实操命令。

1）一张责任梯子：从上到下谁说了算
K8S 层（策略/驱逐）
└─ Kubelet EvictionManager：发现节点资源告急 → 驱逐 Pod（不杀进程，优雅终止）

容器运行时 & cgroup 层（硬规则/记账）
└─ cgroup v2 memory.max / memory.high / memory.swap.max：超过硬上限 → 触发 cgroup OOM

Linux 内核层（全局稀缺时最后的刀）
└─ Page allocator / Reclaim / OOM killer：系统整体内存不够 → 触发 global OOM，kill“最该死”的进程


驱逐（evict）：Kubelet 的行为，让 Pod 下线（删除/终止容器），为节点“止血”，不是内核 OOM。
杀（kill）：内核行为。分两类：

cgroup OOM kill：某个 cgroup 超了自己的硬上限 → 只杀这个 cgroup 里的进程。
global OOM kill：全系统都不够内存 → 在全局进程里挑受害者下手。

# 2）cgroup OOM：谁限制、何时触发、谁杀谁谁在限制？

- 限制器：cgroup v2 的 memory.max（硬上限）、memory.high（软限）、memory.swap.max。
- 记账对象：该 cgroup 中进程的匿名页（anon）、文件页缓存（file cache）、slab 等。

触发路径（简化事件流）

- 进程在 cgroup 内进行内存分配（malloc/new、JIT、读写文件导致 page cache 生长）。

memcg 记账发现新分配将超出 memory.max。
memcg 尝试回收（优先文件页、再 anon），回收失败则触发 memcg OOM。
memcg OOM 选择并发送 SIGKILL 给该 cgroup 内的进程（通常是“最消耗/最适合牺牲”的进程）。
Kubelet 观察到容器退出码 137 / OOMKilled，把 Pod 标记为 OOMKilled。

谁来杀？

内核的 memcg OOM 路径执行杀伤；只影响此 cgroup，不会波及其他 Pod。

旁观证据

/sys/fs/cgroup/<pod>/memory.events 中 oom/oom_kill 计数增长
/sys/fs/cgroup/<pod>/memory.current 接近或等于 memory.max

Pod 状态：lastState.terminated.reason=OOMKilled，容器退出码多为 137

memory.high 是什么？

软限：不直接杀，节流（throttling）。进程被“阻滞”，吞吐下降、延迟上升。

memory.events 会出现 high 增长，提示你处于“高压但未死”的早期预警区。

3）global OOM：谁限制、如何触发、谁杀谁
谁在限制？

整个系统可用内存受 页分配器与水位线（zone watermarks）、vm.min_free_kbytes、NUMA 可用量等约束。

kswapd / direct reclaim 负责回收；回收无效则系统“判死刑”。

触发路径（简化事件流）

全局内存紧张，页分配失败；kswapd 回收 & direct reclaim 也救不回来（文件页、slab、匿名页都回不动）。

内核进入 out_of_memory() 流程，计算各进程 oom_score（badness）。
选择分最高的受害者（可受 oom_score_adj 影响）→ global OOM killer 发 SIGKILL。
dmesg / journalctl -k 出现详细 OOM 日志（列出受害者、RSS、cpuset/numa 等）。

谁来杀？

内核 OOM killer（全局）。可能杀的是你的容器进程，也可能是宿主守护进程（危险）。

旁观证据

dmesg -T | grep -i oom 有“out of memory: kill process …”的记录
/proc/pressure/memory 的 some/full 明显升高（PSI 指标）

节点整体症状：SSH 卡顿、kubelet 自身重启、多个 Pod 被“无差别”影响

4）K8S 与这两类“杀”的边界

Kubelet EvictionManager（只驱逐，不杀）

监控节点维度信号：memory.available、nodefs/imagefs 可用量、inodes 等。
达到 --eviction-hard/soft 阈值 → 挑选优先级低/ QoS 差的 Pod 驱逐，为节点保命。
驱逐 ≠ OOM：驱逐是“体面退场”；OOM 是“内核开枪”。

QoS 与被“动刀”的顺序

Guaranteed（requests=limits）最不容易被驱逐/抢占。
BestEffort 最先被驱逐。

但 cgroup OOM 与 global OOM 不看 QoS，它们看真实用量与可回收性。

5）“为什么我没到 limit 也死/也被逐？”常见真实原因

kubelet 驱逐与 limit 是两个维度：驱逐看节点 memory.available，limit 看容器 cgroup；节点紧张时，即使你的容器没到 limit，也会被驱逐。

容器外内存吃光了节点：overlayfs 元数据、containerd shim、其他 Pod、宿主机守护进程。

page cache 回收困难：热点文件/日志刷写大，cache 压不下；你以为“不是我的内存”，但它照样占节点内存。

NUMA 失衡/内存碎片：总量看着够，局部可用少，导致分配失败。

语言 runtime 外的内存：JVM DirectBuffer、Go runtime arena、Python/本地库 C 侧分配，不受堆参数管控。

透明大页（THP）/ HugePage：造成回收困难与延迟抖动。

6）优化与治理：分层打法（从上到下）
A. K8S 层（策略与容量）

Requests ≈ 95/99 分位真实峰值；Limits 预留 20–40% 头寸（语言/场景不同可微调）。

合理使用 QoS：关键链路用 Guaranteed；把“波动大”的组件拆 Pod。

调整 Eviction：--eviction-hard/soft，确保为系统/kubelet/containerd 预留足够空间（kube-reserved/system-reserved）。

存储分离：imagefs 与 nodefs 分盘，避免 inode/nodefs 压力把你驱逐。

自动化容量：VPA/Goldilocks 给建议、CA 自动扩容。

B. cgroup / 容器运行时层（硬规则）

明确 memory.max 与 memory.high：先用 high 当早期刹车，观测 memory.events:high。

swap 策略：默认禁用；若开启受控 swap，务必设 memory.swap.max 并评估延迟。

导出 memcg 指标：memory.current / max / events / stat + PSI 到监控（Prometheus/node-exporter 文档目录）。

C. Linux 内核层（内存管理卫生）

PSI 监控：把 /proc/pressure/memory 纳入告警（some/full 在 60s/300s 窗口）。

THP 策略：对延迟敏感场景常设为 never，或仅对可受益的工作负载局部开启 HugePages（显式）。

NUMA 感知：启用 K8S Memory/CPU Manager，尽量单 NUMA 放置；检查 numastat。

碎片/回收：观察 slabtop、/proc/buddyinfo；异常 slab 增长需定位内核/驱动/文件系统行为。

D. 应用/语言层（最能见效）

JVM：-Xmx 与 -XX:MaxDirectMemorySize 显式设置；G1/ZGC；NMT 观测 off-heap。

Go：使用 GOMEMLIMIT（Go1.19+），定期 pprof；减少大对象逃逸，池化复用。

Python：prefork 多进程 + worker 内存上限 + 周期性滚动重启，避免碎片囤积。

IO/缓存：尽量顺序写、批量写；日志切分与压缩策略；避免将“热数据”不必要地驻留 page cache。

7）实操排查脚本（当场能敲）
# 1) Pod 视角：是否 cgroup OOM
kubectl describe pod <pod> | egrep -i 'OOMKilled|Evicted|Reason'

# 定位到容器 cgroup（containerd 示例）
cid=$(crictl ps | grep <pod-name> | awk '{print $1}' | head -1)
crictl inspect $cid | jq -r '.[0].info.runtimeSpec.linux.cgroupsPath'

# 读 memcg 证据
cd /sys/fs/cgroup/<that-cgroup>/
cat memory.current memory.max
cat memory.events         # 看 oom/oom_kill/high 是否增长
egrep 'anon|file|slab|workingset' memory.stat

# 2) 节点视角：是否 global OOM 或驱逐
dmesg -T | grep -i oom | tail -n 50     # 有全局 OOM 日志就是 global OOM
journalctl -u kubelet | grep -i eviction
cat /proc/pressure/memory               # PSI some/full
slabtop -o | head
numastat

8）60 秒“口试版”串讲（面试可直接说）

“内存问题我先区分三层：Kubelet 驱逐、cgroup OOM、global OOM。
Kubelet 看到节点 memory.available 下降会驱逐 Pod以保节点；这不杀进程，是策略层。
如果某 Pod 的 cgroup memory.max 被打爆，memcg 回收失败就触发 cgroup OOM，只杀该 cgroup 内的进程；证据是 memory.events 的 oom/oom_kill 增长、容器 OOMKilled、退出码 137。
若节点整体回收失败，内核进入 global OOM killer，依据 oom_score 在全局选受害者并 kill；dmesg 会有详细日志。
治疗上层次推进：调整 requests/limits 和 QoS、设置 eviction 阈值与系统预留；导出 memcg/PSI 指标；在内核侧管理 THP/NUMA/碎片；在语言侧收紧堆与 off-heap。这样可把绝大多数 OOM 从‘全局灾难’降级为‘局部可控’。”
