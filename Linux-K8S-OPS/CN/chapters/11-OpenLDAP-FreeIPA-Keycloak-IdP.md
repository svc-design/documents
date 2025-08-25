# OpenLDAP / FreeIPA / Keycloak 身份提供者 (IdP)

## 背景
身份提供者（Identity Provider, IdP）是集中管理认证信息的组件，用于为集群和应用提供统一的用户登录入口。

## OpenLDAP
- 开源的 LDAP 目录服务实现
- 适合作为轻量级用户目录，提供 `slapd` 服务
- 通过 `ldapadd`, `ldapsearch` 等工具维护条目

## FreeIPA
- 基于 LDAP、Kerberos 与 Dogtag 的综合身份管理方案
- 提供集中认证、授权和证书管理
- `ipa-server-install` 可快速部署服务器并创建初始域

## Keycloak
- Red Hat 开源的单点登录与访问管理平台
- 支持 OAuth2、OpenID Connect、SAML 等协议
- 可与 OpenLDAP 或 FreeIPA 集成，实现统一身份与权限控制

## 常见部署架构
1. 使用 OpenLDAP 或 FreeIPA 作为底层用户目录
2. Keycloak 连接到 LDAP/FreeIPA，同步用户信息
3. 各业务应用通过 OIDC/SAML 与 Keycloak 集成，实现单点登录

## 参考链接
- [OpenLDAP 官方网站](https://www.openldap.org/)
- [FreeIPA 项目主页](https://www.freeipa.org/)
- [Keycloak 项目主页](https://www.keycloak.org/)
