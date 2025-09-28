#AWS / IaC / Container Release – Interview Quick Answers

针对 运维（SRE/DevOps/Infra）技术面试，重点放在 AWS、IaC、容器应用发布。
层级分为：

Level 1 基础问题 (Fundamentals) → 核心概念 & 实操
Level 2 进阶问题 (Intermediate) → 架构设计 & 流程
Level 3 终极场景题 (Advanced / Final Round) → 系统性场景 & 故障演练

每题给你：Question → Reference Answer (key points)。

🧑‍💻 SRE/DevOps/Infra Interview Q&A (AWS, IaC, Containers)
🔹 Level 1 – Fundamentals

Q1. What’s the difference between EC2, ECS, and EKS in AWS? When would you use each?
A (key points):

EC2 → raw VMs, full control, good for legacy or special workloads.
ECS → AWS-native container orchestration, simpler than Kubernetes.
EKS → managed Kubernetes, best for multi-cloud or complex microservices.

Choice depends on control vs. simplicity vs. portability.

Q2. How do you manage Terraform state in a team environment?
A (key points):

Store remote state in S3 with DynamoDB locking.
Use workspaces or folder structure for dev/stage/prod.
Protect with versioning + encryption.
Run Terraform via CI/CD pipelines, not locally.

Q3. What’s a CrashLoopBackOff in Kubernetes, and how would you troubleshoot it?
A (key points):

Pod repeatedly crashes after starting.
Common causes: misconfigured image, missing env vars, livenessProbe failing.
Steps: kubectl describe pod, check logs, verify config/health checks.
Fix: correct config, adjust probes, rebuild image.

🔹 Level 2 – Intermediate

Q4. How do you design a multi-account AWS environment for a client project?
A (key points):

Use AWS Organizations + Control Tower for governance.
Separate accounts: security/logging, shared services, dev, prod.
Centralized logging & monitoring (CloudTrail, Config, GuardDuty).
Apply SCPs (Service Control Policies) for compliance.

Q5. How do you implement a safe deployment pipeline for containerized apps on EKS?
A (key points):

GitOps pipeline: GitHub Actions → ArgoCD/Flux → EKS.
Deployment strategies: rolling, blue/green, canary.
Automated rollback: Prometheus metrics → alert triggers.
Security: image scanning, signed images, least-privilege IAM roles.

Q6. What’s your rollback strategy if a Terraform apply fails in production?
A (key points):

Use plan + manual approval before apply.
Rollback: redeploy last known good state from Git history.
Protect critical resources with lifecycle prevent_destroy.
Detect drift regularly with terraform plan.

🔹 Level 3 – Advanced / Final Round

Q7. Imagine a new application deployment on EKS caused 50% of requests to fail. Walk me through your response.
A (key points):

Detect & declare incident: monitor alerts, assign roles (commander, fixers).

Mitigation: rollback via ArgoCD or deploy stable version.
Investigation: check logs, metrics, service mesh traffic.
Communication: inform stakeholders, give ETA.
Post-mortem: root cause analysis, add tests/monitors to prevent recurrence.

Q8. How would you enforce compliance and security in IaC workflows for a regulated client (finance, healthcare)?
A (key points):

Pre-commit hooks to validate code.
OPA/Conftest or Terraform Cloud policies for compliance (e.g., encrypted storage only).
Mandatory code reviews in GitHub/GitLab.
Audit logs for every IaC change.

Q9. If you joined us as an Ops Engineer, what would be your 90-day plan?
A (key points):

First 30 days: assess infra, pipelines, costs, incident processes.
Next 30 days: standardize IaC modules, improve CI/CD with approval gates.
Last 30 days: optimize reliability (autoscaling, monitoring), knowledge transfer to client teams.

Q10. Tell me about a major incident you resolved. What was your role and the outcome?
A (key points):

Situation: high-traffic outage after release.
Task: restore service quickly.
Action: rolled back release, diagnosed root cause (bad config), improved pipeline.
Result: downtime <30 min, new runbook + automated rollback introduced.

✅ 总结

基础问题考察你是否掌握核心概念 (EC2/ECS/EKS, Terraform state, CrashLoopBackOff)。
进阶问题看你是否能设计体系化方案 (multi-account AWS, GitOps, rollback)。
终极场景题则是全面考察你的 运维思维 + 故障处理能力 + 合规意识 + 交付经验。

## 面试口语速答版（3–4 句/题）

🔹 Level 1 – Fundamentals

Q1. EC2 vs ECS vs EKS
👉 “EC2 gives full VM control, good for legacy workloads. ECS is simpler, AWS-managed containers. EKS is managed Kubernetes, better for portability and complex microservices. I’d choose based on control vs. simplicity vs. multi-cloud needs.”

Q2. Terraform state management
👉 “I store state remotely in S3 with DynamoDB locking. Each env uses workspaces or separate state files. We run Terraform in CI/CD, not locally, to avoid conflicts.”

Q3. CrashLoopBackOff troubleshooting
👉 “It means the pod keeps crashing after start. I’d check logs and kubectl describe to see if it’s config, env vars, or probes. Usually it’s a bad config or failing health check.”

🔹 Level 2 – Intermediate

Q4. Multi-account AWS design
👉 “I’d use AWS Organizations and Control Tower. Separate accounts for prod, dev, logging, security. Apply SCPs and centralize logs with CloudTrail and Config.”

Q5. Safe EKS deployments
👉 “I’d go GitOps with ArgoCD. Use rolling or canary deployments with metrics-based rollback. Add autoscaling and image scanning for security.”

Q6. Terraform rollback strategy
👉 “We always plan and review before apply. If something fails, redeploy the last good version from Git. I protect critical resources with prevent_destroy and run drift checks.”

🔹 Level 3 – Advanced / Final Round

Q7. Handling failed EKS deployment
👉 “First, declare an incident and assign roles. Roll back to a stable version to restore service. Then check logs and metrics, keep stakeholders updated, and run a post-mortem after.”

Q8. Enforcing IaC compliance
👉 “I’d use OPA or Conftest in the pipeline to block non-compliant code. All changes go through code review, and every IaC change is logged. This way we meet security standards.”

Q9. 90-day plan as Ops Engineer
👉 “First month I’d assess infra, pipelines, and costs. Second month I’d standardize Terraform modules and add compliance gates. Third month I’d improve reliability, autoscaling, and mentor the team.”

Q10. Example of major incident
👉 “We had an outage after a bad release. I rolled back quickly, found a config error, and updated the pipeline. Downtime stayed under 30 minutes, and we added an automated rollback.”

