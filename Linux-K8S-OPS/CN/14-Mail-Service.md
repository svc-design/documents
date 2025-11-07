
邮件系统专题（Mail Service）
14.1 邮件系统部署与安全发信实践

现代邮件系统由三大部分组成：

MTA（Mail Transfer Agent）：传输与转发邮件，如 Postfix、Exim。

MDA（Mail Delivery Agent）：投递与存储邮件，如 Dovecot。

MUA（Mail User Agent）：用户客户端，如 Thunderbird、Outlook、Apple Mail。

🔌 协议与端口标准
协议	端口	加密	功能	标准
SMTP	25	STARTTLS	MTA 中继	RFC 5321
Submission	587	STARTTLS	用户发信	RFC 6409
SMTPS	465	Implicit TLS	兼容旧客户端	RFC 8314
IMAP	143	STARTTLS	邮件同步	RFC 3501
IMAPS	993	Implicit TLS	加密收信	RFC 8314
POP3	110	STARTTLS	拉取收件	RFC 1939
POP3S	995	Implicit TLS	加密收件	RFC 8314

在现代部署中，推荐使用 587 (STARTTLS) 作为主要发信端口，465 用于兼容性支持。

🧭 DNS 信任链配置（四大核心）
功能	记录类型	示例	说明
SPF	TXT	"v=spf1 a mx ip4:203.0.113.42 ~all"	防止伪造发件
DKIM	TXT	"v=DKIM1; k=rsa; p=MIIBIjANBg..."	保证邮件完整性
DMARC	TXT	"v=DMARC1; p=quarantine; rua=mailto:dmarc@svc.plus"	SPF/DKIM 失败策略
PTR	PTR	203.0.113.42 → mail.svc.plus	发信 IP 与主机名反查一致
🧱 系统组件职责
组件	职责	示例软件
SMTP (MTA)	发信 / 中继	Postfix
IMAP (MDA)	用户邮箱访问 / SASL	Dovecot
签名	邮件签名验证	OpenDKIM
加密	证书管理与 TLS	Let’s Encrypt / acme.sh
反垃圾	邮件信誉 / 灰名单	Rspamd / SpamAssassin
🔒 安全机制

STARTTLS：明文连接后升级为加密（587 常用）

SASL：认证机制（LOGIN / PLAIN / XOAUTH2）

DKIM + SPF + DMARC：信任与防伪造核心

MTA-STS / DANE：强制传输加密策略

🧩 典型发信架构（svc.plus 示例）
[ Web 应用 (注册/工单系统) ]
          │
          ▼
    [ Postfix - 发信 MTA ]
          │
          ▼
    [ Dovecot - SASL 登录 ]
          │
          ▼
    [ OpenDKIM - 邮件签名 ]
          │
          ▼
     [ Internet / Gmail / Outlook ]

🧠 关键命令
# 测试 SMTP TLS
openssl s_client -starttls smtp -connect mail.svc.plus:587

# 验证 DKIM 记录
dig txt default._domainkey.svc.plus

# 发送测试邮件
swaks --server mail.svc.plus --port 587 --tls \
  --auth LOGIN --auth-user noreply@svc.plus \
  --auth-password 'password' \
  --from noreply@svc.plus --to test@gmail.com
