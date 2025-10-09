# Interview Recap — SRE Technical Interview

- Role: Senior Site Reliability Engineer
- Interviewer: Technical Lead / Infrastructure Manager
- Duration: ~45 minutes
- Format: English, technical Q&A + self-introduction + open discussion

## 1. Introduction

Interviewer: “Please introduce yourself briefly.”
You (summary):

I’m an experienced SRE and DevOps engineer with strong hands-on skills in infrastructure automation and observability.
I’ve worked on both self-managed Kubernetes clusters and cloud-managed ones like EKS, focusing on Terraform-based IaC, CI/CD pipelines, and monitoring with Prometheus and Grafana.
In my previous role, our team was organized by support levels — L1 handled operations, L2 handled incidents, and L3 handled automation and reliability engineering. My role was mainly at L3, building automation and monitoring frameworks.

## 2. Technical Questions

Q1. Terraform & Kubernetes Management

Question: How do you manage both self-hosted Kubernetes clusters and cloud-managed ones? Do you use Ansible?

You (key points):

Yes, I’ve used Terraform for provisioning and Ansible for configuration management.
For on-prem Kubernetes, I automate installation via kubeadm and Ansible, including Calico networking and node joining.
For cloud environments like EKS or ACK, Terraform modules manage VPC, node groups, and add-ons.
I version everything through Git and use GitHub Actions for automated plan/apply workflows with environment separation (dev/staging/prod).

### Q2. Resource Elasticity and Application Auto-Scaling

Question: How do you handle resource elasticity and app auto-scaling?
You (key points):

- I combine Cluster Autoscaler (CA) and Horizontal Pod Autoscaler (HPA).
- CA automatically adjusts node counts based on pending pods.
- HPA monitors metrics (CPU, memory, or custom metrics from Prometheus Adapter) and scales the pods.
- In some workloads, we also used Vertical Pod Autoscaler (VPA) to recommend optimal resource requests.
- All scaling policies are integrated into Helm charts for repeatable deployment.

### Q3. CI/CD Pipelines

Question: What’s your experience with CI/CD tools — Jenkins, GitLab CI, GitHub Actions, or AWS CodePipeline?

You (key points):
I’ve built CI/CD pipelines with all three.
Jenkins: traditional, flexible, but heavy maintenance.
GitLab CI: YAML-based and tightly integrated with GitLab repos.
GitHub Actions: lightweight, easy to reuse with composite actions — currently my preferred choice.

AWS CodePipeline: used for integrating Lambda and ECS deployments with IAM roles.
In most cases, I use GitHub Actions for multi-platform builds and Terraform automation.

### Q4. Database Administration

Question: Do you have database management experience?

You (key points):
- Yes, mainly with PostgreSQL and MySQL.
- I manage database provisioning through Terraform and automate user/backup policies via Ansible.
- I’ve also implemented logical replication (pglogical) for multi-region data sync and perform regular performance tuning using pg_stat_statements and slow query logs.
- For observability, metrics are exported to Prometheus and visualized in Grafana.

### Q5. Observability (Logs, Metrics, Traces)

Question: How do you approach observability?

You (key points):

My observability stack follows the three pillars:

- Metrics: Prometheus + Grafana
- Logs: Loki or OpenSearch (depending on AWS or self-managed)
- Traces: OpenTelemetry Collector + Tempo
In AWS, I’ve also worked with CloudWatch, X-Ray, and OpenSearch Service — roughly the “AWS Observability Trio”.
In hybrid environments, I integrate Loki and Tempo for unified tracing and logging correlation.

3. Your Question to the Interviewer

You asked:

“For this position, does the SRE role focus mainly on infrastructure automation, or does it also cover application-level monitoring and reliability?”

Interviewer:

Good question — the role mainly focuses on infrastructure, but we expect collaboration with the application teams to define meaningful SLIs and SLOs.


## Interview Reflection (Self-Review)

Aspect	Evaluation	Comments

Technical Coverage	✅ Strong	Covered IaC, K8s, CI/CD, Observability
Communication Clarity	👍 Good	Clear structure and examples; slight grammar hesitation under stress
Domain Depth	✅ Solid	Good understanding of AWS and self-managed systems
Missing / Improvement	⚠️ Moderate	Could expand on incident response & reliability culture (SLOs, error budgets)
Next Step	🧭	Prepare STAR stories for reliability incidents, scaling challenges, and automation ROI

## Suggested Practice (Mock Interview Format)

Q: How do you ensure reliability across multiple Kubernetes clusters?
A: I use GitOps-based configuration management with FluxCD or ArgoCD, ensuring consistency. Combined with Prometheus Alertmanager and synthetic probes, we continuously verify cluster health.

Q: Describe a challenging incident you resolved.
A: A misconfigured HPA caused cascading pod restarts. I used metrics from Prometheus to identify high memory pressure, tuned resource requests, and introduced VPA recommendations to stabilize autoscaling.

Q: What do you consider the most important metric for SRE success?
A: Error budget consumption and MTTR — because they directly reflect user impact and operational efficiency.
