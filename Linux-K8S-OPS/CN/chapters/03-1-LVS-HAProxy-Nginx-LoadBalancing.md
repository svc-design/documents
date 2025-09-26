技术特点、LVS+keepalived、模式对比图、演变历史。我整理成四个部分：

1. 技术特点对比
特性	LVS (Linux Virtual Server)	HAProxy	Nginx
层次	四层负载均衡 (IPVS, 内核态)	四/七层负载均衡 (用户态)	七层反向代理为主，兼具四层
性能	⭐⭐⭐⭐（百万 QPS，线速转发）	⭐⭐⭐（几十万 QPS）	⭐⭐（十万级 QPS）
功能	仅转发，调度算法丰富	健康检查、粘性会话、限流、统计	缓存、WAF、SSL、静态资源代理
部署	配置复杂，需配合 keepalived	配置灵活，专注负载均衡	部署简单，Web 生态强
典型场景	IDC/云 LB 内核基础设施	金融、电信、TCP 协议精细控制	Web 服务器、Ingress Controller
2. LVS + keepalived

LVS (IPVS)

内核态转发，性能极致。

三种模式：NAT、DR、TUN。

适合大规模南北向流量。

keepalived

功能：

管理 LVS 服务规则。

健康检查 RS，失效自动摘除。

VRRP 高可用，实现 VIP 漂移。

对性能无影响，只提供 HA 与管理能力。

组合价值

LVS 保证 极高性能。

keepalived 提供 稳定性与高可用。

经典架构：

Client → LVS + keepalived (VIP) → Nginx/HAProxy → 应用服务

3. LVS-NAT / LVS-DR / LVS-TUN 三种模式对比
flowchart TB
    subgraph NAT["LVS-NAT 模式"]
    C1[Client] -->|请求/响应均经 LVS| LVS1((LVS)) --> RS1[Real Server1]
    LVS1 --> RS2[Real Server2]
    end

    subgraph DR["LVS-DR 模式"]
    C2[Client] -->|请求经 LVS| LVS2((LVS)) --> RS3[Real Server3]
    LVS2 --> RS4[Real Server4]
    RS3 -->|直接响应| C2
    RS4 -->|直接响应| C2
    end

    subgraph TUN["LVS-TUN 模式"]
    C3[Client] -->|请求经 LVS| LVS3((LVS)) -->|IP隧道| RS5[Real Server5]
    LVS3 -->|IP隧道| RS6[Real Server6]
    RS5 -->|直接响应| C3
    RS6 -->|直接响应| C3
    end


NAT 模式

请求和响应都经过 LVS。

LVS 成为瓶颈，性能低。

DR 模式

LVS 修改请求 MAC 地址转发，响应直回客户端。

性能最高，常用模式。

TUN 模式

LVS 用隧道转发请求，RS 解包后直接响应。

适合跨地域机房。

4. LVS / HAProxy 演变

2000s：LVS 崛起

Linux 内核 IPVS，支撑国内外大规模网站（新浪、腾讯）。
高性能四层 LB 标准方案。

2010s：HAProxy / Nginx 流行

Nginx：反向代理、Web Server、Ingress Controller → Web 入口事实标准。
HAProxy：专注 TCP/L7 负载均衡 → 金融、电信行业广泛使用。
2020s：云与云原生

云厂商 LB：底层依旧基于 LVS/DPVS（内核态或 DPDK 用户态增强），对用户透明。

Kubernetes：

内部 Service：kube-proxy (ipvs 模式)。

外部入口：Ingress Controller (Nginx/HAProxy/Envoy/Traefik)。

Service Mesh (Envoy)：东西向流量治理。

👉 现状：

LVS：退居幕后，作为云厂商和 K8s 的基石。
HAProxy：依然在特殊行业强势存在。
Nginx/Envoy：成为云原生应用层代理和入口的主角。
