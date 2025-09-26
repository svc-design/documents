Landing Zone is basically the cloud baseline for multi-account setup. On AWS Global you have Control Tower, in AWS China you build it manually, and on Alibaba Cloud you use solution blueprints for local compliance.”

In short, a Landing Zone is not just one thing — it’s a package. You need multi-account structure, identity and access, network baseline, logging, compliance, cost control, and you automate all of this with Infrastructure as Code.”

Landing Zone usually covers these main areas:

- Multi-account governance → how you create and manage multiple accounts in a structured way.
- Identity management → setting up IAM or SSO so users get the right access.
- Network baseline → standard VPC, connectivity, and security controls.
- Logging & audit → make sure all activity goes into a central log account.
- Compliance checks → continuous config and security rules to meet standards.
- Cost and budget → track usage, set budgets, avoid overspending.
- Infrastructure as Code (IaC) → use Terraform or CloudFormation to make the setup repeatable and consistent.

1. How would you design a secure multi-account landing zone?

👉 Multi-account governance (Organizations / Resource Directory), centralized logging, IAM/SSO, network baseline (VPC + TGW/CEN), compliance with Config/Security Hub, cost tagging, all via IaC (Terraform/ROS).

2. How do you manage Terraform state and secrets safely?

👉 Remote backend (S3+Lock / OSS)，state locking，secret via Vault/SOPS or CI secrets，never commit plaintext secrets.

3. What’s your approach to cost control in a Landing Zone?

👉 Use tagging strategy, enable budgets/alerts, analyze with Cost Explorer/费用中心, restrict instance types in Terraform, prefer Spot/Savings Plan for non-prod.

4. Can you give an example of enforcing compliance with IaC?

👉 Use OPA/Conftest to scan Terraform code, enforce policies (e.g., all S3 buckets encrypted), fail pipeline if non-compliant.

5. How do you handle rollback if a Terraform apply breaks production?

👉 Always terraform plan first, keep state versioning (S3 with versioning), if failed, use terraform destroy -target or roll back to last good commit/state snapshot.

6. How do you integrate infrastructure changes into CI/CD?

👉 GitOps style: push → CI runs plan → MR approval → apply. Separate workflows for dev/uat/prod, production requires manual approval. Store plans as artifacts for review.
