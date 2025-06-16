# SSL 配置

1. 使用 `certbot` 或阿里云免费证书服务申请 Let’s Encrypt 证书。
2. 在阿里云 CDN 与 Cloudflare CDN 中分别上传证书，开启 HTTPS。
3. 在香港 OSS 和东京轻量云服务器上同步配置证书，以支持回源 HTTPS。
4. 设置自动续期脚本，确保证书不过期。
