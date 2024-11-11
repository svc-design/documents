# 3. 配置

## 3.1 Keycloak 默认语言设置

登录到 Keycloak，点击左侧菜单栏中的 **Realm Settings**。

1. 点击 **Themes**，将所有属性设置为 `keycloak`。
2. 在 **Internationalization Enabled** 选项中选择 **ON**。
3. 将 **Default Locale** 设置为 `zh-CN`。

重新登录时，在登录页面会显示语言切换项。

## 3.2 Keycloak 安全设置

选择需要配置的 Realm，点击左侧菜单中的 **Authentication** -> **Required Actions**，建议开启以下配置项：

- **configure-opt**: 开启
- **update-password**: 开启

## 3.3 Keycloak 新建 Realm

出于安全的需要，生产环境不建议直接使用默认的 **Master**，可以按照角色或不同用途建立不同的 Realm。

## 3.4 Keycloak 新建 Client

以新建 Gitlab OIDC 客户端为例，参考操作如下：

1. **Keycloak 侧配置**：选择一个 Realm，左侧侧边栏点击 **Clients**，右侧点击 **Create** 客户端。

    - **客户端类型**: OpenID Connect (关键配置项)
    - **客户端 ID**: `gitlab-oidc` (关键配置项)
    - **客户端 Name**: `gitlab-oidc`

2. 选择下一步，**客户端验证**：开启（关键配置项）。

    选择下一步：

    - **Home URL**: 添加 `https://<gitlab-domain>`（关键配置项）
    - **有效的重定向 URI**: 添加 `https://<gitlab-domain>/users/auth/openid_connect/callback`（关键配置项）

3. 保存并记录 `gitlab-oidc` 客户端密钥。

## 3.5 Keycloak 新建 User

在创建好的 Realm 中，创建属于这个 Realm 下的用户，Realm 之间具备逻辑隔离属性。
