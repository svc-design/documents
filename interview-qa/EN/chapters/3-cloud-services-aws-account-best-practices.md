AWS IAM vs Alibaba Cloud RAM — Best Practices (Interview English)

1. Development

In AWS, I use IAM roles with STS and OIDC, so developers and CI/CD pipelines get short-lived credentials instead of static keys.

In Alibaba Cloud, I use RAM users with MFA for login, and also OIDC + AssumeRole for CI/CD pipelines.

👉 Best practice: always go with OIDC and temporary credentials in dev, no long-term keys.

2. Operations (Production)

In AWS, I assign IAM roles, separate read-only and ops roles, and set permission boundaries. I also audit with CloudTrail and IAM Access Analyzer.

In Alibaba Cloud, I use RAM user groups with MFA, monitor with ActionTrail, and set custom policies like “no delete VPC.”

👉 Best practice: minimal permissions, group management, plus audit logs for compliance.

3. Cross-Account

In AWS, I rely on Organizations with SCP to enforce guardrails, and cross-account AssumeRole for access. SSO is unified through IAM Identity Center.

In Alibaba Cloud, I use Resource Directory to manage multiple accounts, push down control policies, and authorize with RAM roles across accounts.

👉 Best practice: always cross accounts via roles, never by sharing keys.

4. Multi-Cloud

In AWS, I integrate external IdPs like Okta or OIDC, then use STS roles for tools like Terraform or ArgoCD.

In Alibaba Cloud, I do the same with SAML or OIDC federation, and RAM roles with temporary tokens.

👉 Best practice: one corporate IdP across all clouds, and only roles with short-lived credentials.

🎯 One-line Summary

“The core principle is the same: least privilege, temporary credentials, and identity federation. AWS leans on Organizations and SCP, Alibaba Cloud relies on Resource Directory and control policies.”

i


1. Basic Positioning

AWS IAM (Identity and Access Management)
A unified access management service for users, roles, and policies. Almost all AWS services are controlled through IAM.

Alibaba Cloud RAM (Resource Access Management)
Similar to IAM, RAM manages user identities, roles, and permissions under an Alibaba Cloud account.

2. Use Cases

AWS IAM

Assign least-privilege permissions to team members, for example, allowing a user to access only a specific S3 bucket.

Create IAM roles for applications and attach them to EC2/EKS services to obtain temporary credentials for API calls.

Enable cross-account trust and federated authentication (SAML/AD, OIDC).

Alibaba Cloud RAM

Assign fine-grained permissions to sub-accounts (RAM users), such as restricting access to a specific RDS database.

Grant ECS or ACK (Alibaba Kubernetes Service) permissions to access OSS or Log Service through RAM roles.

Support cross-account role assumption (similar to AssumeRole) for enterprise-level multi-account collaboration.

3. Core Concept Comparison
Feature	AWS IAM	Alibaba Cloud RAM
User	IAM User	RAM User
Group	IAM Group	RAM User Group
Temporary Creds	STS (AssumeRole)	STS (AssumeRole)
Policy	JSON Policy (Allow/Deny)	JSON Policy (Allow only, no explicit Deny)
Role	IAM Role	RAM Role
Federation	SAML / OIDC	SAML / OIDC
4. Policy Examples

AWS IAM Policy (Read-only S3)

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::example-bucket/*"]
    }
  ]
}


Alibaba Cloud RAM Policy (Read-only OSS)

{
  "Version": "1",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["oss:GetObject"],
      "Resource": ["acs:oss:*:*:example-bucket/*"]
    }
  ]
}


Difference: AWS policies support both Allow and Deny. RAM policies only support Allow; in case of conflicts, the principle of least privilege applies.

5. Operational Practices

AWS IAM

Recommended to use IAM roles with temporary STS credentials instead of long-term access keys.

For multi-account setups, combine with AWS Organizations and manage baselines using SCP (Service Control Policies).

Alibaba Cloud RAM

Similarly, replace long-term AK/SK with STS temporary credentials.

For multi-account scenarios, use Resource Directory for centralized management, while RAM handles fine-grained access.

Since RAM does not support explicit Deny, blacklist controls need to be implemented through Access Control or Config/Audit services.

6. Summary

Similarities: Core concepts (user, group, role, policy, STS) are aligned. Typical use cases involve “user management,” “application/service roles,” and the principle of least privilege.

Differences:

AWS IAM policies are more powerful, supporting explicit Deny and conditional expressions.
Alibaba Cloud RAM is less flexible, but when combined with Resource Directory and Security Center, it can achieve enterprise-level governance.
