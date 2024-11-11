# 5.8 Harbor OIDC SSO 配置

## 5.8.1 Keycloak控制台操作：新建 Harbor OIDC 客户端

1. **Keycloak 侧配置：**
   - 选择一个 **Realm**，左侧侧边栏点击 **客户端**，右侧选择 **创建客户端**。
   - **客户端类型**: 选择 **OpenID connect** （关键配置项）。
   - **客户端ID**: 输入 `harbor-oidc` （关键配置项）。
   - **客户端名称**: 输入 `harbor-oidc`。

2. **选择下一步：**
   - **客户端验证**: 开启（关键配置项）。

3. **选择下一步：**
   - **Home URL**: 输入 `https://<harbor-domain>`（关键配置项）。
   - **有效的重定向URI**: 输入 `https://<harbor-domain>/c/oidc/callback`（关键配置项）。

4. **保存**，并记录生成的 `harbor-oidc` 客户端密钥。

## 5.8.2 Harbor侧配置：开启 OIDC 登录选项

1. **如果 Harbor 已经配置过本地数据库用户：**
   - 需要先清除所有普通用户，登录 Harbor DB 执行以下操作：
     ```sql
     \c registry
     select * from harbor_user;
     delete from harbor_user where username='haha#4';
     ```

2. **登录 Harbor 控制台，添加 OIDC 认证模式配置：**
   - 进入 Harbor 控制台，找到 **认证模式** 配置，选择 **OIDC** 认证。
   - 填入 Keycloak 生成的 OIDC 客户端信息，如 **客户端ID** 和 **客户端密钥**。

3. **重新打开 Harbor 登录页面：**
   - 登录页面将会新增 **OIDC 登录选项**。
   - 首次使用 OIDC 登录时，系统会自动为该用户创建一个本地用户，用户只需填写用户名即可完成登录。
