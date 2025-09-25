## DevOPS

1. Optimizing GitLab Runner
*What:* Techniques to accelerate GitLab CI jobs.
*How:* Scale runners horizontally for parallel jobs, enable dependency caching and artifacts, right-size compute resources, and dedicate runners per workload type.
*Example:* Adding GPU-tagged runners for ML pipelines cut build time by 40% while caching Python wheels avoided repeated downloads.

2. Blue-Green, Gray, and Canary Releases Across Clusters
*What:* Progressive delivery strategies for multi-cluster deployments.
*How:* Maintain blue/green environments for instant traffic switchovers, roll out gray releases by gradually expanding user cohorts, and run canary releases by routing a small traffic percentage before scaling up.
*Example:* A payment service promoted updates cluster by cluster using canary weights in Istio, observing metrics before executing the global blue-to-green cutover.

3. Shift-Left Testing
*What:* Moving testing earlier in the development lifecycle.
*How:* Embed unit, integration, and security tests in CI pipelines triggered on pull requests, and provide developers with local environments mirroring production.
*Example:* Running API contract tests during pre-merge checks caught schema regressions before they reached staging, reducing rework.

4. GitOps Fundamentals
*What:* Operating model that stores desired infrastructure and application state in Git.
*How:* Use Git repositories as the source of truth, reconcile actual state via agents like Argo CD or Flux, and manage changes through pull requests.
*Example:* A cluster configuration repo triggered Argo CD auto-sync; merging a PR updated ConfigMaps and Deployments within minutes.

5. Backing Up GitLab Repositories
*What:* Ensuring source code durability.
*How:* Schedule GitLab backups, mirror repositories to secondary remotes, and script database plus artifact snapshots.
*Example:* Nightly `gitlab-backup create` jobs uploaded archives to S3, while mirroring to GitHub provided quick disaster recovery.

6. Troubleshooting Jenkins Build Failures
*What:* Systematic approach to restore failing pipelines.
*How:* Review console logs, validate pipeline configuration, confirm dependency availability, and reproduce steps locally.
*Example:* A failing Docker build was traced to an expired registry token after reproducing the `docker login` step on the agent.

7. Jenkins User Permission Management
*What:* Controlling access within Jenkins.
*How:* Configure role-based access plugins, assign global vs. project-level permissions, and audit user actions regularly.
*Example:* Creating a read-only viewer role let QA teams inspect pipeline status without risking job configuration changes.

8. Jenkins Pipeline Modes
*What:* Declarative and scripted pipeline syntaxes.
*How:* Use declarative syntax for standardized stages and scripted pipelines for advanced logic when needed.
*Example:* A declarative pipeline handled typical build/test steps, while a scripted block iterated through dynamic microservice lists.

9. Jenkins High Availability
*What:* Architecture to minimize downtime.
*How:* Deploy redundant masters with shared state or operate an active/passive setup, distribute agents, load balance inbound requests, and back up `JENKINS_HOME`.
*Example:* Placing Jenkins masters behind an HAProxy VIP enabled seamless failover during maintenance windows.

10. Master-Agent Coordination
*What:* Division of responsibilities between Jenkins controller and agents.
*How:* Let the controller schedule jobs and manage configuration while agents execute builds over inbound/outbound connections.
*Example:* Labeling Windows agents ensured .NET builds landed on compatible executors without manual routing.

11. Multi-Stage Pipelines
*What:* Structured sequences for CI/CD.
*How:* Define stages for compile, test, security scan, package, and deploy, with parallelized steps and gated approvals.
*Example:* A pipeline ran unit tests and SAST in parallel before requiring manual approval to deploy to production.

12. Argo Rollouts Strategies
*What:* Progressive delivery mechanisms within Kubernetes.
*How:* Configure blue-green strategies with separate services, or define canary steps adjusting traffic weights and analysis templates.
*Example:* Argo Rollouts gradually shifted 5%, 25%, 50%, then 100% of traffic to a new API while monitoring Prometheus metrics.

13. Argo CD Application CRD
*What:* Custom resource that defines a Git-tracked application target.
*How:* Specify repo URL, revision, destination cluster, namespace, and sync policies in the Application manifest.
*Example:* Updating the Application CRD to include a Helm value override deployed a new feature flag automatically.

14. Auto-Sync vs. Manual Sync in Argo CD
*What:* Deployment control modes.
*How:* Enable auto-sync for rapid reconciliation or require manual sync to gate changes via UI/CLI approvals.
*Example:* Production apps used manual sync with change windows, while dev clusters auto-synced on merge to main.

15. Argo CD Troubleshooting
*What:* Steps to diagnose sync issues.
*How:* Inspect application events, review pod logs, compare live vs. desired manifests, and adjust sync options like pruning or self-heal.
*Example:* Resolving a sync error involved fixing a missing namespace annotation that prevented resource creation.

16. Custom Health Checks in Argo CD
*What:* Extended health assessments beyond defaults.
*How:* Add Lua-based health scripts in the repo to evaluate CRD status conditions and surface accurate health states.
*Example:* A custom check read CRD `.status.phase` to mark Kafka topics as Healthy only when partitions were ready.

17. Handling Drift in Argo CD
*What:* Reconciling differences between cluster state and Git.
*How:* Allow Argo CD to auto-correct drift or manually sync, and investigate unauthorized changes before reconciling.
*Example:* Detecting manual ConfigMap edits prompted a conversation with the developer before reverting to the Git-defined version.

18. Monitoring CI/CD Processes
*What:* Observability for build and deploy pipelines.
*How:* Export metrics to Prometheus, visualize in Grafana, analyze logs, and configure alerting on failure rates or queue latency.
*Example:* Alertmanager notified on-call when deployment duration exceeded SLOs, revealing a throttled container registry.

19. Git Feature Branch Workflow
*What:* Standard branching strategy for new features.
*How:* Branch off main, implement changes, commit frequently, open a pull request for review, merge after approval, and delete the branch.
*Example:* Feature branches triggered preview environments via PR automation, enabling product managers to validate UI updates.

20. Resolving Git Merge Conflicts
*What:* Steps to reconcile divergent changes.
*How:* Fetch latest main branch, rebase or merge into the feature branch, resolve conflicts in files, test, and push updates.
*Example:* Using `git rebase main` exposed overlapping edits; we coordinated with another developer to split changes cleanly.

