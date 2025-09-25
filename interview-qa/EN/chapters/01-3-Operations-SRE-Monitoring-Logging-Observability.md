## Monitoring

### 1. Metrics, Events/Logs, Tracing, and Profiling
*What:* The four pillars of observability describe quantitative signals (metrics), discrete records (logs/events), request lifecycles (traces), and runtime resource usage (profiling).
*How:* Collect metrics for trend monitoring, centralize logs/events for forensics, instrument services with distributed tracing, and profile hot paths during performance tuning.
*Example:* A checkout outage was diagnosed by correlating elevated HTTP 500 metrics, error logs pointing to a downstream timeout, a trace showing the slow dependency, and CPU profiling confirming thread contention.

### 2. Metrics Fundamentals
*What:* Time-series measurements of system and application health.
*How:* Track resource usage, latency, error rates, and saturation; set appropriate scrape intervals and retention policies to balance fidelity with cost.
*Example:* We sampled API latency every 15 seconds, stored 30 days locally, and downsampled into long-term object storage for quarterly trend reviews.

### 3. Log Management
*What:* Structured or unstructured event records describing system state changes.
*How:* Aggregate application, system, and container logs into ELK/Loki, enrich with metadata, and apply retention plus index optimization to manage volume.
*Example:* Shipping Kubernetes pod logs via Fluent Bit into Loki let us filter by namespace and quickly trace a crash-looping deployment.

### 4. Event Handling
*What:* Notifications about important state changes such as pod lifecycle events.
*How:* Consume events through watchers or webhooks, trigger automated responses, and store critical events for correlation with incidents.
*Example:* A controller listened for FailedMount events and automatically triggered remediation by reattaching the correct persistent volume.

### 5. Distributed Tracing
*What:* End-to-end visibility across service call chains.
*How:* Instrument services with OpenTelemetry SDKs, export spans to Jaeger or Zipkin, and tune sampling to control overhead.
*Example:* Lowering sampling to 10% in off-peak hours preserved storage while still capturing enough traces to debug a sporadic gRPC timeout.

### 6. Profiling
*What:* Runtime analysis of CPU, memory, and other resource utilization within an application.
*How:* Enable profilers such as Go pprof, JVM Flight Recorder, or eBPF-based tools during load tests to identify hotspots.
*Example:* pprof revealed a JSON marshaling bottleneck, leading us to switch to a streaming encoder and cut CPU usage by 25%.

### 7. Application Performance Monitoring (APM)
*What:* Holistic monitoring of application responsiveness, throughput, and dependency health.
*How:* Deploy APM agents or OpenTelemetry collectors to gather spans, metrics, and logs; configure alert thresholds on golden signals.
*Example:* Datadog APM highlighted a slow SQL query; we added an index and watched response times drop in dashboards within minutes.

### 8. eBPF Monitoring
*What:* Kernel-level instrumentation for low-overhead observability.
*How:* Use eBPF programs via tools like BCC or Cilium to capture syscalls, network latency, and resource usage directly in the kernel.
*Example:* bpftrace scripts surfaced excessive TCP retransmits from one pod, guiding us to fix an MTU mismatch.

### 9. Agents
*What:* Daemons that collect and forward telemetry data.
*How:* Deploy node and application agents (Node Exporter, Fluentd, Telegraf, Datadog Agent) with consistent configuration management.
*Example:* Rolling out Node Exporter as a DaemonSet ensured every Kubernetes node exposed system metrics to Prometheus.

### 10. OpenTelemetry
*What:* Vendor-neutral standard for metrics, logs, and traces.
*How:* Instrument applications with language SDKs, deploy collectors to process/export data, and route to backends like Prometheus, Jaeger, or Tempo.
*Example:* A single OpenTelemetry collector pipeline fanned traces to Jaeger and metrics to Prometheus, simplifying multi-team integration.

### 11. Prometheus Workflow
*What:* Pull-based monitoring architecture with local storage and alerting.
*How:* Scrape endpoints, store time series in TSDB blocks, query via PromQL, evaluate alert rules, and route notifications through Alertmanager.
*Example:* Prometheus scraped `/metrics` every 30 seconds, Alertmanager grouped incidents, and PagerDuty escalated critical alerts to on-call engineers.

### 12. Prometheus Metric Types
*What:* Counter, Gauge, Histogram, and Summary represent different measurement semantics.
*How:* Choose counters for cumulative events, gauges for instantaneous values, histograms for latency distributions, and summaries for client-side quantiles.
*Example:* We modeled HTTP request duration as a histogram to power 95th percentile SLO alerts using `histogram_quantile()`.

### 13. Service Discovery Options
*What:* Mechanisms for Prometheus to learn scrape targets.
*How:* Configure integrations for Kubernetes, Consul, Zookeeper, DNS SRV, or static files depending on environment dynamics.
*Example:* In Kubernetes we annotated Services for scraping, while legacy VMs used file-based discovery managed by Terraform templates.

### 14. Prometheus Functions
*What:* PromQL helpers such as `rate`, `sum`, `avg`, `max`, `min`, `increase`, and `histogram_quantile`.
*How:* Combine functions to derive SLO burn rates, aggregate across labels, and compare time windows.
*Example:* `sum(rate(http_requests_total{status=~"5.."}[5m]))` alerted us to error surges aggregated across all pods.

### 15. Thanos Architecture
*What:* A Prometheus extension for long-term storage and global querying.
*How:* Deploy sidecars to upload TSDB blocks to object storage, run Store, Query, Compactor, and Ruler components for aggregation and rule evaluation.
*Example:* Thanos Query let us view metrics across three regions, while Compactor reduced storage costs by downsampling historical data.

### 16. Thanos vs. VictoriaMetrics
*What:* Alternative approaches to scalable time-series storage.
*How:* Choose Thanos to extend existing Prometheus setups with object storage, or VictoriaMetrics as a standalone high-performance TSDB compatible with Prometheus protocols.
*Example:* A greenfield observability stack adopted VictoriaMetrics single-binary mode for simplicity, whereas our legacy clusters attached Thanos to retain metrics for a year.

### 17. Thanos Sidecar vs. Receive
*What:* Components handling ingestion.
*How:* Use Sidecar alongside Prometheus for block uploads and real-time query federation; deploy Receive when you need a remote-write entry point with high availability.
*Example:* Edge clusters remote-wrote metrics to a central Thanos Receive cluster, enabling centralized alerting without local Prometheus instances.

### 18. Thanos Rule Component vs. Prometheus Rules
*What:* Distributed rule evaluation versus local-only rules.
*How:* Run Thanos Ruler to execute cross-cluster rules and store results centrally, while Prometheus evaluates rules limited to its own data.
*Example:* A global error budget rule ran in Thanos Ruler to combine metrics from multiple regions, providing a single alert for SRE on-call.

### 19. Prometheus Alert Behavior
*What:* Factors influencing alert latency and noise.
*How:* Tune scrape intervals, rule evaluation timings, and Alertmanager suppression/inhibition to reduce duplicates and ensure timely delivery.
*Example:* Increasing the evaluation interval from 1m to 30s cut detection delay, while Alertmanager inhibition prevented simultaneous alerts for parent and child services.

### 20. Pod Memory Metrics
*What:* Working Set Size (WSS) and Resident Set Size (RSS) capture container memory usage.
*How:* Use WSS to gauge actively used memory and RSS for physical footprint; cross-reference with cgroup limits to prevent evictions.
*Example:* A pod with WSS near its limit triggered proactive scaling before kubelet OOMKilled it.

### 21. Monitoring Optimization
*What:* Focus on golden signals—latency, traffic, errors, saturation—and ensure Prometheus performs efficiently.
*How:* Partition scrape targets, shard Prometheus when needed, optimize PromQL queries, and adjust sampling to manage load.
*Example:* Splitting Prometheus by namespace reduced query latency from 8s to under 1s for Grafana dashboards.

### 22. Automated Responses and Persistence
*What:* Programmatic remediation and durable storage for telemetry.
*How:* Trigger automation via Alertmanager webhooks (Ansible, Runbooks) and offload historical data to object storage or Thanos for retention.
*Example:* A webhook invoked an AWS Lambda that scaled an ASG when CPU saturation alerts fired, then logged the action for auditing.

### 23. Data Compression and Persistence
*What:* Prometheus TSDB stores blocks using compression algorithms like Gorilla for efficiency.
*How:* Rely on block compaction and retention policies, and extend with Thanos or Cortex for long-term archival.
*Example:* Weekly compaction reduced storage footprint by 40%, and offloading blocks older than 15 days to S3 kept local disks under capacity.

### 24. `kubectl top` vs. `free`
*What:* Different scopes for resource reporting.
*How:* Interpret `kubectl top` as cgroup-scoped container metrics and `free` as node-level memory, accounting for caches and kubelet overhead.
*Example:* Investigating discrepancies revealed page cache usage on the node, so we tuned eviction thresholds instead of resizing pods.

### 25. Exporters and Troubleshooting
*What:* Components exposing metrics for Prometheus scraping.
*How:* Deploy Node, Blackbox, and Redis exporters with health checks; debug target issues via Prometheus UI, logs, and scrape status.
*Example:* A failing Redis exporter returned 500s; restarting the sidecar and verifying credentials restored metrics collection.

### 26. Target Down Investigation
*What:* Process to restore unreachable scrape targets.
*How:* Check network connectivity, authentication, TLS certificates, and exporter health; review Prometheus `targets` page for error messages.
*Example:* Resolving a `connection refused` error involved opening firewall rules between Prometheus and a new subnet.

### 27. Pull vs. Push Models
*What:* Prometheus pulls metrics while systems like Zabbix often push.
*How:* Use pull for dynamic cloud-native workloads with service discovery, and push gateways or push-based systems for constrained environments.
*Example:* Batch jobs pushed metrics through Pushgateway because they terminated too quickly for direct scraping.

### 28. Prometheus Operator
*What:* Kubernetes operator that manages Prometheus, Alertmanager, and associated resources via CRDs.
*How:* Define ServiceMonitor, PodMonitor, and PrometheusRule objects to add scrape targets and alerting rules declaratively.
*Example:* Adding a new microservice involved creating a ServiceMonitor manifest; the operator handled reloading Prometheus automatically.

### 29. Monitoring External Targets
*What:* Collecting metrics from systems outside Kubernetes.
*How:* Configure additional scrape jobs in Prometheus or expose endpoints through ingress proxies and static configs.
*Example:* On-prem servers exposed metrics through an HTTPS endpoint; we added a static job with basic auth to scrape them securely.

### 30. APM and eBPF Agents Together
*What:* Complementary tooling for application and kernel insights.
*How:* Run APM agents for request-level telemetry and pair them with eBPF agents for deep system visibility.
*Example:* Combining New Relic APM with Pixie (eBPF) provided SQL query traces and kernel packet captures during a latency spike.

### 31. OpenTelemetry Recap
*What:* Unified observability spec supporting exporters to multiple backends.
*How:* Standardize instrumentation across teams, reuse collectors, and map attributes consistently for cross-cutting analysis.
*Example:* Migrating from vendor-specific agents to OpenTelemetry simplified onboarding of new microservices.

### 32. Building an Observability Platform
*What:* End-to-end system aggregating metrics, logs, traces, and profiles.
*How:* Integrate data sources via a centralized pipeline, ensure redundancy, implement role-based access, and design dashboards plus alerting aligned to SLOs.
*Example:* A platform combining Prometheus, Loki, Tempo, and Grafana provided unified views; HA deployments across two regions sustained observability during maintenance.

---

## ELK

### 1. Elasticsearch Indexing Principle
*What:* ES stores documents across shards backed by Lucene indexes.
*How:* Incoming documents write to a transaction log and in-memory buffers before periodic flushes to immutable segment files.
*Example:* Monitoring translog size helped us tune flush intervals to avoid memory pressure during bulk indexing.

### 2. Elasticsearch Storage Principle
*What:* Data persists as compressed segment files organized by shard.
*How:* Manage shard count, replica placement, and snapshot policies to balance performance with durability.
*Example:* Reducing shard count from 10 to 5 per index improved search latency by decreasing segment merges.

### 3. Elasticsearch Performance Optimization
*What:* Techniques to keep indexing and search responsive.
*How:* Optimize mappings, use doc values for aggregations, adjust refresh intervals, and scale nodes based on workload.
*Example:* Disabling `_all` fields and switching to keyword subfields cut index size by 20% and sped up aggregations.

### 4. Elasticsearch Architecture Design
*What:* Cluster roles including master-eligible, data, ingest, and coordinating nodes.
*How:* Separate dedicated masters for stability, size data nodes for storage and query load, and place ingest pipelines near data sources.
*Example:* Deploying three dedicated masters prevented split-brain events when scaling data nodes for log ingestion spikes.
