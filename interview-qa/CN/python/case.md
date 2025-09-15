一套面向运维开发（Ops/DevOps/SRE）的 Python 面试问答 + 练习题（含参考解）。聚焦你日常会用到的：并发、系统编排、网络/HTTP、日志与可观测、配置与发布、测试与CI、性能与故障排查、安全与健壮性等。

A. 面试问答（要点 + 代码）
1) 线程 vs 进程 vs asyncio 适用场景

线程（threading）：I/O 密集；受 GIL 限制，CPU 密集收益有限。

进程（multiprocessing）：CPU 密集；绕过 GIL；跨进程开销更大。

asyncio：单线程协作式并发；大量网络 I/O、连接型任务。

# I/O 密集：线程池
from concurrent.futures import ThreadPoolExecutor
with ThreadPoolExecutor(64) as ex: ex.map(download, urls)

# CPU 密集：进程池
from concurrent.futures import ProcessPoolExecutor
with ProcessPoolExecutor() as ex: ex.map(compress, files)

# asyncio：海量网络并发
import asyncio, aiohttp
async def fetch(sess,u): async with sess.get(u) as r: return await r.text()
async def main(urls):
    async with aiohttp.ClientSession() as s:
        return await asyncio.gather(*(fetch(s,u) for u in urls))
asyncio.run(main(urls))

2) Python 的 GIL 是什么？如何绕开？

GIL：同一进程内一次仅一个线程执行 Python 字节码。

绕开：用多进程、C 扩展释放 GIL、numba/cython、或把热点移交到调用原生库（如 numpy）。

I/O 密集可以用线程；CPU 密集用进程。

3) 正确管理子进程与超时/回显
import subprocess, shlex
cp = subprocess.run(
    shlex.split("tar -czf out.tgz /data"),
    check=True, capture_output=True, text=True, timeout=60
)
print(cp.stdout)


禁止拼接不可信命令；用 shlex.split 或 args=list。

check=True 抛出非零码；timeout 防挂死；必要时用 Popen + communicate()。

4) 构建健壮 CLI（argparse/typer）
import argparse
p = argparse.ArgumentParser()
p.add_argument("--config", required=True)
p.add_argument("--qps", type=int, default=100)
args = p.parse_args()


生产更推荐 typer/click 获得更好 UX、颜色、子命令。

5) 配置加载（优先级：flag > env > 文件）
import os, json
cfg = json.load(open("config.json"))
cfg["qps"] = int(os.getenv("APP_QPS", cfg.get("qps", 100)))
# flag 层再覆盖……


支持 JSON/YAML/TOML；建议单向合并并打印有效配置快照（避免隐性误配）。

6) 结构化日志与可观测
import logging, json, sys, time
class JsonFormatter(logging.Formatter):
    def format(self, r):
        return json.dumps({"lvl": r.levelname, "msg": r.getMessage(), "ts": time.time()})
h = logging.StreamHandler(sys.stdout); h.setFormatter(JsonFormatter())
log = logging.getLogger("app"); log.setLevel(logging.INFO); log.addHandler(h)
log.info("service started")


日志要结构化、包含 request_id、env、host；配合 prometheus_client 暴露指标；可选 OTel tracing。

7) 优雅退出（signals + asyncio）
import asyncio, signal
async def main():
    stop = asyncio.Event()
    for s in (signal.SIGINT, signal.SIGTERM):
        asyncio.get_running_loop().add_signal_handler(s, stop.set)
    # …启动任务
    await stop.wait()   # 收到信号后退出
asyncio.run(main())

8) 连接池与 HTTP 客户端

requests 默认短连接，复用要用 Session；高并发优先 aiohttp。

import requests
s = requests.Session()
s.headers.update({"User-Agent": "ops-bot/1.0"})
r = s.get("https://api", timeout=5); r.raise_for_status()

9) 重试与退避（幂等接口）
import time, random, requests
def retry(fn, tries=5, base=0.2, cap=3.0):
    for i in range(tries):
        try: return fn()
        except requests.RequestException:
            time.sleep(min(cap, base * 2**i) + random.random()*0.1)
    raise


只对幂等操作重试；区分可重试 vs 不可重试错误（HTTP 5xx/429）。

10) 并发限流（令牌桶）
import asyncio, time
class RateLimiter:
    def __init__(self, rate, burst): self.tokens=burst; self.rate=rate; self.ts=time.time()
    async def acquire(self):
        while True:
            now=time.time(); self.tokens=min(self.tokens+(now-self.ts)*self.rate, self.rate)
            self.ts=now
            if self.tokens>=1: self.tokens-=1; return
            await asyncio.sleep(0.01)
lim = RateLimiter(100, 200)

11) 队列与后台任务（asyncio.Queue / Redis）
import asyncio
q = asyncio.Queue(maxsize=1000)
async def worker():
    while True:
        item = await q.get()
        try: await handle(item)
        finally: q.task_done()


跨进程/集群用 Redis（rq, celery, arq）；注意可见性超时、幂等与去重。

12) 文件与目录操作的安全性

使用 pathlib；检查路径是否在允许的根内（防目录穿越）。

from pathlib import Path
root = Path("/safe/root").resolve()
p = (root / user_rel).resolve()
if root not in p.parents: raise PermissionError("path traversal")

13) 临时文件、权限与密钥
import tempfile, os
with tempfile.NamedTemporaryFile(delete=True) as f:
    os.fchmod(f.fileno(), 0o600)
    f.write(secret_bytes)

14) 性能剖析与内存泄漏定位

cProfile + snakeviz；tracemalloc 追踪分配；热点用 line_profiler。

import cProfile, pstats
with cProfile.Profile() as pr: run()
pstats.Stats(pr).sort_stats("tottime").print_stats(20)

15) 生成器/迭代器用于流式处理
def read_lines(path):
    with open(path) as f:
        for line in f: yield line


低内存扫描日志/大文件；可与 itertools 管道化。

16) 上下文管理（资源安全）
from contextlib import contextmanager
@contextmanager
def cd(p):
    import os; cwd=os.getcwd()
    try: os.chdir(p); yield
    finally: os.chdir(cwd)

17) 数据模型与校验（dataclasses / pydantic）
from pydantic import BaseModel, Field
class Config(BaseModel):
    qps: int = Field(100, ge=1, le=10000)


对外部输入进行强校验，减少线上异常。

18) 缓存与过期（lru_cache / Redis）
from functools import lru_cache
@lru_cache(maxsize=1024)
def geoip(ip): ...


分布式共享用 Redis + TTL + 版本键；注意缓存击穿/雪崩。

19) 打包与发布（venv/Poetry/Docker）

锁定依赖（requirements.txt/poetry.lock），构建多阶段 Docker，非 root 运行。

FROM python:3.12-slim AS base
WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN pip install poetry && poetry install --no-root --only main
COPY . .
CMD ["python","-m","app"]

20) 测试与 CI（pytest + mock + 参数化）
import pytest
@pytest.mark.parametrize("code", [200, 500])
def test_resp(client, code, mocker):
    mocker.patch("svc.call", return_value=code)
    assert handle() == (code==200)


在 CI 中跑 pytest -q, ruff/flake8, mypy, bandit；生成覆盖率。

B. 练习题（10 题）+ 参考解要点

每题给出目标与解题要点/示例片段，可直接当作家庭作业或面试白板题。

1) 编写一个 tail -f 风格的异步日志跟随器（支持热切换文件）

要点：asyncio.to_thread 或 aiofiles；文件轮转检测（inode/size 回退）；asyncio.Queue 向下游传输；SIGTERM 退出。

2) 用 aiohttp 并发抓取 1,000 个 URL，限制 200 并发，失败做指数退避重试
sem = asyncio.Semaphore(200)
async def go(u):
    async with sem:
        for i in range(5):
            try:
                async with s.get(u, timeout=5) as r:
                    r.raise_for_status(); return await r.text()
            except Exception:
                await asyncio.sleep(min(3, 0.2*2**i))

3) 实现一个 Prometheus 指标端点，导出请求总数、耗时直方图

要点：prometheus_client 的 Counter, Histogram; start_http_server(9100)；在业务路径中 observe()。

4) 写一个可取消的后台任务系统：生产者读队列，多个 Worker 并发处理，优雅退出

要点：asyncio.Queue(maxsize=...)；task_done/join；收到取消事件时停止生产并 drain；shield 保护正在处理的任务完成或超时放弃。

5) 制作一个安全的 subprocess 包装器，带日志、超时、最大输出截断
def run(cmd: list[str], timeout=30, max_out=1<<20):
    cp = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, check=False)
    out = cp.stdout[:max_out]; err = cp.stderr[:max_out]
    return cp.returncode, out, err

6) 写一个配置加载器：支持 --config(YAML) + 环境变量覆盖 + schema 校验（pydantic）

要点：yaml.safe_load → pydantic.BaseModel；打印最终配置（敏感字段脱敏）。

7) 设计一个小型文件服务：上传到本地目录，防目录穿越，生成一次性下载链接

要点：pathlib.resolve 检查根目录；一次性 token 存内存/Redis；下载后失效；Nginx/X-Accel-Redirect 可加分。

8) 用 multiprocessing 并行压缩多个大文件，进度条与失败重试

要点：Pool.imap_unordered；tqdm 进度；失败收集后重试 N 次；注意 maxtasksperchild 避免内存膨胀。

9) 实现一个 LRU 本地缓存 + Redis 回源的 KV 客户端，带 TTL 与批量预热

要点：functools.lru_cache 或 cachetools.TTLCache；缓存击穿保护（singleflight/锁）；批量 pipeline。

10) 编写一个 FastAPI 健康检查与依赖注入示例：/healthz, /metrics, /config

要点：FastAPI + Depends 注入配置/客户端；/metrics 暴露 Prometheus；统一日志中间件注入 request_id。

C. 参考实现片段合集（可直接拼装）

1) Prometheus 指标 + FastAPI

from fastapi import FastAPI, Request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time

app = FastAPI()
REQS = Counter("http_requests_total", "Total HTTP requests", ["path","method","code"])
LAT  = Histogram("http_request_latency_seconds", "Latency", ["path"])

@app.middleware("http")
async def metrics_mw(req: Request, call_next):
    start = time.time()
    resp = await call_next(req)
    LAT.labels(req.url.path).observe(time.time()-start)
    REQS.labels(req.url.path, req.method, resp.status_code).inc()
    return resp

@app.get("/metrics")
def metrics():
    from fastapi.responses import Response
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

@app.get("/healthz")
def healthz(): return {"ok": True}


2) asyncio + 优雅退出 + Worker

import asyncio, signal

async def worker(name, q: asyncio.Queue):
    while True:
        try:
            item = await q.get()
            await handle(item)
        finally:
            q.task_done()

async def main():
    q = asyncio.Queue(maxsize=1000)
    stop = asyncio.Event()
    loop = asyncio.get_running_loop()
    for s in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(s, stop.set)

    workers = [asyncio.create_task(worker(f"w{i}", q)) for i in range(8)]
    prod = asyncio.create_task(producer(q, stop))

    await stop.wait()
    prod.cancel()
    await q.join()      # 等待已入队任务处理完
    for w in workers: w.cancel()

asyncio.run(main())


3) requests Session + 重试适配器

import requests
from urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter

def session():
    s = requests.Session()
    retry = Retry(total=5, backoff_factor=0.2, status_forcelist=[429,500,502,503,504])
    s.mount("http://", HTTPAdapter(max_retries=retry, pool_connections=100, pool_maxsize=100))
    s.mount("https://", HTTPAdapter(max_retries=retry, pool_connections=100, pool_maxsize=100))
    return s


4) tracemalloc 定位内存热点

import tracemalloc
tracemalloc.start()
# run workload ...
cur, peak = tracemalloc.get_traced_memory()
print("cur:",cur,"peak:",peak)
print(tracemalloc.take_snapshot().statistics('lineno')[:10])

用法建议

面试时把答案结构化为：场景判断 → 组件选择 → 关键代码/边界条件 → 观测/回滚/灰度策略。

代码贴出最小闭环：超时、重试、日志、指标、取消、优雅退出至少一个要有。

练习题可以逐题打包成一个小仓库，配上 pytest & pre-commit & Dockerfile，直接跑 CI
