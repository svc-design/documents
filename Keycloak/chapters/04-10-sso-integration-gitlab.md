# 5.7 Gitlab OIDC SSO 配置

## 5.7.1 Keycloak控制台操作：新建Gitlab OIDC客户端

1. **Keycloak侧配置：**
   - 选择一个 Realm，左侧侧边栏点击 **客户端**，右侧选择 **创建客户端**。
   - **客户端类型**: 选择 **OpenID connect** （关键配置项）。
   - **客户端ID**: 输入 `gitlab-oidc` （关键配置项）。
   - **客户端名称**: 输入 `gitlab-oidc`。

2. **选择下一步：**
   - **客户端验证**: 开启（关键配置项）。

3. **选择下一步：**
   - **Home URL**: 输入 `https://<gitlab-domain>`（关键配置项）。
   - **有效的重定向URI**: 输入 `https://<gitlab-domain>/users/auth/openid_connect/callback`（关键配置项）。

4. **保存**，并记录生成的 `gitlab-oidc` 客户端密钥。

## 5.7.2 Gitlab侧配置：开启OIDC登录选项

以 **Helm 部署 Gitlab** 为例，进行如下配置：

1. **创建存储OIDC认证信息的 Secret：**
   ```bash
   cat > provider.yaml << EOF
   name: 'openid_connect'
   label: 'keycloak-sso'
   args:
     name: 'openid_connect'
     scope:
       - 'openid'
       - 'profile'
       - 'email'
     pkce: true
     discovery: true
     response_type: 'code'
     client_auth_method: 'query'
     send_scope_to_token_endpoint: true
     issuer: 'https://keycloak.apollo-ev.com/realms/cloud-sso'
     client_options:
       identifier: 'gitlab-oidc'
       secret: 'gitlab-oidc-token'
       redirect_uri: 'https://gitlab.apollo-ev.com/users/auth/openid_connect/callback'
   EOF

   export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
   kubectl delete secret gitlab-sso-secret -n gitlab || echo true
   kubectl create secret generic gitlab-sso-secret --from-file="provider=provider.yaml" -n gitlab

更新 Gitlab 部署配置： 修改 gitlab-values.yaml，添加以下配置：

yaml
复制代码
global:
  appConfig:
    omniauth:
      enabled: true
      autoLinkLdapUser: false
      autoLinkSamlUser: false
      blockAutoCreatedUsers: false
      autoSignInWithProvider: null
      autoLinkUser:
        - 'openid_connect'
      allowSingleSignOn:
        - 'openid_connect'
      providers:
        - secret: gitlab-sso-secret
          key: provider
更新 Gitlab 部署：

bash
复制代码
helm repo add gitlab https://charts.gitlab.io/
helm repo up
helm upgrade --install gitlab gitlab/gitlab --namespace gitlab -f gitlab-values.yaml

Gitlab 更新后，重新打开 Gitlab 登录页面，您将看到新的 sign in with keycloak-sso 选项。
