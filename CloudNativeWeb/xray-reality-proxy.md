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

## 示例配置

以下示例展示在中转节点 `/etc/xray/config.json` 中直接监听 443 端口，并将流量通过 VLESS REALITY 协议转发到 `global-homepage.onwalk.net:443` 的配置：

```json
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": 443,
      "listen": "0.0.0.0",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "你的UUID",
            "encryption": "none",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "dest": "global-homepage.onwalk.net:443",
          "xver": 0,
          "serverNames": ["global-homepage.onwalk.net"],
          "privateKey": "中转节点REALITY私钥",
          "shortIds": ["shortid"]
        }
      },
      "tag": "vless-in"
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "inboundTag": ["vless-in"],
        "outboundTag": "direct"
      }
    ]
  }
}
```

该配置让 Xray 接收客户端对 `www.svc.plus` 的访问（浏览器、前端代码或 curl），并将行为伪装为访问 `global-homepage.onwalk.net` 的 HTTPS 请求，由 Cloudflare Worker 接管。

### 前置条件

- **UUID**：任意生成，用作 Xray 客户端标识。
- **privateKey / shortId**：在中转节点生成的 REALITY 私钥及对应短 ID。
- **serverName**：填写 `global-homepage.onwalk.net`（已部署在 Cloudflare）。
- **DNS**：将 `www.svc.plus` 的 A 记录指向中转节点公网 IP，并确保 TLS SNI 能正常生效。
