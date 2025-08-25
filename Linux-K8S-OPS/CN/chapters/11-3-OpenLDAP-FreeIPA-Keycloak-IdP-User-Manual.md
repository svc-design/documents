# Keycloak + FreeIPA 一体化身份系统操作手册

## 1. 管理员手册

### 用户与组管理
- 创建用户（FreeIPA CLI）：
  ```bash
  ipa user-add alice --first=Alice --last=Lee --email=alice@corp.example.com
  ```
- 分配组：
  ```bash
  ipa group-add-member devops --users=alice
  ```
- 重置密码：
  ```bash
  ipa passwd alice
  ```
- 禁用/删除用户：
  ```bash
  ipa user-disable alice
  ipa user-del alice
  ```

### 策略与权限
- HBAC 策略（控制谁能登录哪些主机）：
  ```bash
  ipa hbacrule-add allow_ssh --user=devops --host=linux-servers --service=sshd
  ```
- sudo 权限：
  ```bash
  ipa sudorule-add allow_admins --user=admins --cmdcat=all
  ```
- Keycloak 应用授权：在 Keycloak 控制台 → Clients → Roles/Groups，绑定对应 FreeIPA 组到应用权限。

### 系统运维
- 备份 FreeIPA：
  ```bash
  ipa-backup --data
  ```
- Keycloak Realm 导出：
  ```bash
  ./kc.sh export --dir /backup --realm corp
  ```

## 2. 成员使用者手册

### 登录 Linux 主机
1. 初次登录：使用管理员分配的账号/密码，系统会强制修改密码。
2. 日常使用：
   ```bash
   kinit alice   # 获取 Kerberos 票据
   ssh -K server1   # 免密 SSH 登录
   ```

### 登录业务系统
1. 打开应用（如 https://app.corp.example.com），自动跳转到 Keycloak 登录页。
2. 输入 FreeIPA 用户名/密码 → 绑定 MFA（TOTP/手机扫码或 FIDO Key）。
3. 已登录的情况下，访问其他系统自动单点登录。

## 3. 临时授权手册

### 临时用户（外包/访客）
- 创建带有效期的账号：
  ```bash
  ipa user-add temp123 --first=Temp --last=User --random --expires=20250831
  ```
- 临时用户首次登录需改密码并绑定 MFA。
- 访问权限由 HBAC/sudo/Keycloak Role 指定，过期后自动失效。

### 临时提权（现有成员）
- 追加临时组：
  ```bash
  ipa group-add-member temp-admin --users=alice
  ipa group-mod temp-admin --setattr=ipaUserExpiration=20250831
  ```
- Keycloak 中对应的组映射会自动生效 → 用户临时获得更高权限，到期自动失效。

## 流程图
```mermaid
flowchart TD
    subgraph Admin[管理员配置]
        A1[创建用户/组\nFreeIPA] --> A2[配置 HBAC/sudo 策略]
        A2 --> A3[配置 Keycloak 联邦\n设置应用授权]
    end

    subgraph User[成员使用]
        U1[成员获取账号] --> U2[首次登录\n修改密码 + 绑定 MFA]
        U2 --> U3[Linux 登录:\nKerberos kinit + SSH SSO]
        U2 --> U4[应用登录:\nKeycloak OIDC/SAML 单点登录]
    end

    subgraph Temp[临时授权]
        T1[管理员创建临时账号\n或临时加入高权限组] --> T2[临时用户登录\n绑定 MFA]
        T2 --> T3[按策略访问主机/应用]
        T3 --> T4[到期自动收回权限\n(账号失效/组移除)]
    end

    Admin --> User
    Admin --> Temp
```

## 效果总结
- 单一身份源：账号/组集中在 FreeIPA，消除多处维护。
- 双通道 SSO：Linux 主机和应用层同时实现统一认证与单点登录。
- 安全合规：MFA、集中策略、证书自动化、审计全覆盖。
- 高可用扩展：多副本架构，支持企业级高并发与跨站点部署。
- 低运维负担：自动复制、集中策略、IaC 化部署，简化日常运维。
