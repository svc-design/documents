---
title: "AI Inference Infra and Serving Frameworks Evaluation"
description: "Comparative study of vLLM, SGLang, and Ollama from an infrastructure perspective — covering containerization, Helm deployment, GPU observability, and high availability design."
tags: ["ai-infra", "vllm", "sglang", "ollama", "serving", "cloudnative"]
date: 2025-10-21
---

# 1. Overview

**vLLM、SGLang 与 Ollama**
三者都是大语言模型（LLM）的推理引擎，可在本地或云端提供模型推理服务。
它们在性能、扩展性与部署复杂度上定位不同，适合 CloudNative / AI 平台中多层次使用。

---

# 2. Framework Comparison

## 📘 第一表格：核心功能对比

| 名称 | 简介 | 典型用途 | 部署复杂度 |
|------|------|-----------|-------------|
| **vLLM** | 高性能推理框架，由 UC Berkeley 开发，优化 KV Cache 与张量并行机制，实现高吞吐、低延迟。 | 云端高性能推理服务（OpenAI API 兼容）。 | ⭐⭐⭐⭐（需 GPU + CUDA 环境） |
| **SGLang** | 基于 vLLM 的上层 Serving 框架，支持 streaming、多模型、function calling 与 memory/agent 机制。 | 构建多模型 Agent / RAG 系统。 | ⭐⭐⭐⭐（依赖 vLLM，部署较复杂） |
| **Ollama** | 面向本地与边缘的轻量 LLM 运行时，支持多模型 `.gguf` 格式与 REST API。 | 桌面端 / 私有化轻量推理环境。 | ⭐⭐（安装即用） |

---

## ⚙️ 第二表格：部署与系统特征对比

| 名称 | 硬件需求 | 容器化与 Helm 支持 | API 兼容性 | 镜像 / 模型 |
|------|-----------|--------------------|-------------|--------------|
| **vLLM** | GPU（≥16 GB 显存） | ✅ 官方 Docker，社区 Helm Chart 丰富 | ✅ 完全兼容 OpenAI API | HuggingFace / Local Model |
| **SGLang** | GPU（≥24 GB 显存） | ✅ 提供容器与 K8s 集成 | ✅ 兼容 OpenAI / Function Calling | HuggingFace / vLLM Backend |
| **Ollama** | CPU 或 GPU（≥8 GB 内存） | ✅ 官方 Docker 镜像（轻量部署） | ✅ 自带 REST API / OpenAI 兼容层 | Ollama `.gguf` 模型库 |

---

# 3. CloudNative / AI 平台统一部署推理引擎

## 🎯 目标
通过统一 Helm Chart（multi-model Serving Chart）
在 Kubernetes 中同时运行 vLLM、SGLang、Ollama，实现多模型、混合架构部署。

### 架构示意

      ┌────────────────────────────┐
      │       Multi-Model API       │
      │   (统一入口 / 网关路由层)   │
      └────────────┬───────────────┘
                    │
 ┌──────────────┬──────────────┬──────────────┐
 │ vLLM Pod      │ SGLang Pod   │ Ollama Pod   │
 │ GPU Serving   │ Multi-Agent  │ CPU / Edge    │
 └──────────────┴──────────────┴──────────────┘
                    │
       ┌───────────────────────────────┐
       │ PVC 模型缓存卷 (HuggingFace)  │
       │ /root/.cache/huggingface       │
       └───────────────────────────────┘
yaml
复制代码

---

## 📦 Helm Chart 核心参数（`values.yaml`）

| 参数 | 说明 | 示例值 |
|------|------|---------|
| `framework` | 指定推理引擎类型 | `vllm` / `sglang` / `ollama` |
| `model.name` | 模型路径或名称 | `meta-llama/Llama-2-7b-chat-hf` |
| `resources.limits.nvidia.com/gpu` | GPU 资源申请 | `1` |
| `args` | 自定义启动参数 | `--max-num-batched-tokens 4096` |
| `persistence.enabled` | 是否挂载模型缓存卷 | `true` |
| `service.type` | 服务类型 | `ClusterIP` / `NodePort` / `LoadBalancer` |

---

# 4. 基础镜像制作（Dockerfile 示例）

### ✅ vLLM
```dockerfile
FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu22.04
RUN apt-get update && apt-get install -y python3 python3-pip git
RUN pip install --upgrade pip && pip install "vllm>=0.5.5"
EXPOSE 8000
CMD ["vllm", "serve", "--model", "facebook/opt-1.3b", "--port", "8000"]
✅ SGLang
dockerfile
复制代码
FROM svc/vllm-base:0.5.5
RUN pip install "sglang>=0.4.0"
CMD ["sglang", "serve", "--model", "meta-llama/Llama-2-7b-chat-hf", "--port", "8000"]
✅ Ollama
dockerfile
复制代码
FROM ollama/ollama:latest
EXPOSE 11434
CMD ["ollama", "serve"]
5. GPU 监控与可用性视角
维度	vLLM	SGLang	Ollama
GPU 指标暴露	✅ /metrics (Prometheus)	✅ Ray / Prometheus 集成	⚙️ 可自定义 Exporter
资源利用率	高（多流批处理）	高（多任务并发）	低（单实例运行）
自动扩缩容 (HPA/KEDA)	✅ 支持 GPU utilization-based	✅ 可结合 Ray Cluster	⚙️ 轻量环境不推荐
健康检查	/health	/healthz	/api/tags 可探测
高可用部署	StatefulSet + PVC 模型缓存	Ray Gateway 集群	DaemonSet / 单节点

6. 总结：三者在 CloudNative 体系中的定位
层级	框架	角色定位	部署建议
核心推理层	vLLM	高性能 GPU 推理引擎	StatefulSet + PVC 模型缓存
上层协调层	SGLang	Function calling / Multi-agent 编排	Helm Chart + Gateway Controller
轻量边缘层	Ollama	本地/离线推理运行时	DaemonSet / 独立节点运行

7. 建议与未来方向
统一使用 multi-model Helm Chart，实现一键多框架部署。

引入 Prometheus / Loki / Grafana，增强 GPU 监控与调度可视化。

对接模型仓库（HuggingFace / Ollama Library）实现动态拉取。

未来可扩展至 inference gateway（如 KServe、OpenAI-compatible router）形成完整 AI Infra 层。


---

这份结构与你的 `16-AI-Platform-Evaluation-Solution-and-Report.md` 保持一致，
同时突出你专注的 **AI Infra 视角（容器化、Helm、GPU监控、可用性）**。

是否希望我接着帮你加上第 **0 节封面摘要（Executive Summary）** 和 **目录 ToC**，做成最终发布版？
