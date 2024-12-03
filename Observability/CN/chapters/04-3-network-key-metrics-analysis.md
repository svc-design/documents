
# 4.3 网络关键指标的排查

在网络性能和可靠性方面，关键指标的监控和分析至关重要。通过对这些指标的深入了解和排查，可以有效提升网络服务质量，确保应用系统的稳定运行。以下是优先级最高的网络指标，这些指标直接影响应用的可用性、性能和用户体验，适合在网络性能优化中重点关注：

| **指标**             | **定义**                                             | **重要性**                                                                 | **优先级** |
|----------------------|------------------------------------------------------|----------------------------------------------------------------------------|------------|
| **延迟**             | 数据包从源到目的地传输所需的时间。                   | 高延迟会影响实时应用（如视频会议、在线游戏）以及 API 的响应速度。             | 高         |
| **丢包率**           | 传输中丢失数据包的比例。                             | 高丢包率会导致重传或数据丢失，影响应用性能和用户体验。                       | 高         |
| **带宽利用率**       | 网络已使用带宽占总带宽的百分比。                     | 带宽不足可能导致网络拥塞，带宽利用率低可能是资源浪费的信号。                 | 中等       |
| **网络抖动**         | 连续数据包之间延迟的变化幅度。                       | 高抖动会对实时服务（如 VoIP 和视频流）造成明显影响，可能导致卡顿或失真。      | 中等       |
| **网络可用性**       | 网络在特定时间内可正常运行的比例。                   | 网络中断会导致服务不可用，对高可靠性应用影响严重。                           | 高         |
| **重传率**           | 因丢包或错误而需要重传的数据包比例。                 | 重传增加了网络负载，降低了传输效率，可能进一步加剧延迟和拥塞。               | 中等       |
| **TCP 连接时间**     | 建立 TCP 连接所需的时间。                            | 长连接时间会影响首次请求的响应速度，特别是需要频繁建立连接的应用。           | 中等       |
| **DNS 查询时间**     | 域名解析到 IP 地址所需的时间。                       | 慢速的 DNS 查询会延长应用的请求启动时间，影响整体性能。                     | 中等       |
| **HTTP 请求成功率**  | 成功的 HTTP 请求占总请求的比例。                     | HTTP 请求失败会直接导致功能不可用或用户体验下降。                           | 高         |

以下是对这些关键网络指标的详细分析和排查方法。

## 4.3.1 带宽利用率

### 流量监控

**目标**：实时监控网络带宽的使用情况，确保网络资源被合理利用，避免带宽瓶颈。

**步骤**：

1. **收集流量数据**：
   - 使用网络监控工具（如 NetFlow、sFlow）收集网络接口的流量信息。
   - 记录每个接口的入站和出站流量，统计带宽利用率。

2. **分析带宽使用趋势**：
   - 观察带宽利用率的变化趋势，识别高峰时段。
   - 对比历史数据，判断是否存在异常增长。

3. **识别主要流量来源**：
   - 确定哪些应用、服务或用户消耗了大量带宽。
   - 分析流量协议和目的地址，了解流量类型。

**解决方案**：

- **优化流量分配**：根据业务优先级，调整带宽分配策略，确保关键业务的带宽需求。
- **升级带宽**：如果带宽长期接近饱和，考虑升级网络带宽。
- **流量压缩和优化**：采用压缩技术或协议优化，减少带宽消耗。

### 异常流量检测

**目标**：及时发现和处理异常流量，防止网络拥塞和安全问题。

**步骤**：

1. **设定基线**：
   - 建立正常情况下的流量模型，包括流量大小、协议分布等。

2. **实时监控**：
   - 使用入侵检测系统（IDS）或防火墙监控异常流量。

3. **识别异常行为**：
   - 突发的大流量：可能是 DDoS 攻击或病毒传播。
   - 非法协议或端口：可能是未授权的访问或攻击尝试。

**解决方案**：

- **阻断异常流量**：使用防火墙规则或流量清洗设备阻断攻击流量。
- **安全审计**：检查系统和应用的安全漏洞，更新安全补丁。
- **告警机制**：建立实时告警，及时通知管理员处理。

## 4.3.2 延迟

### 网络路径优化

**目标**：降低网络延迟，提高数据传输效率，提升用户体验。

**步骤**：

1. **测量延迟**：
   - 使用 `ping`、`traceroute` 等工具测量从源到目的地的延迟。
   - 记录往返时间（RTT），分析延迟变化。

2. **分析路径**：
   - 查看数据包经过的路由节点，识别延迟较高的节点或段。

3. **优化路径**：
   - 调整路由策略，选择延迟更低的路径。
   - 使用 MPLS、SD-WAN 等技术实现智能选路。

**解决方案**：

- **内容分发网络（CDN）**：将内容缓存到离用户更近的节点，减少传输距离。
- **就近接入**：在多个地区部署服务节点，实现本地化访问。
- **网络服务提供商合作**：与 ISP 协商，优化跨网传输路径。

### 地理位置影响

**目标**：理解地理位置对网络延迟的影响，针对性地优化跨地域通信。

**分析**：

- **物理距离**：数据传输速度受限于光速，物理距离越远，延迟越高。
- **跨国连接**：国际出口带宽有限，可能存在拥塞或政策限制。

**解决方案**：

- **全球加速服务**：使用云服务提供商的全球加速产品。
- **区域性部署**：在用户集中的地区部署数据中心或边缘节点。
- **协议优化**：使用加速协议（如 TCP Fast Open）减少握手时间。

## 4.3.3 丢包率

### 链路质量

**目标**：确保网络链路的可靠性，降低数据包丢失率。

**步骤**：

1. **监测丢包率**：
   - 使用 `ping` 命令发送多个 ICMP 包，统计丢包率。
   - 使用网络监控工具记录数据包传输情况。

2. **分析链路状态**：
   - 确定丢包发生的节点或链路段。
   - 检查网络设备的错误统计信息（如接口错误、碰撞）。

**解决方案**：

- **更换或修复故障链路**：对于物理损坏的线路，及时维修。
- **提高链路冗余**：采用链路聚合或备用路径，防止单点故障。
- **调整网络参数**：优化 MTU 值，避免分片导致的丢包。

### 设备故障排查

**目标**：检查网络设备的健康状况，排除因设备故障导致的丢包。

**步骤**：

1. **设备日志检查**：
   - 查看交换机、路由器、防火墙等设备的系统日志。
   - 关注错误信息、异常重启、端口状态等。

2. **接口状态检查**：
   - 检查网络接口的状态，是否有频繁的 up/down 变化。
   - 查看接口的错误计数器，如 CRC 错误、帧错误。

3. **固件和配置**：
   - 确认设备固件是否需要更新，配置是否正确。

**解决方案**：

- **更换故障设备**：对于无法修复的设备，及时更换。
- **更新固件**：升级设备固件，修复已知问题。
- **优化配置**：调整设备配置，避免资源耗尽或冲突。

## 4.3.4 网络抖动

### 实时应用影响

**目标**：降低网络抖动对实时应用（如 VoIP、视频会议）的影响，保证服务质量。

**分析**：

- **网络抖动**：指数据包到达时间的变动性，过高的抖动会导致音视频卡顿。
- **实时应用敏感性**：实时应用对延迟和抖动要求较高。

**检测方法**：

- 使用专用工具（如 iperf）测量网络抖动。
- 监控实时应用的质量指标（如 MOS 分数）。

**解决方案**：

- **QoS 策略**：配置服务质量策略，为实时流量设置优先级。
- **带宽保障**：预留带宽，防止其他流量挤占资源。
- **缓冲机制**：在应用层增加缓冲，平滑抖动影响。

### 网络稳定性提升

**目标**：通过网络优化，提高整体网络的稳定性，减少抖动。

**措施**：

- **消除网络瓶颈**：升级过载的网络设备或链路。
- **减少网络层次**：简化网络拓扑，降低转发延迟。
- **使用稳定的传输介质**：优先采用光纤等高质量链路。

## 4.3.5 网络可用性

### 冗余设计

**目标**：通过冗余设计，提升网络的可靠性，防止单点故障。

**策略**：

- **链路冗余**：使用双上行链路、环形拓扑等设计，保证链路故障时有备用路径。
- **设备冗余**：部署冗余的核心交换机、路由器，实现设备级备份。
- **多数据中心**：在不同区域部署数据中心，实现业务容灾。

**实现方法**：

- **协议支持**：使用 STP、VRRP、HSRP 等协议，实现冗余切换。
- **负载均衡**：采用负载均衡设备，分摊流量，提升可用性。

### 故障切换机制

**目标**：确保在故障发生时，系统能够自动切换到备用路径或设备，最小化服务中断。

**步骤**：

1. **配置故障检测**：
   - 设置心跳检测，实时监控设备和链路状态。

2. **设定切换条件**：
   - 明确何时触发切换，如连续心跳失败次数。

3. **测试切换流程**：
   - 定期演练故障切换，确保机制有效。

**解决方案**：

- **自动化切换**：使用网络协议自动完成故障切换，无需人工干预。
- **快速收敛**：优化路由协议参数，减少切换时间。

## 4.3.6 重传率

### 拥塞控制

**目标**：通过拥塞控制，降低数据包重传率，提升网络效率。

**分析**：

- **高重传率原因**：网络拥塞、丢包导致发送端重新发送数据。
- **影响**：增加网络负载，降低传输效率。

**措施**：

- **调整窗口大小**：优化 TCP 的拥塞窗口，避免发送过多数据导致拥塞。
- **主动队列管理（AQM）**：在路由器中使用 RED、ECN 等机制，预防拥塞。

### 传输优化

**目标**：优化传输协议和参数，减少重传，提升传输性能。

**策略**：

- **使用高效协议**：如在高延迟网络中使用 QUIC 协议。
- **协议参数优化**：调整 TCP 的超时时间、重传次数等参数。

**解决方案**：

- **传输压缩**：压缩数据，提高传输效率。
- **流控机制**：根据接收端的处理能力，调整发送速率。

## 4.3.7 TCP 连接时间

### 握手延迟分析

**目标**：降低 TCP 连接建立的时间，提升用户访问速度。

**分析**：

- **三次握手**：TCP 连接需要进行三次握手，延迟会累积。
- **延迟因素**：网络延迟、服务器响应时间。

**检测方法**：

- 使用抓包工具，测量 SYN、SYN-ACK、ACK 包的时间间隔。
- 分析握手过程中是否有重传或超时。

**解决方案**：

- **TCP Fast Open**：减少握手次数，缩短连接建立时间。
- **保持连接**：使用长连接（如 HTTP/2），减少重复握手。

### 服务器性能

**目标**：提升服务器处理连接的能力，避免成为瓶颈。

**措施**：

- **优化系统参数**：调整服务器的最大连接数、半连接队列长度等参数。
- **升级硬件**：提高 CPU、内存等资源，满足高并发需求。
- **负载均衡**：分摊连接请求，防止单台服务器过载。

## 4.3.8 DNS 查询时间

### DNS 服务优化

**目标**：降低 DNS 查询时间，加快域名解析速度。

**措施**：

1. **本地部署 DNS 服务器**：
   - 搭建本地 DNS 解析服务器，减少查询跳数。

2. **优化 DNS 配置**：
   - 使用权威 DNS 服务器，减少递归查询。

3. **提高 DNS 服务器性能**：
   - 增加服务器带宽和处理能力，缩短响应时间。

### 缓存策略

**目标**：通过缓存机制，加快 DNS 解析，提高查询效率。

**策略**：

- **客户端缓存**：浏览器和操作系统层面的 DNS 缓存。
- **网络缓存**：在网络设备（如路由器）中启用 DNS 缓存。
- **TTL 设置**：适当延长 DNS 记录的 TTL，减少重复查询。

**注意事项**：

- **缓存一致性**：在 DNS 记录变更时，需考虑缓存的影响，避免解析错误。
- **安全性**：防止缓存中毒，使用 DNSSEC 等安全措施。

## 4.3.9 HTTP 请求成功率

### 服务器健康检查

**目标**：确保服务器运行正常，提升 HTTP 请求的成功率。

**措施**：

1. **定期检测**：
   - 使用监控工具，定期检查服务器的状态和响应。

2. **健康检查接口**：
   - 开发专用的健康检查接口，返回服务器运行状态。

3. **日志分析**：
   - 分析服务器日志，发现异常请求和错误码。

**解决方案**：

- **自动重启服务**：在检测到异常时，自动重启服务或切换到备用服务器。
- **容量规划**：根据负载，及时扩容，防止服务器过载。

### 网络异常处理

**目标**：处理网络异常情况，确保 HTTP 请求的可靠传输。

**措施**：

- **重试机制**：在请求失败时，客户端或中间件自动重试。
- **超时设置**：合理设置请求和连接的超时时间，避免长时间等待。
- **错误处理**：在网络异常时，提供友好的错误提示和应急措施。

**解决方案**：

- **使用可靠的传输协议**：如启用 HTTP/2 的多路复用，减少连接数量。
- **负载均衡和容错**：通过负载均衡器，自动将请求路由到健康的服务器。


# TCP 传输超时机制整理

## 300ms 内没有收到 ACK 的场景

在 TCP 协议中，**300ms内没有收到 ACK** 这种情况通常发生在以下两个阶段之一：**连接建立阶段** 或 **数据传输阶段**。

---

### 1. 连接建立阶段 (Connection Establishment Phase)
#### 描述
这是 TCP 的三次握手过程，用于建立可靠的连接。

#### ACK 的作用
- 在三次握手过程中，每个通信方会使用 `SYN` 和 `ACK` 标志来确认连接的进展。
- 发送端发送 `SYN` 后，等待接收端返回 `SYN+ACK` 确认。
- 如果在 **300ms内未收到 ACK**，发送端会超时重试，直到达到最大重试次数或完全放弃连接。

#### 示例流程
1. **SYN**：发送方发送 `SYN` 请求建立连接。
2. **SYN+ACK**：接收方返回 `SYN+ACK`。
3. **ACK**：发送方确认 `ACK`，连接建立完成。

#### 300ms 超时的情况
- 如果在第一步或第二步中，`SYN` 或 `SYN+ACK` 没有被成功接收或返回，则会进入超时逻辑。
- 可能原因：
  - 网络延迟。
  - 数据包丢失。
  - 目标主机不可达。

---

### 2. 数据传输阶段 (Data Transmission Phase)
#### 描述
在连接建立后，双方通过 TCP 数据包进行数据传输，每个数据段都需要 ACK 确认。

#### ACK 的作用
- 接收端在成功接收数据包后，发送 ACK 确认包，告知发送端可以发送下一个数据段。
- 如果发送端在 **300ms内未收到 ACK**，会触发重传机制。

#### 示例流程
1. **发送数据**：发送端发送一个 TCP 数据包。
2. **返回 ACK**：接收端成功接收数据后，返回 ACK 确认。
3. **下一数据段**：发送端收到 ACK 后，发送下一个数据段。

#### 300ms 超时的情况
- 如果接收端未能按时发送 ACK，可能导致数据包重传。
- 可能原因：
  - 数据包丢失。
  - 接收端处理延迟。
  - 网络延迟较高或网络抖动。

---

### 3. 阶段区别总结

| **阶段**           | **ACK 的作用**                            | **300ms 超时的可能性**               |
|--------------------|-------------------------------------------|-------------------------------------|
| **连接建立阶段**    | 确保三次握手成功建立连接                   | 网络延迟、丢包、目标主机不可达。     |
| **数据传输阶段**    | 确认接收数据包，并告知发送端继续发送下一数据段 | 数据包或 ACK 丢失、接收端延迟、网络抖动。 |

---

## 如何应对 300ms 未收到 ACK 的情况？

### 1. 动态调整 RTO（重传超时时间）
- RTO 是根据网络条件动态计算的，初始值可能为 300ms。
- 如果网络较慢，可通过调整参数增大超时时间。

### 2. TCP 快速重传 (Fast Retransmit)
- 如果发送方收到多个重复的 ACK（表明某些包未达），可能会提前触发重传，而不是等待 RTO 超时。

### 3. 网络优化
- 检查是否存在网络拥塞或丢包，优化网络路径或增加带宽。

---

通过对网络关键指标的深入分析和有效排查，可以显著提升网络的性能和可靠性。定期监控这些指标，及时发现并解决问题，对于保障应用系统的正常运行和用户满意度至关重要。


TCP 时延相关指标表

| **指标**         | **定义**                               | **阶段**            | **影响因素**                      | **区别**                                                                 |
|------------------|----------------------------------------|---------------------|-----------------------------------|--------------------------------------------------------------------------|
| **TCP 连接时延** | 三次握手所需时间                       | 连接建立阶段        | 网络延迟、服务器响应速度          | 测量连接建立效率，不涉及后续数据传输。                                   |
| **RTT**          | 数据包从源到目的地再返回的总时间       | 全过程              | 网络物理距离、拥塞               | 网络底层延迟的综合反映，是其他时延的基础。                               |
| **初始时延**     | 从请求到收到首字节的时间（TTFB）       | 连接建立 + 数据开始 | TCP 握手时延、服务器响应          | 包括了 TCP 握手和服务器处理时间，反映用户可感知的响应延迟。             |
| **数据传输时延** | 从开始发送到完全接收数据的时间         | 数据传输阶段        | 带宽、窗口大小、丢包重传          | 强调传输阶段性能，与握手阶段无关。                                       |
| **抖动**         | 数据包到达时间的波动性（Jitter）       | 全过程              | 网络稳定性                       | 关注时间一致性，而非单次时延，主要影响实时性要求较高的应用。             |
| **重传时延**     | 因丢包重传导致的额外延迟               | 数据传输阶段        | 丢包率、网络质量                 | 表示丢包的代价，直接影响传输性能。                                       |
| **慢启动时延**   | TCP 连接初期，数据传输受限所需的时间   | 数据传输阶段        | 窗口大小、网络拥塞               | 仅影响传输初期，与稳定阶段性能无关，适用于大文件传输分析。               |


TCP 建连异常相关指标表

| **指标**             | **定义**                                       | **异常阶段**   | **常见原因**                                    | **区别**                                                                 |
|----------------------|------------------------------------------------|----------------|------------------------------------------------|--------------------------------------------------------------------------|
| **TCP 连接失败率**   | 未完成三次握手的连接比例                       | 全过程         | 网络丢包、服务器未监听、超时                   | 反映总体连接失败的宏观指标，是性能排查的起点。                           |
| **TCP 超时率**       | 建连超时的比例                                 | 全过程         | 高延迟、丢包重传、服务器过载                   | 专注超时问题，通常与网络延迟或服务器负载有关。                           |
| **TCP 重试次数**     | 建连中因丢包需要重传的次数                     | 全过程         | 丢包率高、拥塞、路由问题                       | 表示网络传输可靠性，过高可能导致建连失败或性能下降。                     |
| **SYN 丢包率**       | 客户端发送的 SYN 包未收到响应的比例             | 第一步         | 链路丢包、防火墙拦截                          | 专注建连的第一步，反映初始连接的成功率。                                 |
| **SYN-ACK 失败率**   | 服务端返回的 SYN-ACK 包未到达客户端的比例       | 第二步         | 服务端丢包、防火墙或 NAT 问题                  | 分析服务端到客户端方向的网络问题。                                       |
| **RST 包率**         | 建连过程中收到 RST 包的比例                    | 全过程         | 服务端拒绝连接、防火墙或策略问题               | 表明服务端主动中断连接，可能涉及配置错误或策略限制。                     |
| **建连延迟**         | 完成三次握手的时间                             | 全过程         | 高 RTT、丢包重传                              | 偏向时延分析，高延迟可能导致连接超时或多次重传。                         |
| **拒绝连接率**       | 被服务器拒绝的连接比例                         | 全过程         | 服务器端口未监听、超出连接限制                | 表明服务器端主动拒绝连接的情况。                                         |
| **防火墙拦截率**     | 数据包被防火墙拦截的比例                       | 全过程         | 防火墙规则错误或策略限制                      | 特指中间设备干预导致的连接失败。                                         |
| **NAT 超时率**       | 因 NAT 转换失败导致建连异常的比例               | 全过程         | NAT 表溢出、超时配置不当                      | 特指 NAT 相关问题，区别于常规的丢包或超时原因。                          |


## TCP 超时类型

| **超时类型 (中文)**       | **状态 (英文)**                          | **默认值（Linux）**    | **默认值（Windows）** | **默认值（macOS）**    |
|--------------------------|-----------------------------------------|-----------------------|-----------------------|-----------------------|
| **初始 RTO**             | Initial RTO (Retransmission Timeout)   | 200ms - 1秒           | 300ms                 | 1秒                   |
| **最大重传超时**         | Maximum Retransmission Timeout         | 13-30分钟             | 240秒                 | 9分钟                 |
| **Keepalive 超时**       | Keepalive Timeout                      | 7200秒（2小时）       | 7200秒（2小时）       | 7200秒（2小时）       |
| **连接建立超时**         | Connection Establishment Timeout       | 63秒                  | 21秒                  | 75秒                  |
| **连接重置超时**         | Connection Reset Timeout               | 0秒                   | 0秒                   | 0秒                   |
