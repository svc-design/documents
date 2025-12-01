#!/usr/bin/env bash
set -e

BASE_DIR="cloud-neutral-reference"

# Create base directory if not exists
mkdir -p "$BASE_DIR"

cd "$BASE_DIR"

echo "Initializing Cloud-Neutral Reference directory structure..."
echo

create() {
  mkdir -p "$1"
  touch "$1/.keep"
  echo "  + $1"
}

# -------------------------
# CORE STRUCTURE
# -------------------------
create "01-overview"
create "02-dns-gslb"
create "03-cdn-edge"
create "04-load-balancer"
create "05-web-entry-vhost"

# -------------------------
# DATA SERVICES
# -------------------------
create "06-data-services"
create "06-data-services/01-postgres"
create "06-data-services/02-redis"
create "06-data-services/03-mq"
create "06-data-services/04-object-storage"

# -------------------------
# HYBRID CLUSTER
# -------------------------
create "07-hybrid-cluster"

# -------------------------
# IaC + Ansible + GitOps
# -------------------------
create "08-iac-ansible-gitops"

# -------------------------
# CI/CD + Release + Upgrade
# -------------------------
create "09-ci-cd-release-upgrade"

# -------------------------
# Disaster Recovery
# -------------------------
create "10-disaster-recovery"

# -------------------------
# Case Studies
# -------------------------
create "11-case-studies"

# ============================================================
#   DATA PLATFORM (Big Data / Lakehouse)
# ============================================================
create "12-data-platform"
create "12-data-platform/12.1-data-lake"
create "12-data-platform/12.2-lakehouse"
create "12-data-platform/12.3-big-data-compute"
create "12-data-platform/12.4-streaming"
create "12-data-platform/12.5-olap-warehouse"

# ============================================================
#   AI / LLM PLATFORM
# ============================================================
create "13-ai-llm-platform"
create "13-ai-llm-platform/13.1-inference"
create "13-ai-llm-platform/13.2-training"
create "13-ai-llm-platform/13.3-vector-db"
create "13-ai-llm-platform/13.4-rag-pipeline"
create "13-ai-llm-platform/13.5-agentops"
create "13-ai-llm-platform/13.6-multi-cloud-gpu-infra"

# ============================================================
#   FULL LIFECYCLE
# ============================================================
create "14-full-lifecycle"
create "14-full-lifecycle/14.1-deploy-patterns"
create "14-full-lifecycle/14.2-migration-patterns"
create "14-full-lifecycle/14.3-upgrade-patterns"
create "14-full-lifecycle/14.4-disaster-recovery-patterns"

echo
echo "✨ Cloud-Neutral Reference skeleton created successfully!"
