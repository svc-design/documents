# 新 K3s 并注册到 ArgoCD 的操作流程文档


## ✅ 1. 下载 ArgoCD CLI 工具

在操作机器上安装 argocd CLI：

- macOS: brew install argocd
- Linux (x86_64) 执行命令: curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

## ✅ 2. 登录 ArgoCD Server

argocd login argocd.onwalk.net

若启用 HTTPS 自签名证书，可加 --insecure：

argocd login argocd.onwalk.net --insecure

提示输入用户名密码（默认通常是 admin / <初始密码>）

## ✅ 3. 在 K3s 集群创建 ArgoCD 授权账户

在 K3s 集群中运行以下内容创建服务账号和角色绑定：

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-manager
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-manager-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: argocd-manager
  namespace: kube-system
EOF
```

✅ 4. 自动生成 kubeconfig 文件供 ArgoCD 注册使用
以下命令需在 K3s 节点上创建脚本generate-argocd-kubeconfig.sh 并执行

```
#!/bin/bash

# 参数校验
if [ $# -ne 4 ]; then
  echo "用法: $0 <cluster-name> <api-server-url> <server-ca-path> <output-kubeconfig-path>"
  echo "示例: $0 my-k3s https://10.253.254.1:6443 /var/lib/rancher/k3s/server/tls/server-ca.crt ./my-k3s-kubeconfig.yaml"
  exit 1
fi

CLUSTER_NAME="$1"
K3S_API_SERVER="$2"
CA_PATH="$3"
OUTPUT_FILE="$4"

# 检查 CA 文件存在
if [ ! -f "$CA_PATH" ]; then
  echo "❌ 错误: 找不到 CA 文件: $CA_PATH"
  exit 1
fi

# 获取 token
TOKEN=$(kubectl -n kube-system get secret \
  $(kubectl -n kube-system get sa argocd-manager -o jsonpath="{.secrets[0].name}") \
  -o jsonpath="{.data.token}" | base64 -d)

# 获取 CA 并 base64 编码（兼容 Linux 和 macOS）
if base64 --help 2>&1 | grep -q 'GNU'; then
  CA_BASE64=$(base64 -w 0 "$CA_PATH")
else
  CA_BASE64=$(base64 "$CA_PATH" | tr -d '\n')
fi

# 生成 kubeconfig 文件
cat <<EOF > "${OUTPUT_FILE}"
apiVersion: v1
kind: Config
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    server: ${K3S_API_SERVER}
    certificate-authority-data: ${CA_BASE64}
users:
- name: argocd-manager
  user:
    token: ${TOKEN}
contexts:
- name: ${CLUSTER_NAME}-context
  context:
    cluster: ${CLUSTER_NAME}
    user: argocd-manager
current-context: ${CLUSTER_NAME}-context
EOF

echo "✅ 生成完成: ${OUTPUT_FILE}"

```

📁 你也可以将该文件复制到 ArgoCD Server 所在机器上。

✅ 5. 在 ArgoCD Server 注册该集群
在 ArgoCD 所在的机器上执行：

bash
复制
编辑
argocd cluster add --kubeconfig ./k3s-argocd-kubeconfig.yaml global-hub-k3s-context
你应看到：

rust
复制
编辑
Cluster 'https://10.253.254.1:6443' added
✅ 6. 验证集群注册情况
bash
复制
编辑
argocd cluster list
输出应包含：

pgsql
复制
编辑
SERVER                        NAME                    VERSION   STATUS      MESSAGE
https://10.253.254.1:6443     global-hub-k3s-context  v1.28.x   Successful


以下是一个 可在新部署的 K3s 节点执行的一键 all-in-one 脚本，用于：

创建 argocd-manager 账户

生成带 Token 和 CA 的 kubeconfig 文件

将该 K3s 集群注册到远程 ArgoCD Server

✅ register-k3s-to-argocd.sh

```bash
#!/bin/bash

# === 参数设置 ===
CLUSTER_NAME="global-hub-k3s"
API_SERVER="https://10.253.254.1:6443"  # 替换为你的实际 K3s API 地址
ARGOCD_SERVER="argocd.onwalk.net"       # 替换为你的 ArgoCD 域名
KUBECONFIG_OUTPUT="./k3s-argocd-kubeconfig.yaml"

# === 创建 ServiceAccount 和权限 ===
echo "🔧 创建 ServiceAccount 和权限..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: argocd-manager
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-manager-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: argocd-manager
  namespace: kube-system
EOF

# === 获取 token ===
echo "🔑 获取 ServiceAccount token..."
SECRET_NAME=$(kubectl -n kube-system get sa argocd-manager -o jsonpath="{.secrets[0].name}")
TOKEN=$(kubectl -n kube-system get secret "$SECRET_NAME" -o jsonpath="{.data.token}" | base64 -d)

# === 获取 CA 并 base64 编码（兼容 macOS/Linux）===
echo "📜 编码 CA 证书..."
if base64 --help 2>&1 | grep -q 'GNU'; then
  CA_BASE64=$(base64 -w 0 /var/lib/rancher/k3s/server/tls/server-ca.crt)
else
  CA_BASE64=$(base64 /var/lib/rancher/k3s/server/tls/server-ca.crt | tr -d '\n')
fi

# === 生成 kubeconfig ===
echo "📁 生成 kubeconfig 文件: $KUBECONFIG_OUTPUT"
cat <<EOF > "${KUBECONFIG_OUTPUT}"
apiVersion: v1
kind: Config
clusters:
- name: ${CLUSTER_NAME}
  cluster:
    server: ${API_SERVER}
    certificate-authority-data: ${CA_BASE64}
users:
- name: argocd-manager
  user:
    token: ${TOKEN}
contexts:
- name: ${CLUSTER_NAME}-context
  context:
    cluster: ${CLUSTER_NAME}
    user: argocd-manager
current-context: ${CLUSTER_NAME}-context
EOF

# === 登录 ArgoCD Server ===
echo "🔐 登录 ArgoCD: $ARGOCD_SERVER"
argocd login "$ARGOCD_SERVER" --insecure || {
  echo "❌ 登录失败，请确认 ArgoCD 地址和账号密码"
  exit 1
}

# === 注册集群到 ArgoCD ===
echo "🚀 注册集群到 ArgoCD..."
argocd cluster add --kubeconfig "${KUBECONFIG_OUTPUT}" "${CLUSTER_NAME}-context"

# === 结束 ===
echo "✅ 集群 $CLUSTER_NAME 已成功注册到 ArgoCD ($ARGOCD_SERVER)"
```

📦 用法
将脚本保存为 register-k3s-to-argocd.sh，赋予可执行权限并运行：

```bash
chmod +x register-k3s-to-argocd.sh
./register-k3s-to-argocd.sh
```
如果你在多个集群执行此脚本，只需调整 CLUSTER_NAME 和 API_SERVER 即可。
