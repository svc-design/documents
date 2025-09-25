K8s troubleshooting, Linux commands

Linux System topic
1. Combining grep, sed, awk, and cut
grep: A tool for searching text using patterns (regular expressions).
sed: A stream editor used for text substitution and formatting.
awk: A powerful tool for processing and analyzing text data.
cut: A command used to extract specific columns or fields from text.
These tools can be combined to perform complex text manipulation, such as filtering text with grep, extracting columns with awk, replacing content with sed, and extracting portions of lines with cut.

“processing” [ˈprəʊsesɪŋ] “处理；加工；审阅”
“simulation” [ˌsɪmjuˈleɪʃn] “模拟；仿真；假装；冒充”
“optimizing” [ˈɒptɪmaɪzɪŋ] “使最优化；充分利用”
“patterns” [ˈpætənz] “模式；图案；样品”
“substitution” [ˌsʌbstɪˈtjuːʃn] “代替；取代”
“processing” [ˈprəʊsesɪŋ] “处理；加工；审阅”

2. HTTP error codes and causes
Common error codes:
404: Resource not found.
500: Internal server error.
502: Bad gateway (backend service unavailable or timed out).
403: Forbidden access.
3. Difference between long connection, short connection, and WebSocket, and use cases
Long connection: A persistent TCP connection across multiple requests, used in database connections.
Short connection: A connection that closes after each request. Commonly used in HTTP requests.
WebSocket: Enables two-way real-time communication over a single connection. Used in chat applications, live stock updates, etc.
4. Nginx performance optimization methods
Adjust worker_processes and worker_connections.
Use reverse proxy caching.
Enable gzip compression.
Use keepalive for connection reuse.
5. Differences between LVS, Nginx, and HAProxy, and use cases
LVS: Layer 4 load balancer based on IP and port, suitable for high-performance needs.
Nginx: Layer 7 load balancer, based on HTTP protocol, suitable for application layer proxy.
HAProxy: Supports both Layer 4 and Layer 7 load balancing, ideal for high-concurrency scenarios.
6. What is a zombie process?
A process that has completed execution but whose parent process hasn't read its exit status, leaving it consuming resources. It can be cleaned up by using the wait function.
7. Difference between processes, threads, and coroutines
Process: The basic unit of resource allocation by the operating system.
Thread: A unit of execution within a process that shares process resources.
Coroutine: Lightweight user-space threads managed by the program rather than the operating system.
8. What is Nginx's asynchronous non-blocking mode?
Nginx uses an event-driven model to handle requests in a non-blocking manner, improving concurrency by allowing I/O operations to be processed asynchronously.
9. How to troubleshoot network packet loss in Linux?
Use ping and traceroute to check network paths.
Check for interface errors and dropped packets using ifconfig or ip commands.
Use tcpdump or wireshark to capture and analyze network traffic.
10. Common performance analysis and diagnostic commands
top, htop, vmstat, iostat, sar, strace, tcpdump, netstat, lsof, etc.
11. What is process interruption, soft interrupt, hard interrupt?
Process interruption: Interrupts a process to allow the system to perform other tasks.
Soft interrupt: Used to handle asynchronous events, such as network packet processing.
Hard interrupt: Triggered by hardware, such as peripherals requesting CPU attention.
12. What is an uninterruptible process?
A process waiting for I/O completion, which cannot be killed.
13. Difference between stack memory and heap memory
Stack memory: Automatically managed memory used for local variables and function calls.
Heap memory: Dynamically allocated memory managed by the programmer.
14. Process states in the top command
States include R (running), S (sleeping), D (uninterruptible), Z (zombie), T (stopped).
15. What is /proc in Linux?
A virtual filesystem that contains process, kernel, and hardware information, such as /proc/cpuinfo and /proc/meminfo.
16. Difference between load and CPU usage
Load: Reflects the number of processes waiting to be executed by the CPU.
CPU usage: The percentage of time the CPU is busy processing tasks.
17. How are MAC addresses and IP addresses converted?
The Address Resolution Protocol (ARP) is used to map IP addresses to MAC addresses in a local network.
18. Common RAID types and use cases
RAID 0: Striping, high performance, no redundancy.
RAID 1: Mirroring, redundancy but lower performance.
RAID 5: Striping with parity, balance between performance and redundancy.
RAID 10: Combination of striping and mirroring, offering both performance and redundancy.
19. How to partition using LVM
Use pvcreate, vgcreate, and lvcreate commands to create physical volumes, volume groups, and logical volumes.
20. How to view and optimize JVM memory
Use jstat, jmap, and jvisualvm to monitor memory usage. Optimize using flags like -Xmx, -Xms, and -XX:PermSize.
21. Managing kernel parameters
Use sysctl to view and modify kernel parameters.
22. How to adjust process limit, max threads, and open file descriptors
Modify /etc/security/limits.conf or /etc/sysctl.conf to adjust these settings.
23. Reasons for du and df showing inconsistent results
du reports file and directory usage, while df shows the entire filesystem usage. Discrepancies may occur due to unfreed or locked files.
24. Difference between buffers and cached memory
Buffers: Cache for block devices (I/O).
Cached: Cache for filesystem data.
25. Use cases for the lsof command
Display open files, network connections, and used ports, helping diagnose resource leakage.
26. Inter-process communication methods in Linux
Pipes, message queues, signals, shared memory, and sockets, each used for different communication needs.
The following are the usage differences among pipes, message queues, signals, shared memory, and sockets:
I. Pipes
Pipes are mainly used for communication between processes with a kinship relationship.
Purpose:
Usually used to transfer data between parent and child processes. For example, a parent process generates some data and passes it to the child process for further processing through a pipe.
Suitable for simple data transfer scenarios. The data flow is unidirectional. If bidirectional communication is needed, two pipes need to be established.
Features:
Can only be used between processes with a common ancestor.
Data can only flow in one direction. If bidirectional communication is needed, two pipes need to be established.
The capacity of pipes is limited, generally several KB to several MB.
II. Message Queues
A message queue is a message linked list in the kernel, identified by a message queue identifier.
Purpose:
Used to transfer messages between different processes. Multiple processes can send messages to the same message queue and can also receive messages from the same message queue.
Suitable for scenarios where processes need asynchronous communication. The sending process can continue to execute other tasks after sending a message, and the receiving process reads the message when needed.
Features:
Message queues can achieve asynchronous communication between multiple processes.
Messages have types and specific messages can be received according to types.
The messages in the message queue are formatted and can contain different types of data.
III. Signals
Signals are used to notify a process that a certain event has occurred.
Purpose:
Used for notifying abnormal situations, such as illegal memory access, division by zero error, etc.
Can also be used for simple communication between processes. For example, one process sends a specific signal to another process to trigger a certain behavior.
Features:
Signals are an asynchronous communication method. The process sending the signal does not know when the receiving process will handle the signal.
There are a limited number of signal types, and each signal has a specific meaning.
Signal processing can be interrupted and resumed.
IV. Shared Memory
Shared memory is a physical memory area shared by multiple processes.
Purpose:
Suitable for scenarios that require efficient data sharing. Multiple processes can read and write data in shared memory simultaneously to achieve rapid data exchange.
Often used in applications that require a large amount of data interaction, such as scientific computing, image processing, etc.
Features:
The access speed of shared memory is very fast because it operates directly in memory.
Processes need to perform synchronization control by themselves to avoid data conflicts.
Once created, shared memory can be accessed by multiple processes simultaneously.
V. Sockets
Sockets are mainly used for communication between processes on different hosts.
Purpose:
Widely used in network communication to achieve data transmission between processes on different computers.
Can be used to implement various network applications, such as client-server mode application programs.
Features:
Supports communication between different hosts and has a wide communication range.
Can use different protocols such as TCP, UDP, etc.
Provides rich network programming interfaces.

27. Setting process priority in Linux
Use nice and renice commands to set and modify the priority of processes.
28. Difference between memory paging and segmentation
Paging: Divides memory into fixed-size pages.
Segmentation: Divides memory into logical segments such as code, data, and stack.
29. How to create and manage custom systemd services
Create .service files defining how a service should start, stop, and restart. Place the files in /etc/systemd/system/.
30. Loading and unloading kernel modules
Use modprobe to load modules and rmmod to unload them. Kernel modules are stored in /lib/modules.
31. Use cases for Ansible roles
Ansible roles are used for managing complex configurations, such as adding multiple machines to a Kubernetes cluster in bulk.

Kubernetes
Here is the English version of the Kubernetes interview question summary:

1. What is your understanding of Kubernetes?
Explanation of Kubernetes as an open-source container orchestration platform for automating deployment, scaling, and managing containerized applications.
2. What is the architecture of a Kubernetes cluster?
Overview of components: API Server, etcd, Controller Manager, Scheduler, kubelet, kube-proxy, and worker nodes.
3. Briefly describe the Pod creation process
Explanation of how the API server processes a request, validates it, stores it in etcd, and how the scheduler assigns the Pod to a node.
4. Describe the process of deleting a Pod
Steps from API call to pod termination, including graceful shutdown signals sent to containers.
5. Communication between Pods on different nodes
Description of how Pods communicate using the CNI (Container Network Interface) and network plugins like Calico or Flannel.
6. Reasons for a Pod being in Pending state
Lack of available resources, such as CPU or memory, insufficient node capacity, or missing network configurations.
7. Difference between Deployment and StatefulSet
Deployment: Manages stateless applications with pod replicas.
StatefulSet: Manages stateful applications with persistent storage and stable network identities.
8. What is the role of kube-proxy?
Handles network traffic routing in the cluster, managing IP-based rules for load balancing.
9. How to modify IPVS rules in kube-proxy?
Use IPVS mode to route traffic, manage ipvsadm rules for load balancing and failover.
10. Why is IPVS more efficient than iptables?
IPVS operates at a higher layer with more optimized performance for handling large volumes of requests, compared to iptables' linear matching.
11. How to troubleshoot Pod communication issues?
run command: kubectl describe pods xxx Or kubectl logs -f pods-xxx
Verify network policies,
inspect the CNI plugin
check DNS resolution,
validate Pod IPs.
12. Network Policy in Kubernetes and its implementation
Describes how Kubernetes Network Policies control traffic flow between Pods using labels, selectors, and rules for ingress/egress traffic.
13. What are probes, and what types of probes are there?
Liveness probe: Checks if the Pod is running.
Readiness probe: Checks if the Pod is ready to serve traffic.
Startup probe: Checks if the application inside the Pod has started successfully.
14. Possible reasons for Pod health check failure and troubleshooting approach
Common issues include misconfiguration of probes, networking issues, or insufficient resources.
15. What is a Kubernetes Service?
An abstraction that defines a logical set of Pods and a policy to access them, allowing for service discovery and load balancing.
16. Metrics-server data collection process
Explains how metrics-server scrapes resource usage metrics from the kubelet API on each node and exposes them through the Kubernetes API.
17. What are the different ways of service discovery in Kubernetes?
Service discovery using DNS, headless services, or through the Kubernetes API.
18. Common Pod states
Running, Pending, Failed, Succeeded, CrashLoopBackOff, and Unknown.
19. Pod lifecycle hooks
PreStop, PostStart hooks used to run code at certain points in the Pod's lifecycle.
20. Differences between Calico and Flannel
Calico: Uses BGP for L3 networking, supports Network Policies.
Flannel: Simple overlay network, focuses on L3 routing but does not natively support Network Policies.
21. Calico networking principles and architecture
Calico uses an L3 approach with BGP or IP-in-IP for routing, providing a highly scalable solution for large clusters.
22. Use cases for Network Policy
Use to secure traffic between Pods, enforce egress/ingress rules, and isolate services.
23. How does kubectl exec work?
Opens an interactive session into a running container using a WebSocket connection to the kubelet.
24. Methods for limiting CPU in cgroups
Control CPU resource allocation using cgroups with cpu.shares, cpu.cfs_quota_us, and cpu.cfs_period_us.
25. Contents of kubeconfig
Specifies cluster, user credentials, contexts, and configurations for accessing Kubernetes.
26. Pod DNS resolution process
Pods resolve DNS queries using CoreDNS service that handles DNS resolution for services and pods within the cluster.
27. Traefik vs. Nginx Ingress Controller
Traefik provides dynamic routing, easier configuration with Kubernetes, and supports additional features like metrics and tracing.
28. Components of Harbor
Harbor includes components like Docker registry, Harbor core, Job Service, Clair (for vulnerability scanning), and Notary (for image signing).
29. How to achieve high availability for Harbor
Use of external databases, Redis for session persistence, and a load balancer to ensure high availability across multiple Harbor instances.
30. ETCD optimization techniques
Increase performance by tuning etcd memory settings, using SSDs, managing compaction, and ensuring proper backups.
31. Considerations for managing large Kubernetes clusters
Ensure proper etcd scaling, optimize the scheduler and controller-manager, monitor network latency, and ensure resource quotas and limits.
32. Possible reasons for nodes being in NotReady state
Network issues, kubelet crash, insufficient resources, or misconfiguration. Can cause Pods to be unscheduled or degraded.
33. How are Service and Endpoints related?
Service selects Pods based on labels and creates corresponding Endpoints that map IPs of the selected Pods.
34. How are ReplicaSet and Deployment implemented?
Deployment manages ReplicaSets for rolling updates, ensuring consistent state across the cluster.
35. Scheduler workflow in Kubernetes
Scheduler watches unassigned Pods, evaluates available resources, and assigns Pods to appropriate nodes based on affinity, taints, and tolerations.
36. How is Horizontal Pod Autoscaling (HPA) implemented?
Uses metrics from the metrics-server to adjust the number of replicas based on CPU or custom metrics.
37. How are resource requests and limits enforced?
Kubernetes uses cgroup to enforce CPU/memory limits by throttling or killing containers that exceed their limits.
38. How does Helm work?
Helm is a package manager for Kubernetes that simplifies application deployment through reusable templates called charts.
39. Helm chart rollback process
Rollbacks involve updating resources to a previous release by fetching the corresponding chart and values.
40. Velero backup and restore process
Velero backs up cluster resources and persistent volume data, enabling restore in the case of failures.
41. Docker network modes
Bridge, Host, None, and Overlay, each with different networking setups for container communication.
42. Difference between Docker and Container?
Docker is a platform for managing containers, while containers are isolated instances running within an OS.
43. How to minimize Dockerfile image size?
Use multi-stage builds, minimize layers, clear cache, and avoid installing unnecessary packages.
44. Kubernetes logging solutions
Centralized logging with Fluentd, Logstash, or Loki to collect and manage logs from all nodes and containers.
45. Purpose of the Pause container
Used to hold the network namespace for a Pod, enabling communication between containers in the same Pod.
46. How to update expired Kubernetes certificates
Use kubeadm to renew certificates or manually update them in /etc/kubernetes/pki.
47. Kubernetes QoS (Quality of Service) classes
BestEffort, Burstable, and Guaranteed, determined by the resource requests and limits set on the Pod.
48. Considerations when maintaining Kubernetes nodes
Drain the node to move running Pods, apply security patches, and monitor workloads during the maintenance period.
49. Difference between Headless Service and ClusterIP
ClusterIP: Provides an internal IP for accessing services.
Headless: Does not allocate a cluster IP and allows direct access to the underlying Pods.
50. Fundamentals of Linux container technology
Containers rely on namespaces, cgroups, and chroot for isolation and resource control.
51. Common Pod scheduling strategies
Affinity, anti-affinity, taints, tolerations, and resource-based scheduling.
52. Ingress controller principles
Manages external access to services using routing rules defined by Ingress resources.
53. How do Kubernetes components communicate with the API Server?
All components (Scheduler, Controller Manager, kubelet, etc.) communicate via RESTful API to manage resources and ensure desired state.
54. How does kubelet monitor worker nodes?
Kubelet monitors node health, reports status to the API server, and ensures that containers are running as expected.
55. How to resolve container time zone inconsistency issues?
Mount the host’s timezone into the container, or explicitly set the timezone using environment variables.
This structure covers a broad range of Kubernetes topics that are often asked in technical interviews.
