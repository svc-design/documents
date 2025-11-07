# 面试官考点概述（DevOps Pipeline 视角）

展示如何在 GitHub Actions、GitLab CI/CD 与 ArgoCD GitOps 三种体系下，统一实现 DevOps 全流程（静态检查 → 构建与测试 → 镜像与安全 → 部署与回滚），并列出每阶段的典型工具与替代选型。

面试官最想确认的，不是你会用某个工具，而是你是否理解完整交付闭环：从代码质量 → 构建产物 → 安全合规 → 部署运维 → 回滚恢复，全链路掌控与自动化能力。

# 一、核心考察思路

维度	面试官真正想听到的点
系统性	你能否把 “静态检查 → 构建测试 → 镜像安全 → 部署回滚” 四阶段讲成闭环，而非碎片化命令堆砌。
标准化	你的 Pipeline 是否模板化、可复用、可跨项目落地？（如 reusable workflows / shared GitLab templates）
质量门禁	如何设置 Lint、Test、Coverage Gate、SAST、SBOM、安全扫描、License 审计？
自动化程度	是否有从 Push 到 Deploy 的自动触发链路？是否可根据指标自动回滚？
安全与合规	是否产出 SBOM、执行镜像扫描、签名（cosign）、实现 Supply Chain 安全？
多环境治理	如何区分 dev/stg/prod？机密怎么管理？（SOPS、Sealed Secrets、KMS）
可观测性与反馈	是否接入 OpenTelemetry / Prometheus / Grafana，能否从异常自动触发回滚？
工具选型逻辑	你如何解释 “为什么选 GitHub Actions 而不是 Jenkins / GitLab CI”？背后的组织和成本逻辑是什么？

# 二、四大阶段的典型提问方向
阶段	面试官常问问题	期望听到的回答关键词
① 静态检查 / 单测 / 质量门禁	- 你们如何防止不规范代码进入主干？
- 覆盖率如何设置阈值？	ESLint、ruff、golangci-lint、pytest/jest + coverage gate、SonarQube、Git Hooks、PR Checks
② 构建与测试	- 多语言项目如何统一构建？
- 如何保证构建可复现？	pnpm + cache、Go -trimpath、Python wheel/pex、multi-stage Dockerfile、artifact caching
③ 镜像与安全 / 版本化	- 如何确保镜像安全与可追溯？
- SBOM 是如何生成与验证的？	syft / trivy / grype / cosign、semantic-release / goreleaser、SBOM 入库、供应链签名
④ 部署 / 监控 / 回滚	- 灰度发布如何控制？
- 出现异常如何自动回滚？	Helm / Kustomize / Argo CD / Rollouts、金丝雀策略、Prometheus 指标触发、Argo Abort、Feature Flag

# 三、工具链体系认知（综合性问题）

类别	代表工具	面试官想看什么
CI 引擎	Jenkins / GitLab CI / GitHub Actions / Drone	选型逻辑、可维护性、插件与生态
构建工具	pnpm / Go build / uv / Docker buildx	多语言统一与缓存优化
安全扫描	Trivy / Grype / Syft / Cosign	DevSecOps 实践与供应链安全
部署体系	Helm / Kustomize / Argo CD / Flux	GitOps 实现与多环境差异
灰度与回滚	Argo Rollouts / OpenFeature / Unleash	自动化发布与回退机制
可观测性	OpenTelemetry / Prometheus / Grafana / Loki	SLO 驱动运维反馈闭环

# 四、加分项（面试高阶）

你能画出自己的 CI/CD + GitOps 架构图（Actions → Registry → GitOps → ArgoCD → Rollouts）。
你有实际经验处理 构建失败 / OOM / 镜像漏洞 / Rollout 异常。
你能讲出一次真实的 自动回滚案例（延迟、错误率、Release 回撤）。
你能从开发视角切入 DevOps（例如 Next.js SSR 静态导出策略、Go 模块优化、Python 异步性能调优）。

# 五、一句话抢答总结（面试高分句）

“我们把 CI/CD 分成四个阶段：静态检查 → 构建测试 → 镜像安全 → 部署回滚。
CI 用 GitHub Actions 模板化；CD 用 ArgoCD 声明式同步；Rollouts 实现金丝雀回滚；
全流程产出 SBOM + 安全扫描 + 可观测指标，实现从 Push 到 Rollback 的全闭环。”


# DevOps 四阶段流水线矩阵

阶段	目标	GitHub Actions 模板	GitLab CI/CD 模板	ArgoCD GitOps 结构	工具链选型与可替换件

① 静态检查 / 单测 / 质量门禁	统一规范与代码健康	.github/workflows/lint-test.yml
触发 push/pull_request，运行 ESLint、ruff、golangci-lint、Jest/Pytest	.gitlab-ci.yml 中定义 stages: [lint, test]，Runner 执行 Lint + Test Job，设置 coverage 阈值	不直接执行代码检查，但可通过 Argo Workflows 集成前置测试	- ESLint / Prettier / Ruff / Black / go fmt / golangci-lint
- Jest / Pytest / Go test + Coverage Gate
- SonarQube / CodeQL（可选）

② 构建与测试	生成可重现制品	build.yml 任务使用 pnpm build / go build -trimpath / uv build，缓存依赖	build: job 在 Runner 上执行多语言构建，使用 artifacts 上传产物	构建产物不在 ArgoCD 中执行，GitOps 仅引用镜像版本	- Next.js（Node18+/pnpm）
- Go (GOOS/GOARCH / CGO_ENABLED=0)
- Python (uv/poetry/wheel/pex)
- Multi-stage Dockerfile 构建

③ 镜像与安全 / 版本化	镜像生成、SBOM、安全扫描、签名、发布	使用 syft 生成 SBOM → trivy 扫描 → cosign 签名，推送到 GHCR；触发 semantic-release 生成版本 tag	GitLab 内置 Container Registry + Dependency Scanning + License Compliance；自动生成 CHANGELOG.md	ArgoCD 从 Git 引用已签名镜像；支持 Image Updater 自动更新 tag	- SBOM：Syft
- 扫描：Grype / Trivy
- 签名：Cosign
- 版本化：semantic-release / goreleaser
- 归档：GHCR / Harbor / GitLab Registry

④ 部署 / 监控 / 回滚	声明式交付、灰度发布、自动回滚	CI 结束后触发 scripts/create-gitops-pr.sh，提交变更到 env repo；ArgoCD 监控同步	.gitlab-ci.yml 中的 deploy 阶段调用 kubectl / helm / 触发 ArgoCD API	GitOps 核心：
env-repo/
├── dev/stg/prod/
├── rollout.yaml（灰度策略）
├── values.yaml（环境差异）
├── secrets.enc.yaml（SOPS 机密）	- 部署：Helm / Kustomize / ArgoCD / Flux
- 灰度：Argo Rollouts（金丝雀/蓝绿）
- Feature Flags：OpenFeature / Unleash / Flagd
- 机密：SOPS(age) / Sealed Secrets
- 监控：Prometheus + Grafana + Loki + Tempo
- 自动回滚：Argo Rollouts Abort / ArgoCD rollback

# 三类流水线模板概览

## GitHub Actions Pipeline
name: ci-cd
on: [push, pull_request]
jobs:
  lint-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pnpm lint && pnpm test -- --coverage
  build-scan:
    needs: lint-test
    steps:
      - run: docker build -t ghcr.io/org/app:${{ github.sha }} .
      - run: syft packages . -o spdx-json > sbom.json
      - run: trivy image ghcr.io/org/app:${{ github.sha }}
      - run: cosign sign ghcr.io/org/app:${{ github.sha }} --yes
  deploy:
    needs: build-scan
    steps:
      - run: ./scripts/create-gitops-pr.sh


## GitLab CI/CD Pipeline

stages:
  - lint
  - build
  - scan
  - deploy

lint:
  stage: lint
  script:
    - ruff check .
    - pytest --cov --cov-fail-under=80

build:
  stage: build
  script:
    - docker build -t $CI_REGISTRY/app:$CI_COMMIT_SHA .
  artifacts:
    paths:
      - sbom.json

scan:
  stage: scan
  script:
    - syft packages . -o spdx-json > sbom.json
    - trivy image $CI_REGISTRY/app:$CI_COMMIT_SHA
    - cosign sign $CI_REGISTRY/app:$CI_COMMIT_SHA --yes

deploy:
  stage: deploy
  script:
    - ./scripts/gitops-sync.sh
```i```

## ArgoCD GitOps 结构

env-repo/
  ├── dev/
  │   ├── web/
  │   │   ├── kustomization.yaml
  │   │   ├── rollout.yaml        # 金丝雀策略
  │   │   ├── values.yaml         # 环境参数
  │   │   └── secrets.enc.yaml    # SOPS 加密机密
  ├── stg/
  └── prod/


GitOps 流程：

- CI（GitHub Actions / GitLab CI）更新镜像 tag 并提交 PR → env repo
- ArgoCD 自动检测变更 → 同步应用
- Argo Rollouts 控制灰度 / 回滚
- Prometheus 指标驱动自动中止或放量

## 总结要点

GitHub Actions → 轻量云原生 CI，模板化、生态广。
GitLab CI → 企业一体化 DevSecOps 平台，内置扫描与审计。
ArgoCD GitOps → 负责持续部署与环境对齐，是 CD 最佳实践。

三者组合：

Actions / GitLab CI 负责 构建 → 推镜像 → 提交 GitOps PR
ArgoCD 负责 部署 → 监控 → 回滚
形成完整的 代码 → 交付 → 运行 闭环。
