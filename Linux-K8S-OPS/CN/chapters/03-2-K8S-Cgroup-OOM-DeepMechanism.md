# Kubernetes / Linux Memory Control & OOM 深层机制解析

# 1. 总览与目标

1.1 为什么需要理解 OOM（从“容器挂了”到“内核杀了谁”）
1.2 三层责任体系：K8S → cgroup → Linux 内核
1.3 典型表现与日志路径总览

# 2. Cgroup 内存控制原理

## 2.1 cgroup v2 架构与记账机制
memory.current / memory.max / memory.high / memory.swap.max
memory.stat / memory.events

## 2.2 内存分配路径：用户态 → 内核 → memcg

页分配、回收、直接回收、reclaim
page cache、anon、slab、workingset

## 2.3 memory.high（软限）与 memory.max（硬限）的区别

节流机制（throttling）

oom_kill 触发路径

3. cgroup OOM：容器内的局部“杀”

3.1 触发条件：超过 memory.max，回收失败

3.2 事件链：

1️⃣ 应用分配内存 →
2️⃣ memcg 检测上限 →
3️⃣ 尝试 reclaim →
4️⃣ 失败 →
5️⃣ cgroup OOM →
6️⃣ SIGKILL 本组进程

3.3 证据：memory.events（oom/oom_kill）增长

3.4 日志与验证命令

3.5 典型案例：Pod 被 OOMKilled（退出码 137）

4. global OOM：节点级的全局“杀”

4.1 触发条件：全局内存耗尽、kswapd 回收失败
4.2 内核执行流程：

水位线（zone watermarks）
页回收（kswapd、direct reclaim）
调用 out_of_memory() → OOM killer

4.3 受害者选择：badness 分数与 oom_score_adj

4.4 日志分析（dmesg / journalctl -k）
4.5 后果：节点 SSH 卡死、kubelet/containerd 被杀

5. Kubelet EvictionManager：体面驱逐，不开枪

5.1 Eviction vs OOM：机制区别
5.2 eviction-hard / eviction-soft
5.3 Node Condition / Allocatable 机制
5.4 QoS 分类（Guaranteed / Burstable / BestEffort）
5.5 驱逐顺序与示例日志分析

6. “为什么没到 limit 也被杀”深入分析

6.1 page cache 回收受限
6.2 内核 slab 过多
6.3 NUMA 失衡
6.4 JIT / HugePage / THP
6.5 off-heap / native 内存
6.6 容器外内存（overlayfs 元数据、shim）
6.7 内存碎片化
6.8 短暂尖峰（采样捕获不到）

7. 真实排障路径（Runbook）

7.1 快速判断：kubectl describe pod / dmesg / memory.events
7.2 定位容器 cgroup：crictl inspect
7.3 分析节点内核：/proc/pressure/memory、slabtop、numastat
7.4 举例：从 cgroup OOM 到 global OOM 的演化场景
7.5 案例复盘模板

8. 缓解与优化策略

8.1 K8S 层：requests/limits 策略、QoS、Eviction 阈值
8.2 cgroup 层：合理设置 memory.high、监控 memory.events
8.3 内核层：THP 策略、NUMA 优化、PSI 监控
8.4 语言层：JVM / Go / Python 内存管理策略
8.5 存储与缓存优化（page cache、overlayfs）
8.6 观测指标：Prometheus exporter 指标列表

9. 工程化实践

9.1 统一 OOM 监控仪表盘（memory.current / PSI / Eviction metrics）

9.2 自动诊断脚本（shell 示例）
9.3 结合 Argo Rollouts 的自愈与回滚策略
9.4 自动化容量规划（VPA + PSI 信号）

10. 面试口述模板（速背版）

一分钟解释：区分 cgroup OOM vs global OOM
关键命令口令：memory.events、dmesg、PSI
三层优化总结（K8S / cgroup / 内核）

常见陷阱题口径答法


OOM 机制的“核心物理定律”：cgroup 如何“硬性限制”进程的内存使用。下面我们从机制 → 实现 → 触发 → 优化四层拆解。

一、机制：cgroup 的“记账 + 限额 + 执行”

在 Linux 中，cgroup（control group）为每个资源子系统建立独立的记账与控制逻辑。
内存子系统（memory controller）在 每次分配物理页 时都会做两件事：

记账（Accounting）
当进程在该 cgroup 内分配内存（malloc/new、page cache、slab），内核会递增该 cgroup 的使用计数（memory.current）。

校验（Check Limit）
当记账后的值超过 memory.max 时，就触发了 限制逻辑：
先尝试 reclaim（回收页缓存、匿名页）

如果仍超限 → 触发 cgroup OOM

二、实现：每次分配时的内核路径

内核在 mm/memcontrol.c 中（以 v6.x 为例）：

pagefault() -> handle_mm_fault() ->
alloc_page() ->
try_charge_memcg()
    if usage + delta > memory.max:
        reclaim()
        if still over:
            mem_cgroup_oom()


所以 cgroup 限制是内嵌在页分配流程中的，不需要额外进程守护。
这意味着：

不是“定时检测”，而是“分配时阻断”；
cgroup 限制具有原子性与强制性：越界即拒绝。

三、触发：谁杀、杀谁、怎么杀
1. 当触发 memory.max 超限

cgroup 调用 mem_cgroup_oom()，由 memcg OOM 机制接管；
内核扫描该 cgroup 内的所有进程；
计算 badness（类似 global OOM，但范围仅限该组）；
发送 SIGKILL 给目标进程；

事件计数：

memory.events:
oom 1
oom_kill 1


该进程的页表被回收，其余进程继续运行。

2. 当触发 memory.high

不杀，而是 throttling（节流）；
进程被“睡眠”片刻等待回收；
延迟上升，但仍能继续运行；

计数：

memory.events:
high 50

四、K8S 映射：memory.max 从哪里来

K8S Pod 的 resources.limits.memory 会在容器启动时被容器运行时（如 containerd/cri-o）写入：
/sys/fs/cgroup/kubepods/<pod>/memory.max = <limit_value_in_bytes>

因此：

Pod 的 limit 实际就是 cgroup 的硬上限；
cgroup 的杀就是 Pod 的 “OOMKilled”。

五、为什么说是“硬性限制”

由内核直接执行（非守护检测）；
进程无法绕过（除非 root 修改 cgroup）；
即时生效（分配时检测）；

优先保护系统稳定（只杀该组，不影响其他进程）。

可以理解为：

“cgroup memory.max 是一堵写在页分配路径上的墙。任何进程想越墙，都会被系统当场打掉。”

六、优化与工程策略
问题	原因	优化思路
应用频繁 OOMKilled	memory.max 太小	合理调大 limit 或拆分 Pod
应用延迟飙升但未死	触发 memory.high 节流	提高 high 值或优化内存模式
Node 无征兆挂	global OOM	调整 eviction-hard / system-reserved
多 Pod 被同时驱逐	节点剩余可用内存太少	调度/Autoscaler 扩容
七、快速验证命令
# 查看当前 cgroup 限额与使用量
cat /sys/fs/cgroup/memory.max
cat /sys/fs/cgroup/memory.current
cat /sys/fs/cgroup/memory.events

# 模拟触发 OOM
stress-ng --vm 1 --vm-bytes 2G --vm-keep -t 60s

# 观察计数变化
watch -n 1 cat /sys/fs/cgroup/memory.events


要不要我帮你把这一节写成一个 “cgroup memory 限制的实现机制.md”？
可以补上 源码路径 + 简化示意图（页分配 → 记账 → 限额 → OOM），放入你刚才的 chapters/03-2-K8S-Cgroup-OOM-DeepMechanism.md 中。
