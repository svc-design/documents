## AWS Foundations and Architecture

| Category | Services | Key Points |
|:----|:----|:----|
| Compute | EC2 | Elastic compute instances with On-Demand/Reserved/Spot pricing |
|  | Lambda | Serverless, event-driven functions |
|  | ECS / EKS | Container orchestration; EKS is managed Kubernetes |
|  | Elastic Beanstalk | PaaS for quick application deployment |
| Storage | S3 | Object storage with classes (Standard, IA, Glacier) and lifecycle policies |
|  | EBS | Block storage attachable to EC2 |
|  | EFS | Shared file system across instances |
| Networking | VPC | Virtual private cloud with subnets, route tables, and public/private zones |
|  | ELB (ALB/NLB/CLB) | Layer 7/4 load balancing |
|  | CloudFront | Global CDN |
|  | Direct Connect / VPN | Hybrid connectivity |
| Database | RDS | Managed relational databases (MySQL/Postgres/Aurora) |
|  | DynamoDB | Highly available NoSQL |
|  | Aurora | AWS-managed, MySQL/Postgres-compatible |
|  | ElastiCache | Redis / Memcached caching |
| Identity & Security | IAM | Users, roles, policies, least privilege |
|  | KMS | Encryption key management |
|  | Cognito | Application user authentication |
|  | GuardDuty / WAF / Shield | Threat detection and protection |
| Monitoring & Ops | CloudWatch | Metrics, logs, alerts |
|  | CloudTrail | API call auditing |
|  | Config | Compliance and drift tracking |
|  | Systems Manager (SSM) | Operations automation and parameter store |
| DevOps / IaC | CloudFormation | AWS-native infrastructure as code |
|  | Terraform | Multi-cloud infrastructure as code |
|  | CodePipeline / CodeBuild / CodeDeploy | AWS CI/CD toolchain |
|  | GitHub Actions + ArgoCD | Common pattern: CI on GitHub, CD via GitOps |


**Q: Which AWS services do you use most often?**
*What:* Core building blocks across compute, storage, database, identity, and monitoring.
*How:* Combine EC2 or EKS for workloads, store assets in S3, manage data with RDS, protect access via IAM, and observe health through CloudWatch.
*Example:* A production microservice stack ran on EKS with pods pulling configuration from S3, RDS for persistence, IAM roles for service accounts, and CloudWatch dashboards tracking latency.

**Q: How would you design a highly available three-tier architecture on AWS?**
*What:* A resilient web, application, and database topology across availability zones.
*How:* Place web tier instances behind an ALB, run autoscaled containers on EKS/ECS, replicate databases with RDS Multi-AZ or Aurora read replicas, and front everything with CloudFront plus monitoring and security services.
*Example:* For an e-commerce site we deployed ALB-backed EKS pods across three AZs, used Aurora with an async replica, cached static assets with CloudFront, and wired GuardDuty alerts into Slack.

### Infrastructure as Code and Automation

**Q: How do you manage AWS resources with Terraform?**
*What:* Declarative IaC to provision and version infrastructure.
*How:* Break environments into reusable modules, store state in S3 with DynamoDB locking, and gate changes through PR-triggered `terraform plan` and `apply` workflows.
*Example:* A network module built VPC, subnets, and security groups; GitHub Actions ran `plan` on pull requests and applied after approval, giving us auditable changes.

**Q: How do you compare Terraform with CloudFormation?**
*What:* Two popular IaC solutions for AWS.
*How:* Favor Terraform for multi-cloud flexibility and community modules, while choosing CloudFormation for AWS-native features and tighter service integration.
*Example:* We used Terraform to manage shared services across AWS and GCP, but relied on CloudFormation StackSets to roll out GuardDuty organization-wide.

### CI/CD

**Q: How do you design CI pipelines with GitHub Actions?**
*What:* Automated checks that validate and package code.
*How:* Define workflows that lint, run unit tests, build container images, leverage caching, and push to ECR with matrix testing where needed.
*Example:* The main branch workflow linted Python code, executed pytest across Python versions 3.9 and 3.11, then built and pushed an image to ECR using cached dependencies to shorten runtime.

**Q: How do you implement CD with ArgoCD?**
*What:* GitOps-based continuous delivery to Kubernetes.
*How:* Point ArgoCD at Helm charts or manifests in Git, enable auto-sync with health checks, and integrate Argo Rollouts for progressive delivery.
*Example:* Updating a canary Service manifest triggered ArgoCD to sync, run analysis via Argo Rollouts, and automatically promote the release after success metrics passed.

### Monitoring and Operations

**Q: How do you monitor CI/CD pipelines?**
*What:* Visibility into build and deploy health.
*How:* Send GitHub Actions status to chat channels, expose ArgoCD sync metrics to Prometheus, alert via Alertmanager, and visualize latency/error budgets in Grafana.
*Example:* A Slack webhook posted failed builds instantly, while Grafana panels highlighted ArgoCD sync errors that signaled drift in staging clusters.

**Q: Have you faced Terraform or CI/CD failures? How did you handle them?**
*Situation:* `terraform apply` failed during a networking change.
*Task:* Restore pipeline stability without risking production.
*Action:* Ran `terraform plan` to inspect drift, isolated the misconfigured security group, and reverted via version control while notifying stakeholders.
*Result:* The pipeline recovered on the next run, and we added a pre-merge validation step to catch similar errors earlier.

### Behavioral

**Q: How would you handle conflicts between Dev and SRE teams?**
*Situation:* Development pushed for rapid feature rollout while SRE flagged reliability risks.
*Task:* Align both teams on a data-driven decision.
*Action:* Facilitated a session to review SLOs, error rates, and cost implications, then proposed a phased canary rollout with extra monitoring.
*Result:* Both teams agreed to the compromise, the rollout succeeded without incidents, and trust between teams improved.

⚡ Tips:
- Use **What → How → Example** for technical answers.
- Apply the **STAR method** for behavioral questions.
- Keep English responses clear, concise, and confident.
