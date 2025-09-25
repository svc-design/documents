Infrastructure as Code (IaC) Interview Guide

1. Definition of Infrastructure as Code
*What:* IaC treats infrastructure configuration as version-controlled source code.
*How:* Use declarative or imperative templates to define resources, manage them via pipelines, and enforce reviews plus automated testing.
*Example:* Terraform modules describe VPCs and ECS clusters, and a GitOps workflow applies changes after peer approval.

2. Declarative vs. Imperative IaC
*What:* Declarative defines desired state; imperative lists exact commands.
*How:* Choose declarative tools (Terraform, CloudFormation) for idempotent environments and imperative scripts (Ansible shell tasks) when step-by-step control is required.
*Example:* Terraform declared a Kubernetes cluster configuration, while an Ansible playbook imperatively rotated TLS certificates during migration.

3. Module and Reuse Strategy
*What:* Modularization packages repeatable infrastructure patterns.
*How:* Structure Terraform modules or CloudFormation nested stacks with inputs/outputs and semantic versioning, and publish them to internal registries.
*Example:* A shared VPC module accepted CIDR blocks and tags, enabling multiple teams to instantiate networks with consistent guardrails.

4. State Management
*What:* IaC tools need to track current resource state.
*How:* Store Terraform state in remote backends (S3 + DynamoDB locking), use state locking, and run drift detection regularly.
*Example:* Enabling DynamoDB locking prevented two engineers from applying conflicting changes simultaneously.

5. Environment Promotion Strategy
*What:* Process to move infrastructure changes from dev to prod.
*How:* Maintain separate workspaces or stacks per environment, validate with automated tests, and promote via pull requests.
*Example:* A Terraform plan applied to staging first; once approved, the same module version and variables were promoted to production.

6. Policy and Compliance
*What:* Guardrails to ensure infrastructure adheres to standards.
*How:* Use policy-as-code tools like Terraform Cloud Policy Sets, OPA, or AWS Config to enforce tagging, encryption, and network rules.
*Example:* A Sentinel policy blocked any Terraform plan lacking required cost-center tags, reducing billing surprises.

7. Testing Infrastructure Code
*What:* Validation techniques for templates and modules.
*How:* Run syntax checks (`terraform validate`), unit tests with Terratest or Kitchen, and integration tests post-deploy.
*Example:* Terratest spun up a temporary module deployment, asserted that security groups blocked unwanted ports, then destroyed the resources.

8. Secrets Management
*What:* Handling sensitive data within IaC workflows.
*How:* Integrate with secret stores (AWS Secrets Manager, Vault), use encrypted variables, and avoid committing secrets to repos.
*Example:* Terraform pulled database passwords from Vault via dynamic credentials, eliminating hardcoded secrets.

9. Drift Detection and Remediation
*What:* Identifying differences between declared and actual infrastructure.
*How:* Schedule `terraform plan` in read-only mode or use tools like AWS Config Drift Detection; reconcile by updating code or importing manual changes.
*Example:* A nightly plan detected manual IAM edits; we codified the change and enforced automation to prevent recurrence.

10. Blue-Green and Canary Infrastructure Changes
*What:* Safe rollout patterns for critical infrastructure updates.
*How:* Duplicate resources (blue/green) or gradually shift traffic (canary) with load balancers and DNS, using IaC to coordinate.
*Example:* Provisioning a new Aurora cluster in parallel let us cut over via Route 53 weighted records with minimal downtime.

11. Multi-Cloud Considerations
*What:* Managing resources across providers.
*How:* Abstract common patterns into modules, parameterize provider blocks, and centralize logging plus tagging across clouds.
*Example:* A shared Terraform module created Kubernetes clusters in both AWS (EKS) and GCP (GKE) using provider aliases.

12. IaC Security
*What:* Protecting pipelines and artifacts.
*How:* Restrict credentials, rotate access keys, sign state files or templates, and audit pipeline actions.
*Example:* CI runners used short-lived AWS STS tokens obtained via OIDC, eliminating static credentials in build systems.

13. Handling Breaking Changes
*What:* Managing disruptive updates like resource recreation.
*How:* Review plans for `destroy` actions, use `lifecycle` blocks to prevent accidental replacement, and schedule maintenance windows.
*Example:* When Terraform planned to recreate an RDS instance, we set `prevent_destroy = true` and performed a controlled migration instead.

14. Collaboration and Code Review
*What:* Team processes for IaC changes.
*How:* Require pull requests, peer reviews, and automated linting (`tflint`, `checkov`), and document module usage.
*Example:* A PR checklist ensured plans were attached, tagging standards met, and reviewers from platform and security signed off.

15. Disaster Recovery with IaC
*What:* Rebuilding infrastructure rapidly after failures.
*How:* Maintain versioned templates, automated backups of state, and run periodic game days to rehearse redeployment.
*Example:* During a DR drill we restored a VPC, ALB, and ECS services in a new region using the same Terraform modules within 45 minutes.
