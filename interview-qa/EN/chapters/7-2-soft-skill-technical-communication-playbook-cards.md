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

<<<<<<< HEAD
Assuming the API spec is stable, I’ll split this into SDK, integration tests, and release pipeline.
I estimate 2–4 days total.
Risks: CI build times and dependency caching.

# 🚧 G. Scope Control — 异议 / 范围控制

Template: I see the value in … However, given the deadline, could we defer … to phase two?
Example:

I see the value in adding a metrics dashboard for this feature.
However, given the Q4 release deadline, could we defer it to phase two?
=======
示例：I see the value in multi-region. However, given Black Friday, could we defer it to phase two?


外企技术主管面试开场与收尾模板》（中英对照版，可背诵、自然口语化），控制在一页以内，涵盖开场问候 → 简短自我介绍 → 收尾感谢 → 礼貌结束，全程语气专业但自然，适合技术面或主管面使用。

💬 外企技术主管面试开场与收尾模板（中英对照）
🟢 开场部分（Greeting & Introduction）

English:
Hi [Name], it’s great to meet you today. Thanks for taking the time to speak with me.
I’m [Your Name], currently working as a Senior SRE / Cloud Engineer.
Over the past few years, I’ve been focusing on infrastructure automation, observability, and CI/CD systems across cloud platforms.
I’m really excited to learn more about your team and how I could contribute.

中文：
嗨，[名字]，很高兴今天能见到您，谢谢您抽时间与我交流。
我是 [你的名字]，目前担任高级 SRE / 云工程师。
这几年主要专注在云平台的基础设施自动化、可观测性和 CI/CD 系统建设上。
我非常期待了解您团队的工作方向，以及我能发挥作用的地方。

💡 若线上会议刚开始或需要寒暄：

English:
Can you hear me clearly?
No worries if there was a short delay — I completely understand.

中文：
您能清楚地听到我说话吗？
刚才如果有点延迟没关系，我完全理解。

🟡 面试中互动（保持自然回应）

English:
That’s a really interesting challenge.
Thanks for clarifying — that helps me understand the context better.
Let me think for a second… I’d say…

中文：
这个挑战很有意思。
谢谢您解释，这让我更清楚背景了。
让我想一下……我觉得……

🔵 收尾部分（Closing & Gratitude）

English:
Thank you very much for your time today.
I really enjoyed our conversation and learning more about the role and your team.
I’m genuinely interested in this opportunity, and I believe my background in cloud automation and reliability engineering could be a great fit.
Could you please share what the next steps in the process might look like?
Thanks again, and I look forward to hearing from you. Have a great day!

中文：
非常感谢您今天的时间。
我很享受这次交流，也更了解了岗位和团队。
我对这个机会非常感兴趣，我在云自动化与可靠性工程方面的经验应该能很好地契合岗位。
方便请您介绍一下接下来的流程吗？
再次感谢您的时间，期待您的反馈，祝您今天愉快！

✨ 可选收尾一句（灵活替换）
场景	英文表达	中文意思
轻松自然	It was great speaking with you today.	今天和您聊天很愉快。
稍微正式	Thank you for your time and consideration.	感谢您抽出时间并给予考虑。
积极热情	I’m really excited about this opportunity.	我对这个机会非常期待。
稳重专业	I look forward to the next step.	期待进入下一步流程。
