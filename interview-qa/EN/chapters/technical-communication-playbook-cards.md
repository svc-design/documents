二、技术沟通“场景卡片”

A. 站会汇报（Daily Standup）

结构：Yesterday → Today → Blockers
模板：Yesterday I … Today I’ll … I’m blocked by … (need …).

示例：Yesterday I finished the Terraform module. Today I’ll wire the CI. I’m blocked by missing AWS credentials; I need SSO access.

B. 设计评审（Design Review）

结构：Goal → Options → Trade-offs → Recommendation → Risks/Metrics
模板：Our goal is … We considered A/B. The trade-offs are … I recommend … because … Risks are … We’ll track …

示例：Our goal is reduce p95 < 200ms. A: in-memory cache; B: CDN. Trade-off is cost vs. freshness. I recommend CDN for 30% hit ratio; risk is stale data; we’ll track hit rate & complaint counts.

C. 事故通报（Incident Update）
结构 （SBAR）：Situation → Background → Assessment → Recommendation
模板： Situation: … Background: … Assessment: … Recommendation: …
示例：Situation: elevated 5xx on checkout. Background: started 10:12 JST after deploy. Assessment: DB connections saturated. Recommendation: rollback + raise pool to 80 temporarily.

D. 代码评审反馈（Code Review）

结构：肯定 → 具体问题 → 影响 → 建议
模板： Nice work on … One concern: … It could cause … Suggest …

示例：Nice work modularizing handlers. One concern: global state in cache may leak across tests; suggest DI for testability.

E. 需求澄清（Requirements）

结构：目标 → 约束 → 验收标准
模板：To confirm, the goal is … Constraints are … Acceptance means …?
示例：To confirm, the goal is <3% error on peak. Constraints: no new infra. Acceptance: green on synthetic + p95 < 200ms for 48h?

F. 估时与承诺（Estimation）

结构：假设 → 拆分 → 区间 → 风险

模板：Assuming …, split into … I estimate … to … Risks: …
示例：Assuming stable API, split into schema/ETL/dashboards. I estimate 3–5 days. Risk: data quality.

G. 异议/范围控制（Scope Control）

模板：I see the value in … However, given the deadline, could we defer … to phase two?

示例：I see the value in multi-region. However, given Black Friday, could we defer it to phase two?
