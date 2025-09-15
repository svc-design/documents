
一份「Go 异步 / 并发 / 协程（goroutine）」相关的面试考点清单 + 高频陷阱与速答示例，覆盖从原理到实战模式。你可以直接当复习提纲。

一、核心原理与机制

Goroutine 本质：用户态轻量线程，按需增长栈（初始 ~2KB），调度开销远小于 OS 线程。

M:N 调度模型（G-M-P）：G（goroutine）、M（machine/OS thread）、P（processor/可运行队列+调度上下文）；work-stealing、抢占式调度（协作+异步抢占）、网络轮询器（epoll/kqueue）。

GOMAXPROCS：运行时可并行执行的 P 数；与物理核心/超线程关系与调优。

阻塞点：syscall、cgo、channel recv/send、mutex、IO；netpoll 降低 OS 线程占用。

抢占与 STW：GC/调度器可能触发短暂停顿；Go 的异步抢占可打断长循环。

二、通信与同步

Channel 语义

无缓冲：发送/接收同步点；缓冲：容量>0，满/空时阻塞。

关闭规则：只能发送方关闭；对已关闭 chan 再 close → panic；从关闭 chan 接收到零值且 ok=false。

for range ch：读到关闭且队列耗尽后退出；对未关闭的阻塞。

nil chan：发送/接收永久阻塞；在 select 中可用来「动态禁用」分支。

select

随机公平选择可用分支；支持 default 非阻塞尝试；超时：select { case <-time.After(d): ... }。

常见模式：超时、取消、扇出/扇入、心跳。

sync 包

WaitGroup（计数对齐）、Mutex/RWMutex（避免数据竞争）、Cond（条件变量）、Once、Map（读多写少；注意类型安全）。

atomic：无锁原子操作，与内存模型（happens-before）配合；避免与普通读写混用。

Context

传播取消/截止时间/元数据；WithCancel/WithTimeout/WithDeadline；务必向下传递并在 goroutine 中select <-ctx.Done() 响应。

errgroup（x/sync）：并发子任务 + 聚合错误 + 自动取消。

三、常用并发模式（务必会写）

Worker Pool（固定并发）：jobs chan 输入，results 输出，WaitGroup 收尾；适合限流/CPU 绑定。

Fan-out / Fan-in：把任务分发到多个 goroutine 并发处理，再归并到单一通道。

Pipeline：阶段化处理，每一层一个 goroutine + chan；支持背压（上游阻塞）。

超时与重试：context.WithTimeout 或 time.After；指数退避。

限速/令牌桶：time.Ticker + buffered chan；或 x/time/rate。

心跳/健康检查：time.Ticker 周期发心跳；select 合并 ctx.Done()。

防泄漏：所有 goroutine 必须能在关闭/取消时退出；避免「永远等不到的 recv/send」。

四、内存模型与 GC（与并发强相关）

逃逸分析：决定栈/堆分配；闭包/接口/取址常导致逃逸 → 增加 GC 压力。

GC：三色标记-清扫、并发 GC、进度调节（pacer）；调优 GOGC（目标堆增长百分比）、sync.Pool 复用。

数据竞争：多 goroutine 非原子共享读写 → 未定义行为；用 -race 侦测。

内存对齐/伪共享：高并发计数器注意 atomic 与缓存行（可用 runtime/internal/sys 的 cache line size 或结构填充）。

五、容器类型与并发陷阱

Slice：append 触发扩容导致底层数组变化；在多 goroutine 写时必须加锁或分片。

Map：并发写 → panic；Go 1.19+ 仍需加锁或用 sync.Map（读多写少且 key 固定模式）。

String/[]byte：string 不可变；[]byte ↔ string 转换可能复制；unsafe 零拷贝有生命周期风险。

Iter 顺序：map 迭代无序且随机化；不要依赖顺序。

六、接口、错误与异常路径

接口方法集与 nil 陷阱：var err error = (*MyErr)(nil) → err != nil?（是非空接口）；

错误包装：fmt.Errorf("…: %w", err)；errors.Is/As；避免「哑错误」。

defer：LIFO、在返回前执行；循环中 defer 可能积压；可改为显式关闭或小作用域。

panic/recover：只在服务边界兜底（middleware）；不可做流程控制。

七、性能与诊断（并发相关）

pprof：CPU/内存/阻塞/互斥；go tool pprof、runtime.SetBlockProfileRate、SetMutexProfileFraction。

trace：runtime/trace 观察调度、网络事件、GC；定位可运行队列长、停顿等。

基准测试：testing.B，避免把 I/O 放在 hot path；b.ReportAllocs() 关注分配。

调度器/GODEBUG：如 GODEBUG=schedtrace=1000,asyncpreemptoff=1,gctrace=1 辅助分析。

八、与异步 I/O/外部交互

网络多路复用：Go 以 goroutine + netpoll 抽象异步 I/O，通常不需要回调式 API。

数据库/HTTP 客户端：连接池、超时、上下文取消；避免泄漏响应体（defer resp.Body.Close()）。

cgo/阻塞：cgo 阻塞会绑死 OS 线程；runtime.LockOSThread() 仅在需要时使用（GUI、线程本地状态）。

高频面试陷阱（要点速记）

谁能 close channel？：发送方；多次 close panic；从关闭 chan 接收零值且 ok=false。

for-range 未关闭的 chan：可能永久阻塞。

nil chan in select：相当于禁用该分支。

data race：go test -race；读写都要受保护，要么全 atomic，要么全加锁。

context 必须向下传：不要存为全局；不要把 context 放在 struct 字段里长期持有。

defer 在循环里：大量对象延后释放 → 内存攀升。

map 并发写：panic；不要心存侥幸。

err 包装：用 %w 支持 errors.Is/As。

goroutine 泄漏：忘记在 select 里监听 ctx.Done()；读写被对端永久阻塞。

GOMAXPROCS：IO 密集通常不需改；CPU 密集结合 -bench 与 pprof 实测。

典型代码片段（面试时手写思路）
1) 带超时的请求 + 自动取消
ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
defer cancel()

select {
case res := <-doWork(ctx):
    _ = res
case <-ctx.Done():
    return ctx.Err()
}

2) Worker Pool（固定并发 + 收尾）
func runPool(ctx context.Context, n int, jobs <-chan Job) <-chan Result {
    out := make(chan Result)
    var wg sync.WaitGroup
    worker := func() {
        defer wg.Done()
        for {
            select {
            case <-ctx.Done():
                return
            case j, ok := <-jobs:
                if !ok { return }
                r := handle(j)     // 纯函数/可重试
                select {
                case out <- r:
                case <-ctx.Done():
                    return
                }
            }
        }
    }
    wg.Add(n)
    for i := 0; i < n; i++ { go worker() }
    go func() { wg.Wait(); close(out) }()
    return out
}

3) fan-in 合并多个只读通道
func fanIn[T any](ctx context.Context, chs ...<-chan T) <-chan T {
    out := make(chan T)
    var wg sync.WaitGroup
    wg.Add(len(chs))
    for _, ch := range chs {
        go func(c <-chan T) {
            defer wg.Done()
            for {
                select {
                case v, ok := <-c:
                    if !ok { return }
                    select {
                    case out <- v:
                    case <-ctx.Done():
                        return
                    }
                case <-ctx.Done():
                    return
                }
            }
        }(ch)
    }
    go func() { wg.Wait(); close(out) }()
    return out
}

4) 限速（令牌桶简版）
lim := time.NewTicker(50 * time.Millisecond) // 20 QPS
defer lim.Stop()
for _, req := range reqs {
    <-lim.C
    go call(req)
}

面试官常问的「短答」

goroutine 与线程差异？：更轻量、可增长栈、用户态调度、M:N 复用、创建/切换更廉价。

什么时候用 sync.Map？：读多写少、键集基本固定、对 interface{} 开销可接受时。

channel 缓冲大小如何选？：按瞬时峰值/消费者处理时延预估；过小导致阻塞，过大增加内存与延迟尾部。

避免 goroutine 泄漏的通用手法？：统一 ctx 取消、select 监听 ctx.Done()、在 close 时关闭输出通道、确保生产/消费对称。

data race vs. atomic：atomic 只对单个变量的原子读写有用，复合不变式仍需锁。

GC 调优第一步？：减少逃逸/分配（复用缓冲、sync.Pool、避免短命大对象），用 pprof 定位热点。

建议的自测题（5～10 分钟手写）

写一个 带超时 的 HTTP 请求封装（context + http.Client）。

写一个 可取消的 worker pool：父 ctx 取消时应尽快退出所有 goroutine。

写一个 pipeline：读取 → 处理（CPU 密集）→ 聚合，并在任一阶段出错时 全链路取消。

演示 map 并发写 panic 与 race detector 的抓取方法。

用 pprof 找出一个基准测试里的 内存分配热路径，并通过切片预分配或对象复用将 alloc/op 降低
