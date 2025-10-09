# IT / SRE Multi-Level Support Model (L1 / L2 / L3)

In many international companies — such as Amazon, Microsoft, IBM, Siemens, Tesla, and Cisco — the IT and SRE support systems are organized into three structured levels. This tiered model ensures efficient incident resolution, accountability, and continuous improvement through ITIL-based processes.

##  1. Overall Structure

Level	Name	Core Responsibilities	Typical Roles
L1	First-Line Support / Service Desk	Handle user requests, perform initial troubleshooting, follow SOP/KB, escalate unresolved issues	Helpdesk Engineer, IT Support
L2	Second-Line Support / Specialist Team	Perform deep diagnostics, manage monitoring systems, automate recovery, execute approved changes	System Administrator, DevOps, SRE
L3	Third-Line Support / Engineering Escalation	Conduct root cause analysis, handle complex code or design issues, drive reliability improvements	SRE Lead, Software Engineer, Platform Engineer

## Typical Workflow

Let’s take a production incident as an example to illustrate collaboration between the three levels:

- L1 – Service Desk

Receives alerts or user-reported incidents (via Ticket / Email / Chat)
Checks existing Knowledge Base or SOPs
Resolves simple cases or escalates unresolved issues to L2

- L2 – Operations / DevOps
Uses observability tools (Grafana, CloudWatch, Prometheus) to analyze metrics and logs
Validates configurations and executes predefined recovery procedures
If it’s a complex or code-related issue, escalates to L3

L3 – Engineering / Platform Team

Performs code-level debugging or component redesign
Submits patches or configuration changes via controlled Change Management
Conducts post-incident review (Postmortem / RCA) and updates the Knowledge Base for L1/L2

## 3. Management and Governance Model

Most foreign enterprises follow ITIL principles with SLA-driven governance and knowledge feedback loops.

Process	Description	Common Tools
Incident Management	Tracks and resolves system outages and incidents (MTTR, escalation path)	ServiceNow, Jira Service Desk
Problem Management	Identifies root causes, implements long-term fixes	RCA Template, Postmortem Report
Change Management	Controls and approves system changes (CAB meetings)	Change Request, Rollback Plan
Knowledge Management	Documents solutions, FAQs, SOPs for future use	Confluence, Notion, KB Portal
SLA Management	Defines response & resolution time per level	L1: 15min • L2: 1h • L3: 4h (example)

## 4. Organization Structure & Responsibility Split
```
Global IT / SRE Director
 ├── L3 Platform Engineering / SRE
 │     ├── Automation, IaC, Observability, Reliability
 │     └── Handles escalations from L2
 ├── L2 System Operations / DevOps
 │     ├── Cloud & On-Premise Maintenance
 │     ├── Incident Resolution, Deployment
 │     └── Scripting & Workflow Automation
 └── L1 Helpdesk / Service Desk
       ├── Ticket Intake, User Support
       ├── Basic Troubleshooting
       └── Escalation to L2


## 5. Example Scenarios

Scenario	L1 Action	L2 Action	L3 Action
User cannot log in	Check account status, network	Verify authentication logs, LDAP/OAuth	Fix backend authentication service or config
App running slow	Collect report details	Check container resources, HPA status	Optimize code, query, or config
Database connection failure	Notify DBA team	Validate connection pool & DB health	Patch driver or database configuration
🗣️ 6. Interview-Ready Summary

In most global companies, the IT or SRE support model follows a three-tier structure.

Level 1 (L1) is the service desk, handling user tickets, monitoring alerts, and basic troubleshooting.
Level 2 (L2) is the operations or DevOps team, responsible for deeper diagnostics, system reliability, and escalated incidents.
Level 3 (L3) is the engineering or platform team, focused on root cause analysis, performance optimization, and long-term improvements.

The process is governed by ITIL standards, SLA objectives, and knowledge sharing to ensure continuous improvement across all levels.

## 7. Key Terms (Quick Notes)

Category	Keywords
L1	“Frontline / Ticket Handling / SOP-based”
L2	“Technical Troubleshooting / System Operation / Escalation Management”
L3	“Engineering / Root Cause Analysis / Architecture Improvement”
Processes	ITIL, SLA, RCA, Knowledge Base
Tools	ServiceNow, Jira, Grafana, Prometheus, Ansible, Terraform
