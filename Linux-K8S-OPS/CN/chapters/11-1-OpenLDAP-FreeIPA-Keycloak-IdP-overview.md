# OpenLDAP / FreeIPA / Keycloak IdP 概览

## 一句话定位

- **OpenLDAP**：纯 LDAP 目录服务 → 最小可用、可塑性强，但周边（Kerberos、PKI、DNS、MFA、策略）都要你自己拼。
- **FreeIPA**：一体化 Linux 身份与安全域（389-DS LDAP + MIT Kerberos + Dogtag CA + DNS + HBAC/sudo）→ “像 AD 的开源版（偏 Linux）”。
- **Keycloak**：现代 Web SSO IdP（OIDC/SAML）+ 联邦（LDAP/AD 同步）+ MFA/自助门户 → 面向应用层的登录和令牌。

## 架构与能力对照

| 维度 | OpenLDAP | FreeIPA | Keycloak (IdP) |
| --- | --- | --- | --- |
| 核心定位 | 目录服务 (LDAP) | 身份域（LDAP+Kerberos+CA+DNS+策略） | Web SSO（OIDC/SAML）、身份编排 |
| 协议 | LDAP(v3)、StartTLS、SASL | LDAP、Kerberos、GSSAPI、DNS、X.509 | OIDC/OAuth2、SAML、OAuth 代理、LDAP 联邦 |
| 身份数据 | 你自定义 schema/ACL | 现成 schema + 主机/服务账号/策略对象 | 用户/组在内部库或来自“联邦”（LDAP/AD/外部 IdP） |
| 认证 | Simple Bind/SASL | Kerberos（TGT/TGS）、OTP for Kerberos | 交互式登录、令牌签发（JWT/SAML）、MFA |
| MFA | 无内建（需外置） | 有 OTP（整合 Kerberos），Web 场景常与 Keycloak 配合 | 内建 TOTP、WebAuthn/FIDO2、条件/策略 |
| PKI/证书 | 自己搭（Easy-RSA/CFSSL 等） | 自带 CA（Dogtag），主机/服务证书自动化 | 用于签发 OIDC token 的密钥/证书；不做端到端 PKI |
| 主机/域管控 | 无 | HBAC、Sudo 规则、主机/服务主体、DNS | 无（聚焦应用登录） |
| AD 互操作 | 需要你自己做同步/映射 | 支持与 AD 信任 / 同步 | 可直接对接 AD/LDAP 做“用户联邦” |
| HA | Syncrepl/MirrorMode | 多主（389-DS 复制）+ 多副本 IPA | 无状态集群 + 外部数据库 (PostgreSQL) |
| 管理界面 | 无官方 UI（有第三方） | 自带 WebUI/CLI | 丰富 Web 管理控制台、API/SPI |
| 典型用例 | 轻量目录、网络设备/老系统认证 | Linux 域（SSSD 入域）、证书、策略、一体化 | 业务系统统一登录、应用到应用的 OIDC/SAML |

## 推荐的三种落地模式

### A. 仅目录/老系统：OpenLDAP 单用

适合：网络设备、传统中间件只会 LDAP Bind 的场景。

你要补齐：备份、HA（syncrepl）、密码策略、MFA（反向代理或 PAM 侧做）、证书。

### B. FreeIPA 做“地基”，Keycloak 做“门面”（生产常用）

```
Linux 主机/服务 →(SSSD/Kerberos)→ FreeIPA (LDAP/KDC/CA/DNS)
Web/移动应用 →(OIDC/SAML)→ Keycloak →(User Federation)→ FreeIPA
```

优点：

- 主机侧用 Kerberos/SSSD 入域，证书/主机加入/策略集中管理。
- 应用侧用 Keycloak 统一登录、MFA、社交/外部 IdP 编排。
- FreeIPA 仍是“单一事实源”，Keycloak 同步/只读用户属性。

### C. Keycloak 单用 + 内置用户库（最小 IdP）

适合：只要应用 SSO（OIDC/SAML），没有主机入域/证书/Kerberos 诉求。

快，轻，但目录与主机安全侧能力较弱；企业化后常演进到 B 或对接 AD。

## 关键实现要点（实操）

### 3.1 Keycloak ←→ FreeIPA（LDAP 联邦）最小配置

在 Keycloak 的 Realm 中添加 User Federation → LDAP：

- Vendor: rhds（389-DS，与 FreeIPA 同源）或 “other”
- Connection URL: `ldaps://ipa.example.com:636`
- Bind DN: `uid=svc-keycloak,cn=users,cn=accounts,dc=example,dc=com`
- Use Truststore SPI: Only for ldaps
- Import Users: ON（首次同步）
- Sync Registrations: 视需求（通常 OFF，保持 FreeIPA 为权威）
- Edit Mode: READ_ONLY（推荐，避免写回破坏策略）
- UUID LDAP Attribute: `ipaUniqueID`（或 `nsUniqueId`）
- Username LDAP Attribute: `uid`
- RDN LDAP Attribute: `uid`
- Search Base: `cn=users,cn=accounts,dc=example,dc=com`
- Groups DN: `cn=groups,cn=accounts,dc=example,dc=com`
- Attribute Mappers（例）：
  - `givenName` → `firstName`
  - `sn` → `lastName`
  - `mail` → `email`
  - `uid` → `username`
- 组同步使用 `groupOfUniqueNames` 或 FreeIPA 默认 posix 组映射
- Token Claim Mappers（客户端维度）：
  - 把 groups 发到 `realm_access.roles` 或自定义 claim，供微服务做鉴权。

生产强烈建议：Keycloak 使用外部 PostgreSQL，两副本以上 + 反代/Ingress，定期做全量&增量 LDAP 同步（按小时/日）。

### 3.2 Linux 主机加入 FreeIPA 域（示意）

```bash
# 客户端
sudo ipa-client-install \
  --mkhomedir \
  --domain example.com \
  --server ipa1.example.com \
  --realm EXAMPLE.COM
# 成功后：SSSD 接管 nss/pam，sudo/hbac 从 IPA 下发
```

### 3.3 Keycloak（Quarkus）最小化部署（容器）

```yaml
# docker-compose 片段（生产改用 K8s + 外部 PG）
services:
  keycloak:
    image: quay.io/keycloak/keycloak:latest
    command: ["start", "--hostname","sso.example.com","--proxy","edge"]
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://pg:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: strongpass
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: adminpass
    ports: ["8080:8080"]
    depends_on: [pg]
  pg:
    image: postgres:16
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: strongpass
```

## HA 与运行建议

- **OpenLDAP**
  - 用 syncrepl + accesslog 做多主/镜像；配置 ACL 细到条目/属性；备份 `cn=config` 与数据分离。
- **FreeIPA**
  - 官方推荐多副本（`ipa-replica-install`）；DNS/CA 也可多副本。
  - 不建议强行容器化主节点（systemd/时间/网络依赖多），更稳是 VM/裸金属。
- **Keycloak**
  - 无状态多副本 + 外部 PostgreSQL；开启健康检查；令牌签名密钥按 realm 备份。
  - 生产打开 HTTPS（前置反向代理或直接 TLS），设置 `--hostname` 与反代一致；合理设置 SSO Session/Access Token TTL 与缓存。

## MFA / SCIM / RADIUS / 审计

- **MFA**
  - Keycloak：原生 TOTP、WebAuthn/FIDO2、条件认证（基于客户端/用户/风险扩展）。
  - FreeIPA：OTP for Kerberos（SSH / 控制台很有用）；Web 应用 MFA 还是交给 Keycloak。
  - OpenLDAP：无内建，常通过代理或 PAM 链路加二次因子。
- **SCIM**
  - Keycloak：通过社区 SCIM 扩展或事件 SPI 对接。
  - FreeIPA/OpenLDAP：无官方 SCIM，通常用中间件（同步器/自写桥）。
- **RADIUS**
  - Keycloak 有插件可做 RADIUS 代理；FreeIPA 常配 FreeRADIUS（Kerberos/OTP 背书）。
- **审计**
  - Keycloak 事件监听 SPI → 推到 Kafka/ES/ClickHouse。
  - FreeIPA/389-DS 有 access/error 日志；OpenLDAP 用 accesslog overlay。

## 如何选型（给你一个清单）

- 需要 Linux 主机入域 + Kerberos 单点 + 证书/DNS/HBAC/sudo → **FreeIPA**（地基）。
- 需要 Web/微服务统一登录（OIDC/SAML）+ MFA + 社交/企业 IdP 编排 → **Keycloak**（门面）。
- 只有轻量目录或设备/遗留系统只认 LDAP → **OpenLDAP**。
- 与 AD 共存：
  - 有 Windows 域 → 优先 AD + Keycloak（Keycloak 联邦 AD）。
  - 以 Linux 为主、又想“像 AD 那样的一站式” → FreeIPA + Keycloak。

