# chutes-miner 部署指南

本文档整理了在 Kubernetes 集群上部署 chutes-miner 的步骤，包括集群初始化、钱包准备以及节点管理等操作。

## 1. 初始化 Kubernetes 集群

1. 使用 [sealos](https://github.com/labring/sealos) 安装 Kubernetes、Cilium 与 Helm：

```bash
sealos run labring/kubernetes:v1.29.9 labring/cilium:v1.13.4 labring/helm:v3.9.4 \
  --masters 172.29.133.135 --user root --pk /root/.ssh/id_rsa \
  --env '{}' --cmd 'kubeadm init --skip-phases=addon/kube-proxy'
```

2. 添加工作节点：

```bash
sealos add --nodes 172.29.133.134
```

## 2. 安装并配置 Cilium

1. 添加 Cilium Helm 仓库并更新：

```bash
helm repo add cilium https://helm.cilium.io
helm repo update
```

2. 启用 Egress Gateway 功能：

```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set egressGateway.enabled=true
```

3. 若需自定义参数，可导出配置后再次升级：

```bash
# helm get values cilium -n kube-system -o yaml > cilium-values.yaml
helm upgrade cilium cilium/cilium -n kube-system -f cilium-values.yaml
```

## 3. 准备 Bittensor 环境与钱包

1. 安装 Python 虚拟环境并准备依赖：

```bash
apt install -y python3.10-venv
python3 -m venv ~/btcli-env
source ~/btcli-env/bin/activate
pip install bittensor
pip install -U bittensor-cli
pip install chutes-miner-cli
```

2. 创建冷钱包和热钱包：

```bash
btcli wallet new_coldkey --wallet.name shenlan --wallet.path ~/.bittensor/wallets

btcli wallet new_hotkey \
  --wallet.name shenlan \
  --wallet.hotkey jkt-chutes-miner-gpu-0 \
  --wallet.path ~/.bittensor/wallets
```

3. 注册热钱包并质押：

```bash
btcli subnet register \
  --netuid 64 \
  --wallet.name shenlan \
  --wallet.hotkey jkt-chutes-miner-gpu-0 \
  --wallet.path ~/.bittensor/wallets

# 转入少量 TAO 并质押
btcli stake transfer \
  --wallet.name shenlan \
  --wallet.hotkey jkt-chutes-miner-gpu-0 \
  --amount 0.001 \
  --netuid 64 \
  --wallet.path ~/.bittensor/wallets

btcli stake add \
  --wallet.name shenlan \
  --wallet.hotkey jkt-chutes-miner-gpu-0 \
  --amount 0.001 \
  --netuid 64
```

## 4. 部署 chutes-miner

1. 创建命名空间和镜像拉取凭据：

```bash
kubectl create ns chutes || true
kubectl create secret docker-registry regcred \
  --docker-server=docker.io \
  --docker-username=manbuzhe2003 \
  --docker-password='L@xiaomin1250' \
  --docker-email=manbuzhe2008@gmail.com -n chutes
```

2. 创建矿机密钥：

```bash
kubectl delete secret miner-credentials -n chutes
kubectl create secret generic miner-credentials \
  --from-literal=ss58=5GYgtw3J9aXaymosqYCcxX2EpgnRHHJUszbd1zSN9dEwVSEh \
  --from-literal=seed=ebed0ea8bf19c2ef9286f3289dee6516e7a793140df2a2ac3fc6d0462c69aa02 \
  -n chutes
```

3. 部署 Helm chart：

```bash
cd /data/deploy/chutes-miner/

kubectl delete configmap gepetto-code -n chutes
kubectl create configmap gepetto-code --from-file=gepetto.py -n chutes

cd /data/deploy/chutes-miner/charts
helm template . --set createPasswords=true -s templates/one-time-passwords.yaml | kubectl apply -n chutes -f -
helm template . -f values.yaml > miner-charts.yaml
kubectl apply -f miner-charts.yaml -n chutes
```

4. 如有需要，执行权限修复脚本：

```bash
bash /data/deploy/grant-pod-reader.sh
bash /data/deploy/grant-chutes-node-access.sh
bash /data/deploy/fix_gepetto_rbac.sh
bash /data/deploy/fix-chutes-miner-rbac.sh
bash /data/deploy/fix_permissions.sh
bash /data/deploy/fix_chutes_rbac_patch.sh
```

5. 将节点加入矿机清单：

```bash
chutes-miner add-node \
  --name jkt-chutes-miner-gpu-0 \
  --validator 5GYgtw3J9aXaymosqYCcxX2EpgnRHHJUszbd1zSN9dEwVSEh \
  --hourly-cost 0.82 \
  --gpu-short-ref a10 \
  --hotkey ~/.bittensor/wallets/shenlan/hotkeys/shelan \
  --miner-api http://147.139.206.221:32000
```

## 5. 配置 Hugging Face 模型缓存

1. 创建访问令牌并登录：

```bash
kubectl create secret generic hf-auth --from-literal=HF_TOKEN=hf_xxxxxxxxxxx -n chutes
mkdir -p /var/snap/cache
echo "hf_xxxxxxxxxxx" > /var/snap/cache/token
chmod 644 /var/snap/cache/token
export HF_HOME=/var/snap/cache
pip install -U huggingface_hub
huggingface-cli login
```

2. 下载模型并生成缓存：

```bash
huggingface-cli snapshot-download BAAI/bge-large-en-v1.5 --revision refs/pr/5 --local-dir /var/snap/cache/models/BAAI/bge-large-en-v1.5

export HF_HOME=/var/snap/cache
export HUGGING_FACE_HUB_TOKEN=$(cat /var/snap/cache/token)
python3 /var/snap/cache/cache_models.py
```

## 6. 节点标签与注解

```bash
kubectl label node jkt-chutes-miner-gpu-0 nvidia.com/gpu.count=1 --overwrite
kubectl label node jkt-chutes-miner-gpu-0 nvidia.com/gpu.present=true --overwrite
kubectl label node jkt-chutes-miner-gpu-0 nvidia.com/gpu.deploy.operator-validator=true
kubectl label node jkt-chutes-miner-gpu-0 chutes/external-ip=8.215.60.133 --overwrite
kubectl annotate node jkt-chutes-miner-gpu-0 "kubeadm.alpha.kubernetes.io/internal-ip=172.31.23.69" --overwrite
```

## 7. 库存与节点管理

```bash
chutes-miner local-inventory --hotkey ~/.bittensor/wallets/shenlan/hotkeys/jkt-chutes-miner-gpu-0
chutes-miner remote-inventory --hotkey ~/.bittensor/wallets/shenlan/hotkeys/jkt-chutes-miner-gpu-0
```

删除节点示例：

```bash
chutes-miner delete-node \
  --name chutes-miner-sg-node-group-gpu-1 \
  --hotkey ~/.bittensor/wallets/shenlan/hotkeys/sg-node-group \
  --miner-api http://8.219.229.1:32000
kubectl delete svc graval-service-chutes-miner-sg-node-group-gpu-1 -n chutes

chutes-miner delete-node \
  --name chutes-miner-gpu-2 \
  --hotkey ~/.bittensor/wallets/shenlan/hotkeys/sg-node-group \
  --miner-api http://8.219.223.71:32000
kubectl delete svc graval-service-chutes-miner-gpu-2 -n chutes
```

## 8. 推荐支持 GPU 的云主机

| 云厂商 | 推荐实例 | 驱动支持 | 备注 |
|--------|---------|---------|------|
| AWS | g4dn.xlarge 或以上 | ✅ 支持 CUDA 与 NVIDIA Container Toolkit | 推荐使用 Ubuntu 镜像 |
| 阿里云 | ecs.gn5-c8g1.xlarge | ✅ 官方支持 NVIDIA 驱动（部分预装） | 需开放端口安装驱动 |
| GCP | T4、A100 等 GPU 实例 + 自定义镜像 | ✅ 支持 containerd 与 NVIDIA toolkit | - |
| Vast.ai | 任意 T4/A10 实例 + 宿主机 SSH 权限 | - | - |

以上步骤将帮助你在 Kubernetes 集群中快速部署并运行 chutes-miner。
