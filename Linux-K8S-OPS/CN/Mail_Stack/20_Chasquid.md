
# 20_Chasquid — 发信服务配置

## 1. 服务角色
负责 SMTP Submission（587）与加密 SMTPS（465）发信。

## 2. 配置路径
/etc/chasquid/chasquid.conf
/etc/chasquid/domains/svc.plus/
/etc/chasquid/users/

makefile
复制代码

## 3. 关键配置项
```ini
hostname = "smtp.svc.plus"
data_dir = "/var/lib/chasquid"
tls_cert = "/etc/ssl/svc.plus.pem"
tls_key  = "/etc/ssl/svc.plus.key"
mail_delivery_agent_bin  = "/usr/lib/dovecot/dovecot-lda"
mail_delivery_agent_args = ["-f", "%from%", "-d", "%to%"]
4. 用户管理
bash
复制代码
chasquid-util user-add support@svc.plus
chasquid-util user-list
5. DKIM 签名
swift
复制代码
/etc/chasquid/domains/svc.plus/dkim.key
6. 发信验证
bash
复制代码
swaks --server smtp.svc.plus --port 587 --tls \
  --auth PLAIN \
  --auth-user "support@svc.plus" \
  --auth-password "a4h3ljbn" \
  --from "support@svc.plus" \
  --to "support@svc.plus"
