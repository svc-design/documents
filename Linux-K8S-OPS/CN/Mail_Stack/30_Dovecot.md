
# 30_Dovecot — 收信与本地投递配置

## 1. 服务角色
提供 IMAP/IMAPS 收信与 LDA 本地投递。

## 2. 核心配置文件
/etc/dovecot.conf
/etc/dovecot/conf.d/10-mail.conf
/etc/dovecot/conf.d/10-auth.conf
/etc/dovecot/conf.d/10-master.conf

shell
复制代码

## 3. Maildir 存储
mail_location = maildir:~/Maildir

markdown
复制代码

## 4. 权限
- 用户：`support`
- 组：`mail:x:8:dovecot,chasquid`
- Maildir 路径：
/home/support/Maildir/{cur,new,tmp}

makefile
复制代码

## 5. 认证机制
```ini
auth_mechanisms = plain login
disable_plaintext_auth = yes
6. 验证
bash
复制代码
openssl s_client -connect imap.svc.plus:993
登录测试：

css
复制代码
a LOGIN support@svc.plus a4h3ljbn
a LIST "" "*"
📘 docs/40_Debug.md
markdown
复制代码
# 40_Debug — 测试与诊断方法

## 1. 发信测试
```bash
swaks --server smtp.svc.plus --port 587 --tls \
  --auth PLAIN \
  --auth-user "support@svc.plus" \
  --auth-password "a4h3ljbn" \
  --from "support@svc.plus" \
  --to "support@svc.plus"
2. 收信测试
bash
复制代码
openssl s_client -connect imap.svc.plus:993
3. 本地收件目录
bash
复制代码
ls -lt /home/support/Maildir/new/
4. 快速调试脚本
bash
复制代码
/usr/local/bin/mail_debug.sh
可检查：

端口占用

TLS 证书

Dovecot 状态

Chasquid 队列
