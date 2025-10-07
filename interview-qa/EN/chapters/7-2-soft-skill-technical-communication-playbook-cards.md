# A. Daily Standup — 日常站会汇报

Structure: Yesterday → Today → Blockers
Template: Yesterday I … Today I’ll … I’m blocked by … (need …)

Example:

Yesterday I refactored the API client for better error handling.
Today I’ll integrate it into the workflow runner.
I’m blocked by missing staging credentials; I need temporary access to test it.

# 🧭 B. Design Review — 设计评审

Structure: Goal → Options → Trade-offs → Recommendation → Risks/Metrics
Template: Our goal is … We considered A/B. The trade-offs are … I recommend … because … Risks are … We’ll track …
Example:

Our goal is to reduce cold-start latency.
We considered pre-warming pods (A) and enabling lazy module loading (B).
The trade-off is cost vs. simplicity.
I recommend option B because it’s cheaper and easier to roll out.
Risk: unexpected initialization delays; we’ll track p95 startup time.

# 🚨 C. Incident Update — 事故通报

Structure (SBAR): Situation → Background → Assessment → Recommendation
Template: Situation: … Background: … Assessment: … Recommendation: …
Example:

Situation: Users are seeing 502 errors on login.
Background: Started after the Redis upgrade this morning.
Assessment: Session cache eviction rate increased due to lower memory limit.
Recommendation: Roll back Redis config and scale vertically by +1GB RAM.

# 💬 D. Code Review — 代码评审反馈

Structure: Praise → Concern → Impact → Suggestion
Template: Nice work on … One concern: … It could cause … Suggest …
Example:

Nice work simplifying the retry logic.
One concern: the loop lacks exponential backoff.
It could cause request flooding under failure.
Suggest using time.Sleep(backoff * attempt) or a retry helper.

# 📋 E. Requirements Clarification — 需求澄清

Structure: Goal → Constraints → Acceptance Criteria
Template: To confirm, the goal is … Constraints are … Acceptance means …?
Example:

To confirm, the goal is to auto-scale pods within 2 minutes under load.
Constraints: no external autoscaler, must work on EKS.
Acceptance means CPU-based scaling triggers and metrics stay within 70–90% for 24 hours?

# ⏱️ F. Estimation & Commitment — 估时与承诺

Structure: Assumption → Breakdown → Range → Risks
Template: Assuming …, split into … I estimate … to … Risks: …
Example:

Assuming the API spec is stable, I’ll split this into SDK, integration tests, and release pipeline.
I estimate 2–4 days total.
Risks: CI build times and dependency caching.

# 🚧 G. Scope Control — 异议 / 范围控制

Template: I see the value in … However, given the deadline, could we defer … to phase two?
Example:

I see the value in adding a metrics dashboard for this feature.
However, given the Q4 release deadline, could we defer it to phase two?
