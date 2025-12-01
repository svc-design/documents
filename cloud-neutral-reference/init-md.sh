
#!/usr/bin/env bash
set -e

echo "Initializing README.md files for all chapters..."
echo

# A helper function: create README.md with a title
make_readme() {
  local dir="$1"
  local title="$2"

  cat > "$dir/README.md" <<EOF
# $title

## 概述
（本章节将介绍：为什么需要这一层？其作用？与 Cloud-Neutral 的关系？）

## 设计原则
- 原理说明
- 选择理由
- 多云 / 自建 / fallback
- 成本与趋势

## 架构图（后续填）
\`\`\`mermaid
%% TODO: diagram
\`\`\`

## 实践内容
- 方案设计
- 部署模式（IaC / Ansible / GitOps）
- 多云兼容性
- 性能 / 安全 / 成本

## 验证方法
- 如何做故障演练
- 如何测试 failover
- 如何做回切（rollback）

## 灾备与迁移
- 数据/流量/状态相关风险
- 如何跨云迁移
- 如何最小化停机时间

EOF

  echo "  + $dir/README.md"
}

# Root-level readme generator
cat > README.md <<EOF
# Cloud Neutral Reference Architecture

本项目是一套完整的 **Cloud-Neutral 多云架构参考体系**，涵盖：

- DNS / GSLB
- CDN / Edge
- Load Balancer
- Web Entry (VHost)
- Data Services（DB/Cache/MQ/Store）
- Hybrid Cluster
- IaC / Ansible / GitOps
- CI/CD / Upgrade
- Disaster Recovery
- 案例分析
- 大数据平台（Data Lake / Warehouse）
- AI / LLM（Inference / Training / VectorDB / RAG / AgentOps）
- 全生命周期（部署 / 迁移 / 升级 / 灾备）

本仓库为长期演进的“云中立基础设施蓝皮书”，重点不是“完全自建”，而是：

- 理解底层
- 掌握趋势
- 构建可控路径
- 提升可迁移性
- 有能力在事故时自救

EOF

echo "  + README.md"

# ---------------------------
# Mapping titles to directories
# ---------------------------

make_readme "01-overview" "01 概览（Overview）"
make_readme "02-dns-gslb" "02 DNS / GSLB 设计"
make_readme "03-cdn-edge" "03 CDN 与 Edge 反向代理"
make_readme "04-load-balancer" "04 Load Balancer 层"
make_readme "05-web-entry-vhost" "05 Web Entry / VHost 层"

make_readme "06-data-services" "06 数据服务总览"
make_readme "06-data-services/01-postgres" "PostgreSQL（Cloud + 自建 + 灾备）"
make_readme "06-data-services/02-redis" "Redis（Cache / Session）"
make_readme "06-data-services/03-mq" "消息队列（MQ / Streaming）"
make_readme "06-data-services/04-object-storage" "对象存储（S3 / OSS / R2 / MinIO）"

make_readme "07-hybrid-cluster" "07 混合集群（K8s / VM / Edge / GPU）"
make_readme "08-iac-ansible-gitops" "08 IaC + Ansible + GitOps 系统"
make_readme "09-ci-cd-release-upgrade" "09 CI/CD / 发布 / 升级体系"
make_readme "10-disaster-recovery" "10 灾备体系（DR）"
make_readme "11-case-studies" "11 案例分析（Case Studies）"

# --- Data Platform ---
make_readme "12-data-platform" "12 大数据平台（Data Platform）"
make_readme "12-data-platform/12.1-data-lake" "12.1 数据湖（S3/OSS/MinIO）"
make_readme "12-data-platform/12.2-lakehouse" "12.2 Lakehouse（Iceberg / Delta / Hudi）"
make_readme "12-data-platform/12.3-big-data-compute" "12.3 大数据计算（Spark / Flink / Trino）"
make_readme "12-data-platform/12.4-streaming" "12.4 流式处理（Kafka / Redpanda / Pulsar）"
make_readme "12-data-platform/12.5-olap-warehouse" "12.5 OLAP 数仓（ClickHouse / BigQuery）"

# --- AI / LLM ---
make_readme "13-ai-llm-platform" "13 AI / LLM 平台总览"
make_readme "13-ai-llm-platform/13.1-inference" "13.1 推理层（Inference）"
make_readme "13-ai-llm-platform/13.2-training" "13.2 训练层（Training）"
make_readme "13-ai-llm-platform/13.3-vector-db" "13.3 向量数据库（Vector DB）"
make_readme "13-ai-llm-platform/13.4-rag-pipeline" "13.4 RAG Pipeline"
make_readme "13-ai-llm-platform/13.5-agentops" "13.5 AgentOps 多 Agent 调度"
make_readme "13-ai-llm-platform/13.6-multi-cloud-gpu-infra" "13.6 多云 GPU 灰度/弹性 Infra"

# --- Full Lifecycle ---
make_readme "14-full-lifecycle" "14 全生命周期（部署 / 迁移 / 升级 / DR）"
make_readme "14-full-lifecycle/14.1-deploy-patterns" "14.1 部署模式（Deploy Patterns）"
make_readme "14-full-lifecycle/14.2-migration-patterns" "14.2 迁移模式（Migration）"
make_readme "14-full-lifecycle/14.3-upgrade-patterns" "14.3 升级模式（Upgrade）"
make_readme "14-full-lifecycle/14.4-disaster-recovery-patterns" "14.4 灾备模式（DR Patterns）"

echo
echo "✨ All README.md templates created successfully!"
