# Milestone 2 TODO

## 文档 QA embedding 最佳实践

### 结构提取
- 为每篇文档生成目录（Table of Contents）并单独 embedding，用于导航检索。
- 将每个标题/小节标题单独 embedding，支持快速定位。
- 将标签、时间、来源等元数据转成文本并 embedding，参与 Hybrid Search。

### 切分策略
- 按段落切分，保持上下文一致性。
- 采用语义切分（基于句子边界或语义相似度）。
- 启用滑动窗口切分（20%~30% 重叠）减少边界信息丢失。
- 多粒度切分（同时存储小块和大块向量）。

### 信息增强
- 实现 Query Expansion / HyDE，在检索前扩展问题或生成假设文档。
- 为每个 chunk 存储摘要向量，提升跨领域匹配效果。
- 融合跨文档引用上下文 embedding。

### 向量优化与后处理
- 去重无意义 chunk（如页眉、版权声明）。
- MMR（Maximal Marginal Relevance）去冗余，提升多样性。
- 对候选结果进行轻量 Re-ranking（如 bge-reranker）。
- 融合多模态信息（如图片描述）。

### 检索优化
- 在 Query 中启用 Hybrid Search（向量 + BM25），权重可配置。
- 支持多向量查询（ColBERT 思路）匹配文档不同部分。
