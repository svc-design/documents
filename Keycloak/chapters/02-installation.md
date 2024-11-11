# 2. 安装与部署

## 准备工作

在开始部署 Keycloak 之前，请确保已完成以下准备工作：

1. 拥有一个已经备案的域名。
2. 获得对应域名的服务器管理权限，能够更新 DNS 解析记录。
3. 在 AWS 控制台申请一台 t3a.medium 类型的 云主机（Linux 系统）。
4. 申请并配置对应域名的 SSL 证书，并将证书放置在 EC2 主机的 `/etc/ssl/` 目录下。

## 部署步骤

以 POC 环境为例，下面的步骤将指导您如何使用 EC2 初始化 K3S 集群，并在 K3S 集群中部署 Keycloak。

### 1. 初始化 K3S 集群

登录到 EC2 主机并下载以下部署脚本：

```bash
wget https://github.com/svc-design/Modern-Container-Application-Reference-Architecture/blob/main/playbook/roles/k3s/files/setup-k3s-with-hostpath-sc.sh
wget https://github.com/svc-design/Modern-Container-Application-Reference-Architecture/blob/main/playbook/roles/k3s/files/setup-ingress.sh
wget https://github.com/svc-design/Modern-Container-Application-Reference-Architecture/blob/main/playbook/roles/keycloak/files/setup-keycloak.sh
按照以下顺序执行脚本：

bash
复制代码
bash setup-k3s-with-hostpath-sc.sh      # 初始化 K3S 集群
bash setup-ingress.sh <ec2_public_ip>   # 配置 K3S ingress
2. 创建 Keycloak Namespace 和 Secret
在 K3S 集群中创建 keycloak 命名空间，并生成 Secret：

bash
复制代码
kubectl create namespace keycloak      # 创建 namespace
kubectl create secret tls keycloak-tls --key=/etc/ssl/domain.key --cert=/etc/ssl/domain.cert -n keycloak  # 创建 secret
3. 部署 Keycloak
执行以下命令来部署 Keycloak：

bash
复制代码
bash setup-keycloak.sh <domain> <secret_name> <namespace> <keycloak_ui_password> <keycloak_db_password> # 部署 Keycloak

其中，

- <domain> 是您的域名
- <secret_name> 是创建的 TLS Secret 名称
- <namespace> 是 K8S 命名空间
- <keycloak_ui_password> 是 Keycloak 管理员控制台的密码
- <keycloak_db_password> 是 Keycloak 数据库的密码。

4. 配置 DNS 解析
部署完成后，获取域名和 IP 地址，并在 DNS 服务中添加解析记录。使用以下命令查看 Keycloak 的 ingress 记录：

bash
复制代码
kubectl get ingress -A | grep keycloak | awk '{print $4 "\t" $5}'
这将返回类似以下格式的结果：

复制代码
keycloak.onwalk.net    x.x.x.x
将上述域名和 IP 地址添加到您的 DNS 解析记录中，等待 DNS 解析生效。

5. 访问 Keycloak 管理控制台
DNS 解析生效后，您可以在浏览器中访问 Keycloak 管理控制台，URL 示例：
https://keycloak.onwalk.net
使用管理员用户名 user 和之前设置的 <keycloak_ui_password> 密码登录，将会看到 Keycloak 管理控制台的页面。
