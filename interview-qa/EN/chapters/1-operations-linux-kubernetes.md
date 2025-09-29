## Linux commands && K8s troubleshooting

### Linux System topic

1. Combining grep, sed, awk, and cut
*What:* Classic Linux text-processing utilities that parse and transform structured or semi-structured data.
*How:* Pipe commands so that `grep` filters lines, `awk` extracts or computes fields, `sed` rewrites text, and `cut` trims columns.
*Example:* `grep ERROR app.log | awk '{print $5}' | sed 's/://g' | cut -d',' -f1` isolates the failing component name from log entries.

2. HTTP error codes and causes
*What:* Standardized status codes that describe request outcomes between clients and servers.
*How:* Map each code family (4xx client issues, 5xx server faults) to remediation steps such as checking routing rules, backend health, or permissions.
*Example:* When a deployment surfaced repeated 502 errors, I validated the load balancer health checks and discovered a crashed upstream pod.

3. Long connection, short connection, and WebSocket
*What:* Different communication patterns for TCP-based services.
*How:* Use persistent long connections for stateful or chatty backends, short connections for stateless REST calls, and WebSockets for bidirectional real-time updates.
*Example:* A trading dashboard kept a WebSocket open to stream live quotes, while its REST API used short-lived HTTPS calls for order submissions.

4. Nginx performance optimization methods
*What:* Tunable parameters and modules that improve throughput and latency.
*How:* Adjust worker counts, enable caching and compression, reuse upstream connections, and profile slow upstreams.
*Example:* Increasing `worker_connections` and enabling `proxy_cache` cut our API gateway latency by 30% under load testing.

5. LVS vs. Nginx vs. HAProxy
*What:* Common load-balancing technologies across layers 4 and 7.
*How:* Select LVS for ultra-high L4 throughput, Nginx for HTTP-aware routing, and HAProxy when you need mixed L4/L7 features with rich health checks.
*Example:* We placed LVS at the edge for TCP fan-out, then HAProxy in front of microservices to route traffic based on HTTP headers.

6. Zombie process definition and handling
*What:* A child process that finished but whose exit status was never reaped by its parent.
*How:* Monitor processes stuck in state `Z`, send signals to the parent, or adopt them with `init` by terminating the parent if needed.
*Example:* After spotting zombies with `ps aux | grep Z`, we patched the supervisor to call `waitpid()` after each worker exit.

7. Process, thread, and coroutine differences
*What:* Execution units with varying isolation and scheduling.
*How:* Use OS-managed processes for isolation, threads for shared-memory parallelism, and coroutines for cooperative concurrency within a thread.
*Example:* In a scraping tool we ran multiple processes for site isolation, threads for I/O concurrency, and coroutines in Python's asyncio for non-blocking requests.

8. Nginx asynchronous non-blocking mode
*What:* Event-driven architecture that handles many connections with minimal threads.
*How:* Leverage the `epoll` loop so each worker processes I/O readiness events instead of blocking on sockets.
*Example:* Switching a blocking upstream module to the async upstream API allowed one worker to handle thousands of keepalive connections.

9. Troubleshooting network packet loss in Linux
*What:* Systematic approach to locate the failing hop or component.
*How:* Start with `ping` and `traceroute`, inspect interface counters via `ip -s link`, and capture traffic with `tcpdump` for deeper analysis.
*Example:* We traced intermittent loss to CRC errors on a NIC, confirmed with `ethtool -S eth0`, and replaced the faulty cable.

10. Performance analysis and diagnostic commands
*What:* Tooling to monitor CPU, memory, disk, and network usage.
*How:* Combine utilities like `top`, `vmstat`, `iostat`, `sar`, `strace`, and `lsof` based on the suspected bottleneck.
*Example:* When disk latency spiked, `iostat -xz 1` revealed a single partition with near-100% utilization caused by a runaway backup job.

11. Process interruption, soft interrupt, hard interrupt
*What:* Mechanisms that preempt CPU execution to handle events.
*How:* Understand that software interrupts (softirqs) handle kernel-level tasks like networking, while hardware interrupts respond to device signals.
*Example:* High softirq CPU in `top` indicated heavy packet processing, leading us to tune the network stack with RSS queues.

12. Uninterruptible process state
*What:* Processes waiting on critical I/O that cannot be killed until the operation completes.
*How:* Identify state `D` in `ps` or `top`, investigate underlying I/O, and resolve the hardware or filesystem issue.
*Example:* A blocked NFS mount left processes in `D`; remounting the hung volume freed them immediately.

13. Stack memory vs. heap memory
*What:* Memory regions with different lifetime and allocation strategies.
*How:* Use stack for automatic, small allocations and heap for dynamic, long-lived data; monitor with profiling tools to avoid overflows or leaks.
*Example:* Refactoring a recursive function to iterative reduced stack usage and prevented stack overflow during large batch jobs.

14. Process states in the `top` command
*What:* Indicators of current execution status.
*How:* Interpret `R`, `S`, `D`, `Z`, and `T` to prioritize investigation of running, sleeping, blocked, zombie, or stopped processes.
*Example:* Spotting many `D` states hinted at storage latency, which we confirmed with `iostat`.

15. Purpose of `/proc`
*What:* Virtual filesystem exposing kernel and process metadata.
*How:* Read files like `/proc/cpuinfo`, `/proc/meminfo`, or `/proc/<pid>/fd` for troubleshooting.
*Example:* Checking `/proc/sys/net/ipv4/ip_forward` quickly confirmed whether packet forwarding was enabled on a router node.

16. Load vs. CPU usage
*What:* Different metrics describing system demand.
*How:* Use load average to view runnable and waiting processes, and CPU usage for the proportion of active CPU time; correlate both when diagnosing issues.
*Example:* A high load average with modest CPU usage revealed many processes waiting on disk I/O rather than CPU saturation.

17. MAC to IP resolution
*What:* Address Resolution Protocol (ARP) that maps IP addresses to MAC addresses in local networks.
*How:* Inspect `arp -n` tables, send gratuitous ARP, or use `ip neigh` to validate entries.
*Example:* Clearing a stale ARP cache with `ip neigh flush` restored connectivity after a failover.

18. RAID types and use cases
*What:* Redundant array configurations balancing performance and resilience.
*How:* Choose RAID0 for speed, RAID1 for mirroring, RAID5 for parity-based balance, and RAID10 for high performance plus redundancy.
*Example:* For a database requiring fast writes and redundancy, we provisioned RAID10 on SSDs.

19. Partitioning with LVM
*What:* Logical Volume Manager for flexible disk management.
*How:* Create physical volumes with `pvcreate`, group them with `vgcreate`, then carve logical volumes via `lvcreate` before formatting and mounting.
*Example:* Expanding `/var` involved adding a new disk, extending the volume group, and resizing the logical volume without downtime.

20. Viewing and optimizing JVM memory
*What:* Tools and flags to monitor and tune Java heap usage.
*How:* Use `jstat`, `jmap`, or VisualVM for telemetry, then adjust parameters like `-Xms`, `-Xmx`, and GC options.
*Example:* Setting `-Xmx4g` and enabling G1GC stabilized latency for a Spring service under peak load.

21. Managing kernel parameters
*What:* System-wide tunables affecting networking, memory, and more.
*How:* Query or set values with `sysctl`, persist changes in `/etc/sysctl.conf`, and reload with `sysctl -p`.
*Example:* Raising `net.core.somaxconn` via sysctl prevented SYN backlog drops during traffic spikes.

22. Adjusting process limits, max threads, open files
*What:* ulimit and PAM configurations that control resource ceilings.
*How:* Edit `/etc/security/limits.conf` for user-level limits and `/etc/sysctl.conf` for system-wide thread counts, then relogin or reload.
*Example:* Increasing `nofile` to 65535 fixed connection errors for a high-concurrency Nginx instance.

23. `du` vs. `df` discrepancies
*What:* Different perspectives on disk usage.
*How:* Use `du` for file-level space, `df` for filesystem availability; investigate deleted-but-open files or reserved space when numbers diverge.
*Example:* Restarting a log collector released deleted log files that kept disk usage high despite `du` showing little data.

24. Buffers vs. cached memory
*What:* Kernel memory used for block device I/O versus filesystem data caching.
*How:* Interpret `free -m` output to distinguish buffer usage from page cache, reclaiming memory if needed.
*Example:* After flushing caches with `sync; echo 3 > /proc/sys/vm/drop_caches`, cached memory dropped while buffers remained for ongoing writes.

25. `lsof` use cases
*What:* Utility for listing open files and network sockets.
*How:* Run `lsof -i` for listening ports, `lsof +L1` to find deleted-but-open files, or `lsof -p <pid>` for descriptors of a process.
*Example:* Identifying which process held port 8080 let us safely restart the correct service.

26. Inter-process communication methods
*What:* Mechanisms like pipes, message queues, signals, shared memory, and sockets.
*How:* Select the method that fits data volume, latency, and topology requirements.
*Example:* We used shared memory for a high-frequency trading feed, complemented by POSIX semaphores to coordinate writers and readers.

27. Setting process priority
*What:* Controls that influence CPU scheduling via niceness.
*How:* Launch processes with `nice -n <value>` or adjust live processes with `renice` to raise or lower their priority.
*Example:* Temporarily lowering a batch job's priority using `renice 15 <pid>` protected critical web workloads during peak hours.

28. Memory paging vs. segmentation
*What:* Memory-management strategies.
*How:* Understand paging's fixed-size pages versus segmentation's logical divisions to interpret kernel tuning and performance impacts.
*Example:* Enabling hugepages for a database minimized TLB misses compared to default paging.

29. Custom systemd services
*What:* Service units describing how daemons start and stop.
*How:* Create a `.service` file in `/etc/systemd/system`, define `ExecStart`, reload systemd, then enable and start the service.
*Example:* We packaged a log forwarder as `log-forwarder.service` to manage restarts and dependencies automatically.

30. Kernel module management
*What:* Loadable components that extend kernel functionality.
*How:* Use `modprobe` to load modules with dependencies, `lsmod` to verify, and `rmmod` to unload when safe.
*Example:* Loading `ip_vs` modules enabled LVS functionality on new load balancer nodes.

31. Ansible roles
*What:* Reusable configuration units for complex automation.
*How:* Structure roles with tasks, handlers, defaults, and templates, then compose them in playbooks.
*Example:* A Kubernetes bootstrap playbook reused roles for installing container runtime, kubeadm init, and worker joins across dozens of nodes.

### Kubernetes

1. Understanding of Kubernetes
*What:* Kubernetes is an open-source orchestration platform that automates deployment, scaling, and management of containerized workloads.
*How:* Leverage declarative manifests, controllers, and reconciliation loops to keep desired and actual state aligned.
*Example:* Defining a Deployment for a web API let Kubernetes roll out updates with zero downtime using rolling updates.

2. Kubernetes cluster architecture
*What:* Core control-plane components and node agents that coordinate scheduling and workload execution.
*How:* Describe the API server, etcd, controller manager, scheduler, kubelet, and kube-proxy, plus worker nodes hosting pods.
*Example:* During an audit I diagrammed how managed masters in EKS interact with our worker groups and load balancers.

3. Pod creation process
*What:* Sequence from user request to running containers.
*How:* A manifest hits the API server, gets stored in etcd, controllers create ReplicaSets, and the scheduler binds pods to nodes where kubelet pulls images and starts containers.
*Example:* Reviewing events with `kubectl describe pod` showed scheduling delays due to insufficient node memory, guiding us to scale the node group.

4. Pod deletion process
*What:* Graceful termination flow when removing workloads.
*How:* Kubernetes sends a termination signal, honors `terminationGracePeriodSeconds`, executes preStop hooks, and kubelet removes the pod after containers exit.
*Example:* Setting a 60-second grace period allowed our Nginx pods to drain connections before the load balancer deregistered them.
