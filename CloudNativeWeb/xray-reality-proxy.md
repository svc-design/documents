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
## 进阶：Nginx 与 Xray 分层部署

当需要将 TLS 终端和转发逻辑分别托管于 Nginx 和 Xray 时，可以使用 `nginx → xray-client → xray-server` 的方式。整体链路下图：

```text
Browser
  ↓ HTTPS (TLS)
Nginx (TLS termination)
  ↓ http://127.0.0.1:1081
Xray (HTTP Inbound)
  ↓ VLESS+REALITY to 127.0.0.1:8443
Xray (REALITY Inbound)
  ↓ freedom
global-homepage.onwalk.net
```

### systemd 服务单元示例

`xray-client.service`

```ini
[Unit]
Description=Xray Client (HTTP Inbound → VLESS+REALITY)
After=network.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/xray -config /etc/xray/in.config
Restart=always
RestartSec=5s
User=nobody
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

`xray-server.service`

```ini
[Unit]
Description=Xray Server (REALITY Inbound → freedom)
After=network.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/xray -config /etc/xray/out.config
Restart=always
RestartSec=5s
User=nobody
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

如使用自编译的 Nginx，还需创建 `nginx.service`：

```ini
[Unit]
Description=NGINX HTTPS Forwarder (TLS termination)
After=network.target

[Service]
ExecStart=/usr/sbin/nginx -g 'daemon off;'
ExecReload=/bin/kill -HUP $MAINPID
ExecStop=/bin/kill -QUIT $MAINPID
PIDFile=/run/nginx.pid
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

启用并启动全部服务：

```bash
systemctl daemon-reexec
systemctl enable --now xray-server.service xray-client.service nginx.service
```

### Nginx 配置

`/etc/nginx/conf.d/www.svc.plus.conf`

```nginx
server {
  listen 443 ssl http2;
  server_name www.svc.plus;

  ssl_certificate     /etc/ssl/certs/www.svc.plus.pem;
  ssl_certificate_key /etc/ssl/private/www.svc.plus.key;

  location / {
    proxy_pass http://127.0.0.1:1081;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }
}
```

### Xray 客户端配置 `/etc/xray/in.config`

```json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 1081,
      "listen": "127.0.0.1",
      "protocol": "http",
      "tag": "http-in",
      "settings": {}
    }
  ],
  "outbounds": [
    {
      "tag": "to-reality",
      "protocol": "vless",
      "settings": {
        "vnext": [
          {
            "address": "127.0.0.1",
            "port": 8443,
            "users": [
              {
                "id": "REPLACE-WITH-UUID",
                "encryption": "none"
              }
            ]
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "serverName": "global-homepage.onwalk.net",
          "publicKey": "REPLACE-WITH-PUBLIC-KEY",
          "shortId": "12345678"
        }
      }
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "inboundTag": ["http-in"],
        "outboundTag": "to-reality"
      }
    ]
  }
}
```

### Xray 服务端配置 `/etc/xray/out.config`

```json
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 8443,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "tag": "reality-in",
      "settings": {
        "clients": [
          {
            "id": "REPLACE-WITH-UUID",
            "flow": ""
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "global-homepage.onwalk.net:443",
          "xver": 0,
          "serverNames": ["global-homepage.onwalk.net"],
          "privateKey": "REPLACE-WITH-PRIVATE-KEY",
          "shortIds": ["12345678"]
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "inboundTag": ["reality-in"],
        "outboundTag": "direct"
      }
    ]
  }
}
```

启动测试方式：

```bash
xray -config /etc/xray/out.config &
xray -config /etc/xray/in.config &
systemctl restart nginx
```

今后访问 `https://www.svc.plus` 应可看到 Cloudflare Worker 的返回内容。
