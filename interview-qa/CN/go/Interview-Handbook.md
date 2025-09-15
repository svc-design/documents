Part A · 面试问答（Q&A with code）
1) Goroutine 与线程的区别？在高并发代理/采集器中的意义

EN: What are goroutines vs OS threads? Why do they matter in a high-concurrency proxy or collector?
A: Goroutines are user-space, cheap to create/switch, growable stacks (~2KB start) and M:N scheduled (G-M-P). They let you fan out per-connection/per-task without exploding OS threads—perfect for log shippers, sidecars, and scraping agents.

2) GOMAXPROCS 如何影响 CPU 绑定任务（如压缩/加密）

EN: How does GOMAXPROCS impact CPU-bound workloads (compression/crypto)?
A: GOMAXPROCS sets concurrent runnable goroutines on CPUs. For CPU-bound stages, tune near #cores and measure with -bench/pprof; for IO-bound agents, default is often fine.

3) 用 context 设计可取消的采集任务（退出即收敛）

EN: Design cancellable collectors that terminate cleanly.

func collect(ctx context.Context, targets []string) <-chan Result {
	out := make(chan Result)
	var wg sync.WaitGroup
	wg.Add(len(targets))
	for _, t := range targets {
		t := t
		go func() {
			defer wg.Done()
			reqCtx, cancel := context.WithTimeout(ctx, 3*time.Second)
			defer cancel()
			select {
			case out <- scrape(reqCtx, t):
			case <-reqCtx.Done():
				return
			}
		}()
	}
	go func() { wg.Wait(); close(out) }()
	return out
}


要点：向下传 ctx；每个 goroutine 监听 ctx.Done()；父级取消时快速收敛，避免泄漏。

4) channel 关闭的原则与常见坑

EN: Channel closing rules & pitfalls?
A: Only the sender closes. Closing twice panics. Reading from closed channel yields zero value with ok=false. for range ch exits when drained and closed; ranging on never-closed may hang.

5) select + 超时/心跳在健康检查中的用法

EN: Use select for timeouts/heartbeats in health checks.

func pingLoop(ctx context.Context, dst string, hb time.Duration) error {
	tk := time.NewTicker(hb)
	defer tk.Stop()
	for {
		select {
		case <-tk.C:
			if err := pingOnce(ctx, dst); err != nil { return err }
		case <-ctx.Done():
			return ctx.Err()
		}
	}
}

6) Worker Pool：限制并发 + 背压（队列满时阻塞）

EN: Implement a worker pool with bounded concurrency/backpressure.

type Job struct{ ID int; Payload []byte }
type Res struct{ ID int; Err error }

func pool(ctx context.Context, n int, jobs <-chan Job) <-chan Res {
	out := make(chan Res)
	var wg sync.WaitGroup
	worker := func() {
		defer wg.Done()
		for {
			select {
			case <-ctx.Done():
				return
			case j, ok := <-jobs:
				if !ok { return }
				err := handle(j)
				select {
				case out <- Res{ID: j.ID, Err: err}:
				case <-ctx.Done():
					return
				}
			}
		}
	}
	wg.Add(n)
	for i := 0; i < n; i++ { go worker() }
	go func(){ wg.Wait(); close(out) }()
	return out
}


要点：有界 jobs 缓冲 = 背压；关闭 jobs 触发收尾；ctx 取消全体退出。

7) 零停机热更新配置（file watcher + 原子替换）

EN: Hot-reload config atomically (no downtime).

func atomicSwap[T any](dst *atomic.Pointer[T], next *T) {
	dst.Store(next) // readers see new config instantly
}

type Config struct{ Targets []string }
var cfgPtr atomic.Pointer[Config]

func Reload(path string) error {
	b, err := os.ReadFile(path); if err != nil { return err }
	var next Config
	if err := json.Unmarshal(b, &next); err != nil { return err }
	atomicSwap(&cfgPtr, &next)
	return nil
}


读侧始终 cfg := cfgPtr.Load()；避免锁争用，更新 O(1)。

8) sync.Map 何时适合？与带锁 map 对比

EN: When to use sync.Map vs map+RWMutex?
A: sync.Map excels in read-mostly with rare writes and a relatively stable key set (like metric descriptors, connection caches). For mixed R/W with invariants, prefer map + RWMutex.

9) 限速与突发（x/time/rate）在 API 调用中的实践

EN: Rate-limit external API calls (steady + burst).

lim := rate.NewLimiter(rate.Limit(100), 200) // 100 QPS, burst 200
func callWithLimit(ctx context.Context, req Req) error {
	if err := lim.Wait(ctx); err != nil { return err }
	return doCall(ctx, req)
}

10) 数据竞争定位与修复

EN: Find & fix data races.
A: Use go test -race, protect shared state with Mutex or use atomic for single-variable counters. Mixed atomic & non-atomic on the same var is UB. Maintain invariants with locks.

11) Pipeline 设计：分阶段处理日志（解析→过滤→压缩→上报）

EN: Multi-stage log pipeline with backpressure/cancellation.

func stage[T any](ctx context.Context, in <-chan T, f func(T) (T, bool)) <-chan T {
	out := make(chan T, 64)
	go func() {
		defer close(out)
		for {
			select {
			case v, ok := <-in:
				if !ok { return }
				nv, ok := f(v); if !ok { continue }
				select {
				case out <- nv:
				case <-ctx.Done():
					return
				}
			case <-ctx.Done():
				return
			}
		}
	}()
	return out
}


要点：每层 goroutine 监听取消；缓冲合理设置以吸收抖动；出现错误可向上游传播 ctx 取消。

12) HTTP 客户端正确超时与连接复用

EN: Correct HTTP client timeouts & connection pooling.

tr := &http.Transport{
	MaxIdleConns:        200,
	MaxIdleConnsPerHost: 100,
	IdleConnTimeout:     90 * time.Second,
	TLSHandshakeTimeout: 5 * time.Second,
	ResponseHeaderTimeout: 5 * time.Second,
	ExpectContinueTimeout: 1 * time.Second,
}
client := &http.Client{
	Transport: tr,
	Timeout:   8 * time.Second, // whole request cap
}


要点：总超时 + 传输级细分超时；务必 defer resp.Body.Close()；注意大响应用 io.Copy 流式处理。

13) 优雅退出（signals + context）

EN: Graceful shutdown with signals and context.

func WithSignals(parent context.Context, sigs ...os.Signal) (context.Context, context.CancelFunc) {
	ctx, cancel := context.WithCancel(parent)
	ch := make(chan os.Signal, 1)
	signal.Notify(ch, sigs...)
	go func() { <-ch; cancel() }()
	return ctx, func(){ signal.Stop(ch); cancel() }
}

14) pprof/trace 在高 QPS 接入层的定位思路

EN: Use pprof/trace to diagnose scheduling stalls, GC pressure, mutex contention; enable block and mutex profiles; compare before/after under representative load.

15) 避免 goroutine 泄漏的通用模板

EN: Template to avoid goroutine leaks when consuming a channel.

func consume(ctx context.Context, in <-chan Item) {
	for {
		select {
		case it, ok := <-in:
			if !ok { return }
			_ = handle(it)
		case <-ctx.Done():
			return
		}
	}
}

Part B · 12 道专题小测（Quiz, 侧重运维场景）

说明：每题 1–2 句话/短代码即可。下方附参考答案。

（并发） 何时应该用有缓冲 channel？给一个背压生效的例子。

（取消） 写一段代码：父 ctx 取消时，正在 select 等待的 goroutine 能够退出。

（select） nil channel 放进 select 有何效果？如何用它实现「动态禁用」分支？

（关闭） 读 for range ch 何时退出？不关闭会怎样？

（HTTP） 正确处理大响应体避免 OOM 的代码片段。

（同步） 在计数器场景，何时选 atomic.AddInt64，何时选 Mutex？

（rate limit） 用 x/time/rate 限制 50 QPS，突发 100。

（map） 为什么并发写原生 map 会 panic？如果读多写少，给一个替代实现。

（pprof） 如何捕获阻塞与互斥概况？需要设置哪些开关？

（pipeline） 三阶段日志处理管道如何在任一阶段出错时取消全链路？

（热更新） 如何原子地替换运行时配置，避免读侧加锁？

（错误包装） 用 %w 包装并在上层判断底层是否为 os.IsTimeout 的等价写法。

参考答案（Answer Key）

有缓冲 channel 用于解耦生产/消费速率并提供背压。当缓冲满时，发送阻塞，迫使上游减速：

jobs := make(chan Job, 128) // 背压阈值
// produce:
select {
case jobs <- j: // ok
default:        // 队列满 → 拒绝/降级/丢弃或阻塞发送（去掉 default）
}

func worker(ctx context.Context, in <-chan Task) {
	for {
		select {
		case t, ok := <-in:
			if !ok { return }
			_ = do(t)
		case <-ctx.Done():
			return
		}
	}
}


nil channel 在 select 中永远不可就绪，相当于禁用该分支：

var data <-chan int // nil = disabled
select {
case v := <-data: _ = v // 永不触发
case <-time.After(time.Second): // fallback
}


for range ch 在 channel 被关闭且缓冲耗尽 时退出；若不关闭且不再写入，会永久阻塞。

resp, _ := client.Get(url)
defer resp.Body.Close()
f, _ := os.Create(dest)
defer f.Close()
_, _ = io.Copy(f, resp.Body) // 流式复制


单一数值计数器选 atomic.AddInt64；涉及多个字段一致性/不变式（如 map+计数）选 Mutex/RWMutex。

lim := rate.NewLimiter(50, 100)
if err := lim.Wait(ctx); err != nil { /* cancelled */ }


Go 的原生 map 非线程安全，并发写会触发运行时检查 panic。读多写少可用 sync.Map 或 map+RWMutex：

var m sync.Map
m.Store("k","v")
v, ok := m.Load("k")

// 运行前设置：
runtime.SetBlockProfileRate(1)
runtime.SetMutexProfileFraction(10)
// 导出 pprof 并用 go tool pprof/浏览器查看


用 errgroup.WithContext：任一 goroutine 返回错误会取消共享上下文：

g, ctx := errgroup.WithContext(parent)
g.Go(func() error { return stage1(ctx) })
g.Go(func() error { return stage2(ctx) })
g.Go(func() error { return stage3(ctx) })
if err := g.Wait(); err != nil { /* cancelled all */ }


atomic.Pointer 保存不可变配置结构体指针，写侧一次性替换，读侧无锁读取：

var cfg atomic.Pointer[Config]
cfg.Store(&Config{/*...*/})
cur := cfg.Load()

if err != nil {
	return fmt.Errorf("fetch %s: %w", url, err)
}
if errors.Is(err, os.ErrDeadlineExceeded) { /* timeout path */ }


或对 net 错误：nerr, ok := err.(net.Error); ok && nerr.Timeout()。

使用建议

面试时优先画图（G-M-P、pipeline、背压、取消传播）。

回答尽量包含：什么时候用、为什么、怎么做（代码片段）、如何验证（pprof/trace/bench）。

真题实战可从：优雅退出、Leak 排查、限速/重试、热更新四个最常问的模块切入演示。

