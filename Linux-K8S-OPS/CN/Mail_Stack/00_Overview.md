# Mail Stack Overview — Chasquid + Dovecot

## 一、目标与适用场景

本项目旨在构建一个轻量级、自托管、TLS 安全的邮件服务栈，适用于：
内部业务系统（注册验证、通知、工单、报告）；
少量对外邮件（支持@svc.plus等域名）；
无需 SQL / LDAP 的单机或小型集群部署；
具备标准 IMAP 收信与 SMTP 发信能力。

核心服务组合：

- Chasquid — 轻量级 SMTP 服务器，负责发信与中继；
- Dovecot — 稳定的 IMAP/POP3 服务端，同时提供 LDA 本地投递。

## 二、系统特性

功能	组件	协议	端口	状态
发信（Submission）	Chasquid	STARTTLS (587) / SMTPS (465)	✅
收信（IMAP）	Dovecot	IMAPS (993) / IMAP (143)	✅
本地投递（LDA）	Dovecot	UNIX socket	✅
认证机制	PAM / 系统用户	PLAIN, LOGIN	✅
存储格式	Maildir	/home/<user>/Maildir	✅
群组权限	mail group	Chasquid+Dovecot 共享	✅

## 三、DNS 配置

类型	主机	内容	说明
A	smtp.svc.plus	167.179.72.223	SMTP + Submission
A	imap.svc.plus	167.179.72.223	IMAPS
MX	svc.plus	10 smtp.svc.plus	邮件交换记录
TXT	svc.plus	"v=spf1 a mx ~all"	SPF 授权
TXT	_dmarc.svc.plus	"v=DMARC1; p=none; rua=mailto:support@svc.plus"	DMARC 报告
TXT	default._domainkey.svc.plus	(公钥字符串)	DKIM 验签

可选：增加 AAAA 记录以支持 IPv6 收发。

## 四、认证机制与安全性

机制	规范	安全条件	推荐度
PLAIN	RFC 4616	仅限 TLS 内使用	✅ 推荐
LOGIN	历史兼容	仅限 TLS 内使用	⚙️ 可保留

Dovecot 默认 disable_plaintext_auth = yes，意味着仅在 STARTTLS / IMAPS 下接受明文密码认证。

## 五、关键配置路径

/etc/dovecot.conf
/etc/dovecot/conf.d/10-mail.conf
/etc/dovecot/conf.d/10-auth.conf
/etc/dovecot/conf.d/10-master.conf
/etc/chasquid/chasquid.conf

Maildir 目录：/home/<user>/Maildir
系统用户组：mail:x:8:chasquid,dovecot
证书路径：/etc/ssl/svc.plus.{pem,key}

## 六、快速测试

1. 收信验证
openssl s_client -connect imap.svc.plus:993

2. 发信验证
swaks --server smtp.svc.plus --port 587 --tls \
  --auth PLAIN \
  --auth-user "support@svc.plus" \
  --auth-password "a4h3ljbn" \
  --from "support@svc.plus" \
  --to "support@svc.plus"

3. 本地投递检查
ls -lt /home/support/Maildir/new/

## 七、选型理由

对比项	Chasquid + Dovecot	Postfix + Dovecot	Stalwart / Maddy
复杂度	极低（单进程 Go 程序）	高	中
部署易度	✅ systemd 即可	❌ 需配置多模块	✅ 但较新
安全性	完全支持 TLS + DKIM + DMARC	同级	同级
性能	足以支撑中小型企业	稍高	类似
可读性	YAML/JSON 配置，现代风格	传统配置语法	类似
扩展能力	可配 LMTP + Rspamd	更成熟	新兴生态

结论：

Chasquid + Dovecot 的组合，天然适合中小规模、低延迟、安全可靠的自托管邮件系统。
它避免了 Postfix 的复杂 relay 配置，也比全能型新项目更稳定。

## 八、典型部署规模（经验参考）

场景	节点	用户数	每日邮件量	状态
内部通知系统	1×(2C/2G)	≤50	≤5k	稳定
SaaS 注册验证	2×(2C/4G)	≤200	≤20k	稳定
B2B 通知中心	3×(4C/8G)	≤800	≤100k	稳定（轻度队列）

可通过增加 Chasquid 节点线性扩展发信能力，共用 Dovecot 存储。

## 九、部署与自动化

systemd 资源限制
LimitNOFILE=65535
Restart=always
ProtectSystem=strict

## Ansible Playbook

ansible-playbook ansible/playbooks/deploy_mail.yml

CI/CD 流水线

ci-cd/mailstack-test.yml 自动执行 SMTP/IMAP 连通性验证

十、总结

Mail_Stack 是一个面向现代运维与开发团队的「最小可运行邮件系统」。
它不追求海量吞吐，而是追求可维护、可观察、可扩展。
通过 Chasquid（发信）+ Dovecot（收信）+ Systemd（守护）+ Ansible（部署），
实现一个企业级标准协议栈的轻量封装。

Chasquid + Dovecot 的“甜蜜区间”
特征	是否匹配
小型独立域（1–5 个）	✅ 理想
邮件日量 ≤ 5000	✅ 稳定
事务型通知、收件信箱	✅ 推荐
需要 DKIM/SPF/DMARC/SSL	✅ 原生支持
多租户或上万邮箱账户	🚫 不建议
灰度转发、垃圾过滤、速率限制	⚙️ 需外接 rspamd/clamav
企业邮件归档/索引系统	🚫 需外部方案（如 Solr / Elastic / Maildir indexer）

可扩展路径建议

前期（单节点）：
Chasquid + Dovecot + system user → 简洁稳定。
中期（小团队共享）：

启用虚拟用户（Dovecot userdb/passdb）；
Chasquid 改走 SQL 或 JSON 用户映射；
加 Rspamd 反垃圾中继；
邮件存储挂载 NFS 或 CephFS。

后期（企业多域）：

替换 Chasquid → Postfix；
保留 Dovecot；
加入 LDAP + Dovecot Director；
引入 Prometheus / Grafana 监控队列与延迟；
建立中继层（Relay）和归档层（Archive）。
