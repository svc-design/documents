# CI/CD Blueprint

- **Focus**: 可复制的端到端流水线
- **必答要素**: PR 质量门→构建缓存/可重复→依赖/镜像扫描→制品与 provenance→Argo 推进→一键回滚（含 DB Expand-Contract/影子表/双写）→发布后验证。
- **陷阱**: 忽略数据库变更兼容与回滚。
- **材料**: 一段可运行的 Pipeline 片段（含阻断阈值）。

