# 1. 介绍

## 概述

Keycloak 是一种用于现代应用程序和服务的开源身份和访问管理解决方案。开发人员通常要求编写的安全功能是开箱即用的，并且可以轻松根据组织的需求进行定制。Keycloak 提供了可定制的用户界面，用于登录、注册、帐户管理，支持单点登录（SSO）、用户注册和身份联合等用例。

Keycloak 还可以作为一个集成平台，将其连接到现有的 LDAP 和 Active Directory 服务器，并且可以将身份验证委托给第三方身份提供商，如 GitHub 和 Google。

Keycloak 的主要特点包括：

1. **单点登录**：支持 OpenID Connect、OAuth 2.0 和 SAML 2.0 等标准协议。
2. **身份和访问管理**：提供用户联合、强认证、用户管理和细粒度授权。可以将身份验证集成到应用程序和服务中，而无需处理用户存储或验证。

## 术语

下表列出了与此解决方案相关的关键术语：

| 术语   | 全名                                    | 说明                                                                                          |
|--------|------------------------------------------|------------------------------------------------------------------------------------------------|
| **SSO** | 单点登录（Single-Sign On）              | 单点登录（SSO）是一种身份验证方案，允许用户使用单一的凭证登录多个相关但独立的软件系统。                             |
| **SAML** | 安全断言标记语言（Security Assertion Markup Language） | SAML 是一种开放标准，用于在各方之间交换身份验证和授权数据，特别是在身份提供者和服务提供者之间。它是一种基于 XML 的语言，用于进行安全断言。 |
| **OpenID** | OpenID                                 | OpenID 是由 OpenID 基金会推动的开放标准和去中心化的身份验证协议。有关详细信息，请参见 OpenID Connect。                      |

在使用 Keycloak 来保护 Web 应用程序和 服务之前，了解以下核心概念和术语非常重要：

| 术语   | 说明                                                                                          |
|--------|------------------------------------------------------------------------------------------------|
| **Realms** | Realms 是身份验证和授权的子域，用于管理和验证用户身份。每个 realm 都有自己的身份验证和授权配置。 |
| **Clients** | Clients 是使用 Keycloak 作为 API 客户端的程序或服务。Keycloak 提供了多个 API（例如 HTTP API、JSON API 和 WebSocket API）供客户端使用，客户端可以通过这些 API 访问 Keycloak 后端服务，获取访问令牌或其他授权资源。 |
| **Groups** | Groups 是一组具有相同权限的用户或客户端。用户可以加入多个 group，每个 group 都具有特定的权限范围。group 可以是基于用户的，也可以是基于客户端的。例如，可以创建一个名为“admin”的 group，将所有管理员添加到该 group 中，以便他们可以访问系统中的所有权限。 |
| **Users** | Users 是使用 Keycloak 的用户。Keycloak 提供多种验证用户身份的方式，例如密码、社会安全号码、护照等。用户可以在 Keycloak 中创建、修改或删除，并且可以通过 API 进行身份验证和授权。 |
| **Client Scopes** | Client Scopes 是授予客户端访问 Keycloak 后端服务的权限。Client scope 定义了一组权限，可以授予客户端，使其可以访问 Keycloak 后端服务。例如，可以创建一个名为“read”的 client scope，并将其授予可以读取特定资源的客户端。这样可以确保只有具有足够权限的客户端可以访问系统中的资源。 |
