# 4.1 AWS SSO 配置

## 配置项目汇总

| 步骤 | 配置项目        | Keycloak 控制台操作                                                                                  | AWS 控制台操作                                                            |
|------|-----------------|------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| 1    | 创建 Realm      | 创建 Realm，命名为 `cloud-sso`。                                                                      |                                                                         |
| 2    | 设置登录名为邮件 | 启用 `Email as username` 设置。                                                                      |                                                                         |
| 3    | 导出 SAML Metadata | 导出 SAML 2.0 的 Metadata 文件（`keycloak-saml-metadata.xml`）。                                        |                                                                         |
| 4    | 添加身份提供商   |                                                                                                      | 在 `IAM` 中添加 SAML 2.0 身份提供商，导入 Keycloak SAML Metadata。       |
| 5    | 创建客户端      | 导入 AWS SAML Metadata，设置 `IDP-Initiated SSO URL name` 和 `Home URL`。                             |                                                                         |
| 6    | 创建 Realm 角色  | 创建 Realm 角色，格式为 `<sso-iam-role-arn>,<identity-providers-arn>`。                                |                                                                         |
| 7    | 更新客户端配置  | 配置 `clientScopes`，设置 `Full scope allowed` 为 `Off`，并添加 `assign role` 操作。                  |                                                                         |
| 8    | 配置 Session Role | 在 `Mappers` 中配置 `Role list` 映射器，设置 `Role attribute name` 为 `https://aws.amazon.com/SAML/Attributes/Role`。 |                                                                         |
| 9    | 配置 Session Name | 在 `Mappers` 中配置 `User Property` 映射器，设置 `Role Attribute Name` 为 `https://aws.amazon.com/SAML/Attributes/RoleSessionName`。 |                                                                         |
| 10   | 创建用户        | 在 Keycloak 中创建新用户，分配角色。                                                                  |                                                                         |
| 11   | 添加角色绑定    |                                                                                                      | 为身份提供商绑定角色并创建 IAM 角色。                                    |
| 12   | 配置角色权限    |                                                                                                      | 为 IAM 角色分配权限策略（如 `AdministratorAccess`）。                    |
| 13   | 记录 ARN        |                                                                                                      | 记录 IAM 角色和身份提供商的 ARN。                                        |
| 14   | 导入 SAML Metadata |                                                                                                      | 下载 AWS SAML Metadata 文件（AWS 中国和国际版）。                         |
| 15   | 配置 Home URL 和 IDP-Initiated URL | 设置 `Home URL` 和 `IDP-Initiated SSO URL`。                                          |                                                                         |
| 16   | 完成角色绑定    |                                                                                                      | 完成角色和权限的绑定，确保角色策略已正确分配给 SSO 用户。               |


## 4.1.1 Keycloak 控制台操作，创建 Realm
1. 登录到 Keycloak 管理控制台，创建一个新的 Realm，命名为 `cloud-sso`。
2. 配置 Realm 域内的用户使用邮件作为默认登录名：
   - 在 `cloud-sso` 的左侧设置栏中，选择 `Login` 选项卡，确保启用以下设置：
     - `Email as username`：开启。

## 4.1.2 Keycloak 控制台操作，导出 Identity Provider Metadata
1. 导出 Keycloak 的 SAML 2.0 Identity Provider Metadata 文件，并保存为 `keycloak-saml-metadata.xml`。

## 4.1.3 AWS 控制台操作，添加身份提供商
1. 登录 AWS 管理控制台，进入 `IAM` -> `Identity Providers`，点击 `添加身份提供商`。
2. 配置身份提供商，选择 SAML 协议：
   - 提供商名称：`keycloak-sso`（自定义名称）。
   - 导入 Keycloak 导出的 `keycloak-saml-metadata.xml` 文件。

## 4.1.4 AWS 控制台操作，为身份提供商绑定 IAM 角色
1. 添加身份提供商后，点击 `下一步` 进入角色分配。
2. 选择 `创建新角色`。
3. 选择受信任实体的类型为：`SAML 2.0 身份联合`。
4. 在 `SAML 提供商` 处选择 `keycloak-sso`。
5. 允许 `编程访问` 和 `亚马逊云科技 管理控制台访问`。
6. 点击 `下一步`，为角色设置权限，附加所需的权限策略（例如，`AdministratorAccess`）。
7. 点击 `下一步` 设置标签，进行角色名称填写后，完成角色创建。示例角色名称为 `sso-saml-admin`。
8. 记录 IAM 角色 ARN 和身份提供商 ARN，这些信息将在后续的 Keycloak 客户端配置中使用。

**注意**：AWS 中国和 AWS 国际的配置略有差异：
- **AWS 中国账号** 格式：
  - IAM角色 ARN：`arn:aws-cn:iam::<aws-account-id>:role/sso-saml-admin`
  - 身份提供商 ARN：`arn:aws-cn:iam::<aws-account-id>:saml-provider/keycloak-sso`
- **AWS 国际账号** 格式：
  - IAM角色 ARN：`arn:aws:iam::<aws-account-id>:role/sso-saml-admin`
  - 身份提供商 ARN：`arn:aws:iam::<aws-account-id>:saml-provider/keycloak-sso`

## 4.1.5 Keycloak 控制台操作，创建客户端
1. 下载 SAML Metadata 文件：
   - **AWS 中国**：下载地址 [SAML Metadata](https://signin.amazonaws.cn/static/saml-metadata.xml)
   - **AWS 国际版**：下载地址 [SAML Metadata](https://signin.aws.amazon.com/static/saml-metadata.xml)
2. 登录到 Keycloak 管理控制台，选择一个 Realm，点击左侧的 `Clients`，然后选择 `导入客户端`。
3. 选择下载的 Metadata 文件进行导入，点击 `Save` 保存配置。
4. 修改以下配置：
   - **IDP-Initiated SSO URL 名称**：`aws-cn-sso`（关键配置项）。
   - **Home URL**：例如，对于 `keycloak.onwalk.net`，对应的内容是 `https://keycloak.onwalk.net/realms/cloud-sso/protocol/saml/clients/aws-cn-sso`。

## 4.1.6 Keycloak 控制台操作，创建 Realm 角色
1. 在 `Realm Roles` 选项卡下，创建新的角色用于授权 Keycloak 用户，格式如下：
   - 角色名：`<sso-iam-role-arn>,<identity-providers-arn>`。

## 4.1.7 Keycloak 控制台操作，更新客户端配置
1. 进入 `Client` -> `urn:amazon:webservices:cn-north-1`，选择 `clientScopes`，点击 `urn:amazon:webservices:cn-north-1`。
2. 在 `scope` 设置中，选择 `Full scope allowed` 为 `Off`。
3. 删除 Role List，执行 `assign role` 操作，将步骤 4.1.6 中创建的 Realm 角色分配给客户端。

## 4.1.8 Keycloak 控制台操作，调整 Session Role 配置
1. 更新客户端配置：进入 `Client` -> `urn:amazon:webservices:cn-north-1`，选择 `clientScopes` -> `urn:amazon:webservices:cn-north-1-dedicated` -> `Mappers`。
2. 删除原有的 Role 配置，重新添加以下配置：
   - 映射器类型：`Role list`
   - Name：`Session Role`
   - Role attribute name：`https://aws.amazon.com/SAML/Attributes/Role`
   - Single Role Attribute：`开启`

## 4.1.9 Keycloak 控制台操作，调整 Session Name 配置
1. 更新客户端配置：进入 `Client` -> `urn:amazon:webservices:cn-north-1`，选择 `clientScopes` -> `urn:amazon:webservices:cn-north-1-dedicated` -> `Mappers`。
2. 删除原有的 Role Session 配置，重新添加以下配置：
   - 映射器类型：`User Property`
   - Name：`Session Name`
   - 属性：`email`
   - Role Attribute Name：`https://aws.amazon.com/SAML/Attributes/RoleSessionName`

## 4.1.10 Keycloak 控制台操作，新增用户
1. 在 Keycloak 控制台中，创建新用户。
2. 清除原有的 role 配置，并执行 `Assign role` 操作，将步骤 4.1.6 中创建的 Realm 角色分配给该用户。

## 4.1.11 Keycloak 控制台操作，验证 SSO 登录
1. 使用浏览器访问 `Home URL`，例如：`https://keycloak.onwalk.net/realms/cloud-sso/protocol/saml/clients/aws-cn-sso`。
