
“Kubernetes 调度深层原理”，就要从 POD 对象创建 → Scheduler 调度 → Kubelet 拉起容器 这条链路贯穿起来。我们来拆解整条“生命线”。

一、从 Pod 创建到调度前

当用户创建一个 Pod（或 Deployment → ReplicaSet → Pod）时：

1. API Server 持久化对象
2. Pod 对象写入 etcd，状态为 Pending。
3. 此时 .spec.nodeName 为空。
4. Scheduler Cache / Informer 感知变化
5. Scheduler 内部有一套 SharedInformer + Cache，监听 Pod、Node、PV、PVC、PriorityClass 等资源。

当新 Pod 处于 Pending 状态且没有 nodeName 时，会被加入 PendingQueue。

二、Scheduler 核心调度流程
1. SchedulingContext 初始化

Scheduler 从 PendingQueue 拿到 Pod，生成一个 SchedulingCycle Context，这是一轮完整调度循环的上下文。

2. Filter 阶段（旧称 Predicates）

逐节点执行过滤插件，典型插件包括：

NodeUnschedulable：跳过被标记为不可调度的节点；

NodeName：若 Pod 指定了 nodeName；

NodeAffinity / PodAffinity / PodAntiAffinity；

TaintToleration：污点/容忍；

NodeResourcesFit：检查 CPU/Mem/GPU 是否足够；

PodTopologySpread：控制分布范围。

过滤的目的是找出“可行节点候选集（Feasible Nodes）”。

3. Score 阶段（旧称 Priorities）

对可行节点进行打分。典型插件：

LeastAllocated（资源剩余多 → 高分）；

BalancedAllocation（CPU/Mem 利用率均衡）；

TopologySpread（跨可用区分布）；

ImageLocality（节点已缓存镜像）；

自定义打分（企业常加业务权重、GPU 空闲度等）。

综合各插件得分后，选出得分最高节点。

4. Reserve / Permit / PreBind / Bind 阶段

这是 Scheduling Framework 的插件化阶段：

阶段	作用
Reserve	临时占用节点资源（避免并发冲突）
Permit	可做异步审批（等待资源或外部系统确认）
PreBind	可处理 PVC 绑定、网络资源准备等
Bind	写入 spec.nodeName，触发调度成功
PostBind	可记录事件或清理状态

绑定完成后，API Server 更新 Pod → 节点绑定完成，调度结束。

三、抢占（Preemption）机制

若调度失败（无可行节点）且 Pod 优先级高：

Scheduler 会在候选节点上计算 “可抢占受害者集（victims）”；

模拟驱逐，验证若移除低优先级 Pod 是否能调度；

检查 PDB（Pod Disruption Budget），防止破坏可用性；

若通过，发起驱逐并重新调度高优先级 Pod。

常见问题：

抢占可能导致 级联驱逐 或 冷启动雪崩；

生产建议设立优先级梯度 + PDB 约束 + HPA 扩容冗余，给调度“留出口”。

四、Kubelet 与容器启动协作流程

当 Pod 被绑定后，Node 上的 Kubelet 感知变化：

Kubelet Watch Pod 更新事件

Pod 对象同步到本地，Kubelet 创建内部 PodSyncWorker。

Container Runtime 接口 (CRI)

调用 CreatePodSandbox() 创建网络命名空间（pause 容器）；

通过 CNI 插件配置网络；

调用 CreateContainer() 拉取镜像；

设置 cgroup、namespace、volume mount；

启动容器。

健康探针 & Ready 状态

ReadinessProbe 通过 → Pod Ready；

状态上报至 API Server。

此时 Pod 才真正进入 Running 状态。

五、调度与节点协作（延伸）

Informer / Cache 同步：

Scheduler 对集群状态是“延迟一致”的，非强一致；

调度延迟高时可能出现乐观冲突，需配合 Assume 与 Reserve 保证幂等。

Topology Aware Scheduling：

GPU、NUMA、HugePage、MemoryManager、CPUManager 配合；

topologyManagerPolicy=restricted 或 single-numa-node；

典型于高性能计算或 AI 推理任务。

多调度器与扩展机制：

Scheduler Extender：HTTP 回调式扩展；

Scheduling Framework Plugin：原生插件（Coded in Go）；

多调度器：不同 namespace / label 绑定不同 schedulerName。

六、生产优化与实践

Binpacking 策略：

阶段一：优先“均摊”以降低单节点压力；

阶段二：在低负载时“压缩”空闲节点以节能。

扩容反馈链路：

Scheduler 发现无节点可用 → 触发 Cluster Autoscaler 扩容；

调度完成后通过 Kubelet → CRI → CNI → CSI → Pod Ready → HPA/FPA 再反馈资源需求。

调度性能瓶颈：

大集群优化：调度缓存并发、parallelism、skip-nonfit；

结合 QueueSort、PreFilter、Score parallelism 提升吞吐。

七、总结回答模板（可口头答复版本）

“调度过程从 PendingQueue 拿 Pod 开始，依次经过 Filter → Score → Reserve → Bind。
Scheduler Framework 将这些阶段插件化，便于扩展企业策略。
我常结合 NodeAffinity、TopologySpread、GPU 空闲度自定义 Score 插件，实现‘先本地再跨区’策略。
调度后，Kubelet Watch 到 Pod → 通过 CRI 创建 sandbox → CNI 配网 → CSI 挂载 → 启动容器。
在生产上，为防止抢占风暴，会分级设优先级梯度和 PDB，并结合 Cluster Autoscaler 做容量回补。


—从节点接棒到容器真正起来，以及 当 Pod 出问题时，系统如何自愈、重新调度、驱逐。这恰恰是面试官用来区分“懂原理”和“能落地”的关键。

一、调度完成 → Node 侧接棒：Kubelet 启动容器的完整链路

一旦 Scheduler 将 Pod 绑定到节点（即写入 .spec.nodeName），
该节点上的 Kubelet 就会收到 Watch 事件，触发以下阶段：

1. SyncPod Loop 与 PodWorker

Kubelet 内部的 PodWorker 负责调谐目标状态。
每个 Pod 都有一个 Worker 协程，执行 “目标状态 = Running” 的同步逻辑。

核心循环：

desiredState := API Server 中的 PodSpec
currentState := 本地运行容器的状态
→ 调用容器运行时接口 (CRI) 进行 reconcile

二、Kubelet → CRI → CNI → CSI → PodReady 详解
1. CRI（Container Runtime Interface）

Kubelet 并不直接操作容器，而是通过 gRPC 调用 CRI Runtime：

RunPodSandbox()

创建 Pod 级别的 sandbox 容器（通常是 pause）。

建立 Linux Namespace：network、ipc、pid、uts。

分配 cgroup 资源。

sandbox 的 IP 会成为整个 Pod 的 IP。

CreateContainer() & StartContainer()

针对每个容器镜像调用 CreateContainer()。

Runtime 拉取镜像（从本地或远端 registry）。

Mount Volume、配置环境变量、命令、端口映射。

调用 StartContainer() 启动容器进程。

Runtime 可以是：

containerd（主流）

cri-o

DockerShim（已废弃）

nerdctl / Kata / gVisor / WasmEdge（安全/轻量扩展）

2. CNI（Container Network Interface）

Pod 网络的核心。

在 RunPodSandbox 期间，Kubelet 调用 CNI 插件的 ADD 接口；

典型流程：

创建 veth pair；

一端放入 Pod netns；

另一端桥接或路由到主机网络；

分配 IP（通常由 CNI IPAM 管理）；

写入 /etc/cni/net.d/ 配置；

插件例子：Calico / Flannel / Cilium / Weave / Multus。

3. CSI（Container Storage Interface）

存储挂载的标准接口。

在 PreBind → Kubelet Sync 阶段，Kubelet 通过 CSI 调用：

NodeStageVolume：准备卷；

NodePublishVolume：挂载到 Pod 路径；

对应 PVC/PV 生命周期；

支持块存储、文件存储、云盘、NFS、Ceph、EBS 等。

4. Probes 与 Ready 状态

Kubelet 定期探测 Pod 状态：

LivenessProbe：失败 → 重启容器；

ReadinessProbe：决定是否加入 Service Endpoints；

StartupProbe：用于大容器冷启动延迟场景。

只有当所有容器的探针通过后，Pod 状态才会变为：

status:
  phase: Running
  conditions:
  - type: Ready
    status: True


Ready 状态同步回 API Server，此时服务发现（Endpoints、Ingress、Service）才会把流量导入。

三、异常场景与自愈机制

调度不是一劳永逸的，Kubernetes 设计的魅力在于失败可控。

1. Pod 异常分类
异常类型	表现	触发机制
容器崩溃	CrashLoopBackOff	LivenessProbe 重启次数超限
资源超限	Evicted	Node 上 OOM / 磁盘压力
节点失联	Unknown → NotReady	ControllerManager 检测
驱逐/回收	Evicted	调度器或 Kubelet 发起
Pending 超时	Unschedulable	没有合适节点
2. Kubelet 层异常处理

若容器异常退出：
根据 RestartPolicy（Always / OnFailure / Never）重启；
超出阈值 → 标记 CrashLoopBackOff；
若节点资源压力：
触发 Eviction Manager：
检查 MemoryPressure、DiskPressure；
驱逐低优先级 Pod；
按 QoS Class（Guaranteed → Burstable → BestEffort）顺序逐出；
同步事件到 API Server。

3. Controller 层的恢复动作

Kubelet 只是节点本地执行者。更高层 Controller（Deployment、ReplicaSet、StatefulSet）会：
发现 Pod 不存在或状态异常；
创建新的 Pod（可能在其他节点）；
Scheduler 重新调度；
保证副本数满足期望（Replica Count）。

4. 调度重试与 Node 驱逐

调度器检测到某节点 NotReady 超过 node-monitor-grace-period；

触发 NodeLifecycleController：
驱逐该节点上非 DaemonSet / 静态 Pod；
更新 Node Conditions；

驱逐策略可配置：

--node-eviction-rate：并发驱逐速率；
--secondary-node-eviction-rate；
--unhealthy-zone-threshold。

同时，Cluster Autoscaler 会判断是否需要扩容节点补位。

5. 冷启动与级联问题（深层次）

若抢占或 Eviction 触发大量 Pod 重调度：
可能引发镜像拉取风暴；
影响 etcd / API Server；
典型 “冷启动雪崩”；

缓解手段：

PodDisruptionBudget (PDB)；
RateLimit 调度速率；
镜像预热 / Warm Node Pool；
PriorityClass 梯度控制。

四、总结口语化回答框架

“调度完成后，Kubelet 会 Watch 到 Pod 绑定事件，通过 SyncPodLoop 调用 CRI 创建 Sandbox → CNI 配网 → CSI 挂卷，最后启动容器。探针全部通过后才标记 Ready，这时 Service 流量才进来。
一旦容器崩溃、节点资源紧张或节点失联，Kubelet 会先尝试重启或驱逐，ControllerManager 再触发副本重建，Scheduler 重新调度。整个链条实现了自动化自愈。
实战中我会关注 EvictionManager 阈值、PDB 保护、以及冷启动雪崩的防御，让调度和恢复都具备韧性。”
