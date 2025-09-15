
Case 1 – Sweet Orange Finance

Background

Financial industry, IDC deployment, serving consumer payment users.

Large internal network and mirrored traffic. Single collector node: 10G / 2mPPS.

Two data centers (Nanjing & Wuhu) with a total of 20G mirrored traffic, covering 3–5 business clusters (K8s, ~250 nodes).

DeepFlow Value

Provides Layer-4 network metrics.

Supports flow logs and packet capture (pcap) for deep analysis.

Challenges

Stability of out-of-band traffic collection system.

ClickHouse query performance bottlenecks.

Risk of packet loss under burst traffic.

Case 2 – Maitang

Background

Runs on AWS public cloud.

Heavy traffic during business peaks, requiring monitoring of specific API endpoints.

DeepFlow Value

Provides Layer-7 call tracing.

Ensures observability of API call chains in the cloud.

Challenges

Flexible, on-demand data collection.

Guaranteeing no packet loss while maintaining full and accurate tracing.

Case 3 – COSCO Shipping

Background

Exploring AI-driven IT operations.

DeepFlow Value

AI Agent PoC for business inspection and root cause analysis.

Other References

China Telecom Jiangsu: Telco network observability.

Shanghai Electric Power: Business-critical system observability & compliance.

Guotai Junan Futures: Financial trading system network & application monitoring.
