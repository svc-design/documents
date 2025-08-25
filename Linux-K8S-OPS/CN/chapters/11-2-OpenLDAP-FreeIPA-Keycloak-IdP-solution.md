# Keycloak + FreeIPA 生产级架构与实施手册（Linux 域 + Web SSO）

Keycloak ←→ FreeIPA（LDAP 联邦）一体化身份体系：架构与实施手册

场景：以 Linux Server 为主的环境，FreeIPA 作为“地基”（目录/Kerberos/证书/DNS/HBAC/sudo），Keycloak 作为“门面”（Web SSO：OIDC/SAML + MFA + 身份编排）。

0. 目标与范围

统一身份源：用户与组在 FreeIPA（389-DS）中为单一事实源；Keycloak 只做登录与令牌签发。

双通道 SSO：

系统侧：Linux 主机入域，SSH/Kerberos SSO、HBAC、sudo 策略集中下发。

应用侧：OIDC/SAML 统一登录、MFA、社交/企业 IdP 编排。

高可用/可观测/易运维：多副本、灰度升级、完备监控与备份。

SLO（建议）：

登录成功率 ≥ 99.95%（月）；

令牌签发 P95 < 300ms；

FreeIPA 变更复制延迟 P95 < 10s。

1. 参考架构
```mermaid
flowchart LR
  subgraph Infra[Network / Infra]
    LB[(L4/L7 LB)]
    DNS[(FreeIPA DNS Zone)]
  end


  subgraph Core[Core Identity Plane]
    IPA1[(FreeIPA Primary)]
    IPA2[(FreeIPA Replica A)]
    IPA3[(FreeIPA Replica B)]
    subgraph PKI[Dogtag CA / ACME]
      CA1[(IPA CA)]
    end
  end


  subgraph IdP[Keycloak Cluster]
    KC1[(Keycloak Pod/VM #1)]
    KC2[(Keycloak Pod/VM #2)]
    DB[(PostgreSQL HA)]
  end


  subgraph Linux[Linux Servers]
    H1[Host A (SSSD)]
    H2[Host B (SSSD)]
  end


  LB---KC1
  LB---KC2
  KC1---DB
  KC2---DB
  KC1==LDAPS(636)==>IPA1
  KC2==LDAPS(636)==>IPA2


  H1==Kerberos/LDAP==>IPA1
  H1==Kerberos/LDAP==>IPA2
  H1==Kerberos/LDAP==>IPA3
  H2==Kerberos/LDAP==>IPA2


  DNS-.SRV/Kerberos/LDAP.->H1
  DNS-.SRV/Kerberos/LDAP.->KC1
```

要点：

FreeIPA 主（Primary）+ 至少 2 个 Replica，多站点可各放 1 个副本。

Keycloak 无状态多副本 + 外部 PostgreSQL（主从或 Patroni/CloudNativePG）。

Keycloak 通过 LDAPS 联邦到 FreeIPA；Keycloak 信任 FreeIPA CA。

Linux 主机使用 SSSD 入域，Kerberos/GSSAPI 实现 SSH/控制台 SSO；HBAC/sudo 从 IPA 下发。

2. 组件与资源建议（起步/增长）
| 组件 | 起步规模 | 典型资源（vCPU/RAM/磁盘） | 备注 |
| --- | --- | --- | --- |
| FreeIPA Primary | 1 台 | 2C / 4–8GB / 40GB+ | 物理或 VM，不建议容器化主节点 |
| FreeIPA Replica | 2 台 | 2C / 4–8GB / 40GB+ | 跨可用区部署 |
| Keycloak | 2 副本 | 每副本 2C / 4–8GB | K8s 部署或独立 VM；开启 metrics |
| PostgreSQL | 3 节点 | 每节点 2–4C / 8–16GB / SSD | Patroni/CloudNativePG/主从；WAL 归档 |
| 反向代理/LB | 托管或自建 | - | 入口 TLS/HTTP/2、会话亲和（可选） |
| 监控/日志 | - | - | Prometheus + Loki/OpenObserve + Grafana |

容量经验值（仅供估算）：

Keycloak 每核可支撑 ~100–300 次 token 签发/秒（视 SPI/联邦/缓存）；

PostgreSQL TPS 以 200–1000 为起步量级（依硬件）；

FreeIPA 复制延迟主要受网络与写入频率影响，常见 < 数秒。

3. 网络与安全基线
3.1 端口与协议

FreeIPA：TCP/UDP 88(Kerberos), 464(kadmin), TCP 389/636(LDAP/LDAPS), TCP 80/443(WebUI/JSON API), TCP/UDP 53(DNS)。

Keycloak：HTTP(S) 8080/8443（通常经 Ingress/反代暴露 443）。

PostgreSQL：TCP 5432。

3.2 DNS 与命名

Realm：EXAMPLE.COM；IPA 域：corp.example.com。

SRV 记录：_kerberos._udp, _kerberos._tcp, _ldap._tcp 指向各 IPA 实例。

Issuer：使用 IPA 内置 Dogtag CA；可启用 ACME 响应器（≥4.11） 为主机/服务签发证书。

3.3 TLS 与信任

Keycloak 的 JVM truststore 导入 IPA CA：确保与 LDAPS 正常握手。

外部访问均走 TLS；LDAPS 仅在内网开放并做 ACL/防火墙限制。

3.4 账户与权限

为 Keycloak 单独创建 只读 Bind DN：uid=svc-keycloak,cn=users,cn=accounts,...，最小权限访问 users/groups OU。

禁止匿名绑定；限制可读属性；启用密码策略与账号锁定策略。

4. 实施分阶段计划
Phase 0：前置准备

规划子网/VLAN、NTP、反代/LB、DNS 委派。

选择 OS（RHEL/Rocky/Alma/Debian 均可，IPA 官方更偏 RHEL 系）。

规划证书策略（IPA CA / ACME / 外部公有 CA）。

Phase 1：部署 FreeIPA（主 + 副本）
```bash
# 主节点安装（示例）
sudo ipa-server-install \
  --domain=corp.example.com \
  --realm=EXAMPLE.COM \
  --hostname=ipa1.corp.example.com \
  --ds-password 'DS_StrongPass' \
  --admin-password 'Admin_StrongPass' \
  --setup-dns --forwarder=8.8.8.8


# 生成副本准备包（在主节点）
sudo ipa-replica-prepare ipa2.corp.example.com


# 副本安装（到目标副本主机）
sudo ipa-replica-install --setup-ca --setup-dns


# 第 2 个副本同理（或直接无准备包安装，视版本/发行版）

验证：ipa topologysegment-find、ipa-replica-manage list、kinit admin、ipa user-find。

HBAC/sudo 基线（示意）：

ipa hbacrule-add allow_ssh
ipa hbacrule-add-service allow_ssh --hbacsvc=sshd
ipa hbacrule-add-user allow_ssh --users=admins
ipa hbacrule-add-host allow_ssh --hosts=hostgroup-servers


ipa sudorule-add allow_sudo_root --cmdcat=all
ipa sudorule-add-user allow_sudo_root --users=admins
ipa sudorule-add-host allow_sudo_root --hostcats=all
```
Phase 2：Linux 主机入域（SSSD/Kerberos）
```bash
sudo ipa-client-install \
  --domain=corp.example.com \
  --server=ipa1.corp.example.com \
  --realm=EXAMPLE.COM \
  --mkhomedir --enable-dns-updates


# 验证
kinit username
id username
ssh -K username@host   # GSSAPI 免密
```

默认会写入 /etc/sssd/sssd.conf、/etc/krb5.conf，并配置 PAM 与 nsswitch。

Phase 3：部署 PostgreSQL（Keycloak 外部库）

选型：Patroni/CloudNativePG（K8s）或 VM 上主从 + 自动故障切换。

打开 WAL 归档、合理 max_connections 与连接池（PgBouncer 可选）。

Phase 4：部署 Keycloak（K8s/VM）

K8s（示例，Helm/Operator 皆可）：
```yaml
# values 关键项（伪示例）
replicas: 2
extraEnv:
  - name: KC_DB
    value: postgres
  - name: KC_DB_URL
    value: jdbc:postgresql://pg-ha:5432/keycloak
  - name: KC_DB_USERNAME
    valueFrom: secretKeyRef: { name: kc-db, key: user }
  - name: KC_DB_PASSWORD
    valueFrom: secretKeyRef: { name: kc-db, key: pass }
  - name: KEYCLOAK_ADMIN
    valueFrom: secretKeyRef: { name: kc-admin, key: user }
  - name: KEYCLOAK_ADMIN_PASSWORD
    valueFrom: secretKeyRef: { name: kc-admin, key: pass }
  - name: KC_PROXY
    value: edge
  - name: KC_HOSTNAME
    value: sso.corp.example.com
  - name: KC_METRICS_ENABLED
    value: "true"
  - name: JAVA_TOOL_OPTIONS
    value: "-Xms512m -Xmx2048m"


ingress: { enabled: true, hosts: [sso.corp.example.com], tls: [...] }
```
将 IPA CA 注入 Keycloak Pod 的 JVM truststore（cacerts），确保 LDAPS 可用。

VM/Compose（最小测试）：
```yaml
services:
  keycloak:
    image: quay.io/keycloak/keycloak:latest
    command: ["start","--hostname","sso.corp.example.com","--proxy","edge","--metrics-enabled"]
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://pg:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: strongpass
      KEYCLOAK_ADMIN: admin
      KEYCLOAK_ADMIN_PASSWORD: adminpass
    ports: ["8080:8080"]
    volumes:
      - ./ipa-ca.crt:/opt/java/openjdk/lib/security/ipa-ca.crt:ro
```
Phase 5：Keycloak Realm 与 LDAP 联邦

创建业务 Realm（如 corp），开启 Login、Email、Tokens 策略（见 §6）。

User Federation → LDAP：

Connection URL：ldaps://ipa.corp.example.com:636

Bind DN：uid=svc-keycloak,cn=users,cn=accounts,dc=corp,dc=example,dc=com

Edit Mode：READ_ONLY（推荐）

Users DN：cn=users,cn=accounts,dc=corp,dc=example,dc=com

Groups DN：cn=groups,cn=accounts,dc=corp,dc=example,dc=com

UUID Attr：ipaUniqueID（或 nsUniqueId）

Username Attr：uid; 映射 givenName→firstName, sn→lastName, mail→email

Sync：开启周期性导入（hourly/daily），禁用写回。

Group Mapper：同步 POSIX 组到 Keycloak；必要时将组映射到 realm_access.roles 或自定义 claim。

Phase 6：MFA 与策略

启用 TOTP 与 WebAuthn/FIDO2，为敏感客户端设为必选或条件触发（基于 IP/组/风险等级）。

启用 Required Actions：首次登录绑定 TOTP、更新密码/邮箱。

SSO Session/Access Token/Refresh Token TTL：见 §6 建议值。

Phase 7：应用集成（示例）

Nginx + oauth2-proxy（适配任意后端）：

oauth2-proxy OIDC provider 指向 Keycloak；以 groups 或 roles claim 做鉴权。

Go（net/http）：coreos/go-oidc + oidc.Provider + verifier；缓存 JWKS；校验 aud/iss/exp。

Next.js：next-auth 的 Keycloak Provider；回调 URL 配置在客户端。

Phase 8：可观测性与审计

Keycloak：/metrics Prometheus 拉取；事件 SPI 输出到 Kafka/OTLP（可送到 OpenObserve/Loki）。

FreeIPA/389-DS：收集 access/error 日志；复制状态告警；证书到期告警。

Phase 9：备份与 DR

FreeIPA：

线上多副本即热备；仍需定期 ipa-backup（含 CA/LDAP/DNS）。

站点级故障：就近副本继续服务；主站恢复后自动追赶。

Keycloak：

以 DB 备份为主（逻辑/物理 + WAL 归档）；

定期导出 Realm 配置（防人为误改）。

PostgreSQL：全量+增量；演练 PITR（Point-in-time Recovery）。

5. 运行参数与安全加固（建议）
5.1 Keycloak 策略

Access Token Lifespan: 5–10 min；SSO Session Idle: 8–12 h；SSO Session Max: 24–72 h；

Refresh Token Lifespan: 30–60 min（长期会话可用 Offline Token）；

关闭按密码注册（由 IPA 权威）；启用密码复杂度与锁定策略（在 IPA 侧）。

SPI 扩展（如自定义条件认证）控制风险；限制管理控制台到办公网。

5.2 FreeIPA/LDAP/Kerberos

禁用匿名绑定；限制属性级 ACL。

Kerberos：仅允许强加密套件（aes256-cts-hmac-sha1-96 等）。

HBAC 最小化授权：默认拒绝，按主机组/服务开放。

sudo 规则最小化；审计提权命令。

5.3 容器与系统

Keycloak/DB 使用只读 RootFS（尽量）；Secrets 由 K8s Secret/外部 Vault 管理。

所有对外入口强制 TLS1.2+；启用 HSTS；禁用弱 Cipher。

6. 验证与验收清单
6.1 功能用例

目录一致性：在 IPA 新建用户 alice → N 分钟内出现在 Keycloak；id alice/getent passwd 生效。

Kerberos SSO：客户端 kinit alice，SSH 到目标主机无需密码（GSSAPI）。

HBAC/sudo：alice 在允许规则内可 SSH；admins 组具备 sudo 权限，普通用户无。

OIDC 登录：访问示例应用 → 跳转 Keycloak → MFA → 返回携带 id_token/access_token。

组驱动鉴权：devops 组可访问 /admin，其他 403。

6.2 高可用演练

Keycloak 副本故障：单 Pod 下线不影响登录；LB 自动切换。

PostgreSQL 主故障：副本提升为主；Keycloak 无需重启即可恢复。

IPA 副本故障：客户端与 Keycloak 自动切换到其他 SRV 记录；复制恢复后数据一致。

6.3 性能与容量

以压测工具（Gatling/k6 + OIDC 流程）模拟 100/500/1000 登录/秒；记录 P95、错误率。

目录同步作业对 DB/Keycloak 的影响评估（错峰执行）。

7. 示例配置片段
7.1 Nginx ↔ oauth2-proxy（Keycloak OIDC）
```nginx
location /oauth2/ {
  proxy_pass http://oauth2-proxy;  # 监听 4180
}
location / {
  auth_request /oauth2/auth;
  error_page 401 = /oauth2/sign_in;
  proxy_set_header X-Auth-Request-Email $upstream_http_x_auth_request_email;
  proxy_set_header X-Auth-Request-Groups $upstream_http_x_auth_request_groups;
  proxy_pass http://app;
}
```
7.2 Go（net/http）校验中间件（要点）
```go
provider, _ := oidc.NewProvider(ctx, "https://sso.corp.example.com/realms/corp")
verifier := provider.Verifier(&oidc.Config{ClientID: "my-client"})


token, err := verifier.Verify(ctx, rawIDToken)
// 校验 aud/iss/exp/iat；缓存 JWKS；处理签名轮换
```
7.3 Keycloak LDAP 联邦（kcadm 关键字段）
```bash
KCADM=/opt/keycloak/bin/kcadm.sh
$KCADM config credentials --server http://127.0.0.1:8080 --realm master \
  --user admin --password 'adminpass'


# 创建 realm
echo '{"realm":"corp","enabled":true}' | \
  $KCADM create realms -f -


# 创建 LDAP 联邦（示例，省略若干字段）
$KCADM create components -r corp -s name=ipa-ldap \
  -s providerId=ldap \
  -s providerType=org.keycloak.storage.UserStorageProvider \
  -s 'config.connectionUrl=["ldaps://ipa.corp.example.com:636"]' \
  -s 'config.usersDn=["cn=users,cn=accounts,dc=corp,dc=example,dc=com"]' \
  -s 'config.bindDn=["uid=svc-keycloak,cn=users,cn=accounts,dc=corp,dc=example,dc=com"]' \
  -s 'config.editMode=["READ_ONLY"]' \
  -s 'config.useTruststoreSpi=["ldaps"]'
```
组/属性 Mapper 需以 parentId=<组件ID> 另行创建，可在 UI 中完成。

8. 运维与升级策略

变更窗口：Keycloak 以滚动升级；先升级从库/副本，再升主库/主控；备份在前。

配置基线：所有变更 IaC 化（Helm/Kustomize/Ansible），PR 审核 + CI 验证。

审计：Keycloak Admin 操作与登录事件落日志；FreeIPA 访问日志归档与敏感字段脱敏。

9. 风险与对策

单点风险：外部 DB、IPA Primary、DNS → 多副本与健康探针；

证书到期：证书与 CA 到期监控；提前 30/15/7 天多级告警；

联邦抖动：LDAP 同步引发缓存雪崩 → 限流 + 分批同步；

跨站点延迟：复制拓扑分层（Hub-Spoke），SRV 记录就近解析。

10. 交付物清单（可扩展）

IaC：Keycloak（Helm/Kustomize）与 PostgreSQL（Operator/Helm）模板。

Ansible：FreeIPA 主/副本安装剧本、客户端入域剧本、HBAC/sudo 基线。

运维文档：备份与恢复、灾备演练、容量与阈值、升级 Runbook。

验收报告：功能/HA/性能三类用例通过记录。

附录：常见排障

Keycloak LDAPS 报错：检查 JVM truststore 是否包含 IPA CA；openssl s_client -connect ipa:636 验证链路。

SSO 回环/重定向错误：KC_HOSTNAME 与反代一致；Ingress 的 X-Forwarded-* 头。

Kerberos 票据失败：客户端/服务器时间偏差 >5min；NTP 校正；klist -e 查看加密算法。

组映射缺失：LDAP Group Mapper DN/过滤器是否正确；是否 posixGroup / groupOfNames 匹配。

