# 50_Scale — 扩展与多节点部署

## 1. 多节点架构
- 多个 Chasquid 节点：分担发信负载；
- 共用 Dovecot 存储节点：集中 Maildir 或 NFS；
- 统一 DNS MX 指向主节点或负载均衡器。

## 2. 可选组件
| 模块 | 作用 |
|------|------|
| Rspamd | 反垃圾、灰名单、评分过滤 |
| HAProxy / Nginx | SMTP/IMAP 负载均衡 |
| LMTP | 高效投递接口替代 LDA |

## 3. 持续集成
- Ansible Playbook 自动部署；
- GitHub Actions 执行 swaks + openssl 验证；
- 邮件发送监控（Grafana + VictoriaMetrics 可选）。

---
