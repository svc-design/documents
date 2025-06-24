# Xray VLESS+REALITY 中转到 Cloudflare Worker

本文记录如何通过中转节点将用户访问的 `https://www.svc.plus` 流量转发至 Cloudflare Worker 服务 `global-homepage.onwalk.net`。整体流程如下：

1. **DNS 指向中转节点**：将 `svc.plus` 域名的 DNS 记录配置为指向中转服务器 IP。
2. **Xray 接收 TLS 请求**：在中转服务器上部署 Xray，监听 443 端口并启用 REALITY 握手。客户端访问 `https://www.svc.plus` 时，TLS 流量会被 Xray 捕获。
3. **使用 VLESS+REALITY 转发**：Xray 通过 VLESS+REALITY 协议将流量转发到 `global-homepage.onwalk.net:443`，后者为部署在 Cloudflare Worker 上的服务。
4. **Cloudflare Worker 处理请求**：Worker 根据业务逻辑返回页面或进一步访问后端服务。

```text
用户浏览器 ──HTTPS──> svc.plus (DNS) ──> 中转节点(Xray) ──VLESS+REALITY──> global-homepage.onwalk.net
```

### Xray 配置要点

- `inbounds` 监听 443 端口，`tlsSettings` 使用 REALITY，配置私钥及公钥。
- `outbounds` 连接 `global-homepage.onwalk.net:443`，启用 `serverName` 指向目标域名。
- 如需隐藏流量特征，可在客户端与服务端同时配置 `realitySettings` 中的掩码域名。

通过上述配置，即可在保证 TLS 安全的前提下，将用户请求转发到 Cloudflare Worker，实现灵活的边缘计算接入。
