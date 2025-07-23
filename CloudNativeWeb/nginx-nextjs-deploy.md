# Nginx + Next.js 应用部署指南

本文档整合了使用 Nginx 配合 Next.js 生产应用的部署方法，涵盖 SSL 证书配置、反向代理及静态站点构建流程。

## 1. Nginx 配置示例

编辑 `/etc/nginx/sites-available/default`，实现 HTTP 自动跳转到 HTTPS，并将请求代理到本地的 Next.js 服务（端口 3000）：

```nginx
# HTTP 自动跳转到 HTTPS
server {
  listen 80;
  server_name svc.plus www.svc.plus;
  return 301 https://svc.plus$request_uri;
}

# HTTPS 主站配置，仅 svc.plus
server {
  listen 443 ssl http2;
  server_name svc.plus;

  ssl_certificate /etc/ssl/svc.plus.pem;
  ssl_certificate_key /etc/ssl/svc.plus.rsa.key;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers HIGH:!aNULL:!MD5;

  # 默认根路由反代 Next.js 运行服务
  location / {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }

  # 显式处理 Next.js 静态资源路径，防止被 cache 规则干扰
  location ^~ /_next/ {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }

  # 静态资源优化缓存（不影响 _next 路径）
  location ~* \.(?:ico|css|js|gif|jpe?g|png|woff2?)$ {
    expires 30d;
    access_log off;
    add_header Cache-Control "public";
    try_files $uri @fallback;
  }

  # fallback 防止刷新页面报 404
  location @fallback {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }

  # favicon.ico 单独处理
  location = /favicon.ico {
    access_log off;
    log_not_found off;
    try_files /favicon.ico @fallback;
  }
}
```

在启用该配置后执行 `sudo nginx -t` 进行语法检查，并通过 `sudo systemctl reload nginx` 使配置生效。

## 2. Systemd 服务示例

为了让 Next.js 应用在后台稳定运行，可创建 `/etc/systemd/system/nextjs-app.service`：

```ini
[Unit]
Description=Next.js Production App
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/XControl/ui/homepage
ExecStart=yarn next dev -p 3000
Restart=always
Environment=NODE_ENV=production
Environment=PORT=3000

[Install]
WantedBy=multi-user.target
```
```

启用并启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now nextjs-app.service
```

此服务将监听 3000 端口，与 Nginx 配置中的代理端口保持一致。

## 3. 使用 Yarn 构建和导出静态站点

在项目目录 `/var/www/XControl/ui/homepage` 提供了 `Makefile`，常用目标如下：

- `init`：安装依赖（若未安装 `yarn` 将尝试通过 Homebrew 安装）。
- `dev`：启动开发服务器，默认端口为 3001。
- `build`：构建生产版本。
- `export`：执行 `next build` 并将静态文件导出至 `out` 目录，可用于部署纯静态站点。
- `clean`：清理 `.next` 和 `out` 目录。

示例流程：

```bash
cd /var/www/XControl/ui/homepage
make init     # 安装依赖
make build    # 生产构建
make export   # 可选：导出静态站点
```

构建完成后，可通过 Nginx 反向代理 `ExecStart` 指定的端口（默认 3000）或直接部署 `out` 目录中的静态文件。

## 4. 总结
通过以上步骤，可实现 Nginx 在前端提供 SSL 与缓存能力，后端由 Next.js 应用处理动态请求。同时可选择导出静态站点，提升访问速度并降低服务器负载。
