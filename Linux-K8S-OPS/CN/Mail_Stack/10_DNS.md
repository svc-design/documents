
# 10_DNS — 邮件域名解析配置

## 1. 目标
确保域名正确解析发信与收信路径，符合 SPF / DKIM / DMARC 规范。

三、DNS 配置
类型	主机	内容	说明
A	smtp.svc.plus	167.179.72.223	SMTP + Submission
A	imap.svc.plus	167.179.72.223	IMAPS
MX	svc.plus	10 smtp.svc.plus	邮件交换记录
TXT	svc.plus	"v=spf1 a mx ~all"	SPF 授权
TXT	_dmarc.svc.plus	"v=DMARC1; p=none; rua=mailto:support@svc.plus"	DMARC 报告
TXT	default._domainkey.svc.plus	(公钥字符串)	DKIM 验签

可选：增加 AAAA 记录以支持 IPv6 收发。


## 2. 基础记录
| 类型 | 主机 | 内容 | 说明 |
|------|------|------|------|
| A | smtp.svc.plus | 167.179.72.223 | SMTP + Submission |
| A | imap.svc.plus | 167.179.72.223 | IMAPS |
| MX | svc.plus | 10 smtp.svc.plus | 邮件交换记录 |

## 3. SPF

## 3. SPF
"v=spf1 a mx ~all"

cpp
复制代码
验证：
```bash
dig txt svc.plus +short
4. DKIM
生成：

bash
复制代码
cd /etc/chasquid/domains/svc.plus
chasquid-util make-dkim svc.plus default
DNS 记录：

cpp
复制代码
default._domainkey.svc.plus  TXT  "v=DKIM1; k=rsa; p=MIIBIjANBg..."
5. DMARC
perl
复制代码
_dmarc.svc.plus  TXT  "v=DMARC1; p=none; rua=mailto:support@svc.plus"
6. 验证命令
bash
复制代码
dig mx svc.plus
dig txt _dmarc.svc.plus
dig txt default._domainkey.svc.plus

