# CloudNative Web v1.0 架构总览

本文档概述了基于全球双源部署的 CloudNative Web v1.0 方案，覆盖 DNS 智能调度、CDN 加速、源站部署及未来扩展方向。具体实施细节请参考各子文档。

## 文档结构

- [部署步骤](deployment.md)
- [智能 DNS 配置](dns-config.md)
- [CDN 配置](cdn-config.md)
- [SSL 配置](ssl-config.md)
- [IAC 与 Ansible Playbook](iac-playbook.md)
- [成本模型](cost-model.md)
- [后续可扩展方案](future-roadmap.md)

## 架构图

```
+----------------- DNSPod Pro -----------------+
|                                               |
| CN用户  ——>  阿里云 CDN  ——> OSS (香港源站)     |
| 海外用户 ——> Cloudflare CDN ——> OSS (香港源站)  |
|                                               |
| 东京用户 ——> 阿里云东京轻量云 (Web缓存+镜像)  |
+-----------------------------------------------+
```

该架构利用 DNSPod Pro 实现 GeoDNS 调度，大陆用户走阿里云 CDN，海外用户走 Cloudflare CDN。核心内容存储在香港 OSS，东京轻量云服务器可作缓存节点或镜像，提高访问速度和可靠性。
