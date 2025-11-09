# 99_Troubleshoot — 常见错误与修复

## 1. 权限错误
lda(support): Error: net_connect_unix(/run/dovecot/stats-writer) failed: Permission denied

go
复制代码
→ 修复：
```ini
service auth {
  unix_listener auth-userdb {
    mode = 0777
  }
}
2. MDA 投递失败
vbnet
复制代码
Fatal: setresgid(...) failed with euid=chasquid: Operation not permitted
→ 将 chasquid 加入 mail 组。

3. TLS 证书问题
bash
复制代码
openssl x509 -in /etc/ssl/svc.plus.pem -noout -dates
4. 调试命令
bash
复制代码
journalctl -fu chasquid
journalctl -fu dovecot
yaml

