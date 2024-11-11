# 5.9 Grafana OIDC SSO 配置

## 5.9.1 Keycloak控制台操作：新建 Grafana OIDC 客户端

1. **Keycloak 侧配置：**
   - 选择一个 **Realm**，左侧侧边栏点击 **客户端**，右侧选择 **创建客户端**。
   - **客户端类型**: 选择 **OpenID connect** （关键配置项）。
   - **客户端ID**: 输入 `grafana-oidc` （关键配置项）。
   - **客户端名称**: 输入 `grafana-oidc`。

2. **选择下一步：**
   - **客户端验证**: 开启（关键配置项）。

3. **选择下一步：**
   - **根 URL**: 输入 `https://<grafana-domain>`。
   - **Home URL**: 输入 `https://<grafana-domain>` （关键配置项）。
   - **有效的重定向URI**: 输入 `*` （关键配置项）。

4. **保存**，并记录生成的 `grafana-oidc` 客户端密钥。

## 5.9.2 Grafana侧配置：开启 OIDC 登录选项

1. **修改 `grafana.ini` 配置：**
   - 以容器集群内部署的 Grafana 为例，连接到部署的 Grafana 集群，执行以下命令：
     ```bash
     kubectl edit cm observability-server-grafana -n monitoring
     ```

2. **添加以下配置：**
   ```ini
   [server]
   domain = <grafana-domain>
   root_url = %(protocol)s://%(domain)s:%(http_port)s/
   serve_from_sub_path = true

   [auth.generic_oauth]
   enabled = true
   name = oidc-sso
   allow_sign_up = true
   auto_login = false
   client_id = grafana-oidc
   client_secret = <grafana-oidc-token>
   scopes = openid email profile roles
   email_attribute_path = email
   login_attribute_path = username
   name_attribute_path = full_name
   auth_url = https://<keycloak-domain>/realms/cloud-sso/protocol/openid-connect/auth
   token_url = https://<keycloak-domain>/realms/cloud-sso/protocol/openid-connect/token
   api_url = https:/<keycloak-domain>/realms/cloud-sso/protocol/openid-connect/userinfo
   role_attribute_path = contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'
更新 ConfigMap 后，重启 Grafana Pod：

重启 Grafana 服务以使配置生效。
bash
复制代码
kubectl rollout restart deployment grafana -n monitoring
重新打开 Grafana 登录页面：

登录页面将会新增 Sign in with oidc-sso 选项。
这样，你就成功为 Grafana 配置了基于 Keycloak 的 OIDC SSO 登录。


这段内容已整理为 `5.9 Grafana OIDC SSO 配置`，包括了在 Keycloak 和 Grafana 侧进行的所有配置
