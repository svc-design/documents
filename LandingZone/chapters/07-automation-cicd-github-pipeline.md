模块复用（版本可控）

在业务栈里引用模块时，固定 tag/commit，避免漂移：

module "vpc" {
  source = "git::ssh://git@github.com/your-org/iac-modules.git//vpc?ref=v0.3.2"
  name   = var.name
  cidr   = var.vpc_cidr
}


若模块单仓库：用 Release Tag 管控版本，流水线里允许通过输入 MODULES_REF 覆盖。

3) 环境变量与后端（Backend）处理

backend.hcl 只写非机密后端信息：

AWS：bucket, key, region, dynamodb_table

阿里云：bucket, prefix, region（Terraform OSS 后端）

机密（如凭证）不放 backend.hcl，用 OIDC/临时凭证 或 CI Secret 注入。

通过 TF CLI Config 文件（~/.terraformrc）或 TF_REGISTRY_CLIENT_... 处理私有模块/私有 registry 的 token（由 CI Secret 注入）。

4) 敏感信息管理（推荐优先级）

OIDC + 云端角色扮演（AssumeRole）：CI 不存长期密钥（最佳实践）。

Vault/SOPS：把 *.tfvars.enc 解密为临时文件（作业结束清理）。

CI Secret/Protected Variables：以 TF_VAR_xxx 注入（变量名即 Terraform 变量）。

规则：

不提交任何明文密钥到仓库。

terraform.tfvars 只放非敏感参数；敏感项走 TF_VAR_* 注入或解密出来的临时 secret.auto.tfvars。

prod 的变量/凭证用 Protected / 环境级别 Secret，且需要审批。

5) GitHub Actions（复用工作流 + 环境/分支映射）
5.1 可复用工作流 .github/workflows/tf-reusable.yml
name: tf-reusable
on:
  workflow_call:
    inputs:
      env:
        required: true
        type: string   # dit | uat | prod
      stack:
        required: true
        type: string   # network | app
      modules_ref:
        required: false
        type: string
    secrets:
      CLOUD_ROLE_ARN:
        required: false
      VAULT_TOKEN:
        required: false
      SOPS_AGE_KEY:
        required: false

jobs:
  tf:
    runs-on: ubuntu-latest
    environment: ${{ inputs.env }}         # 绑定环境(用于审批/保护)
    permissions:
      id-token: write                      # OIDC
      contents: read
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      # 可选：拉取集中配置仓库（git-config-repo）
      - name: Checkout config repo
        uses: actions/checkout@v4
        with:
          repository: your-org/env-config
          path: .config
          ref: main

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Render backend & env
        run: |
          python3 pipeline/render_backend.py \
            --env ${{ inputs.env }} \
            --stack ${{ inputs.stack }} \
            --config ./.config

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      # OIDC Assume Role（以 AWS 为例；阿里云可用STS/OIDC网关）
      - name: Configure cloud credentials (OIDC)
        if: secrets.CLOUD_ROLE_ARN != ''
        run: |
          # 这里根据云厂商写 assume-role 脚本，导出临时环境变量
          ./pipeline/assume_role.sh "${{ secrets.CLOUD_ROLE_ARN }}"

      # 可选：用 SOPS/Vault 解密敏感 tfvars -> secret.auto.tfvars
      - name: Decrypt secrets
        if: secrets.SOPS_AGE_KEY != '' || secrets.VAULT_TOKEN != ''
        run: |
          ./pipeline/decrypt.sh ${{ inputs.env }} ${{ inputs.stack }}

      - name: Terraform Init
        working-directory: stacks/${{ inputs.stack }}
        run: |
          terraform init -backend-config=../../envs/${{ inputs.env }}/backend.hcl

      - name: Terraform Plan
        working-directory: stacks/${{ inputs.stack }}
        run: |
          terraform plan -var-file=../../envs/${{ inputs.env }}/terraform.tfvars \
                         -out=tfplan

      - name: Upload Plan
        uses: actions/upload-artifact@v4
        with:
          name: tfplan-${{ inputs.env }}-${{ inputs.stack }}
          path: stacks/${{ inputs.stack }}/tfplan

      - name: Terraform Apply (manual for prod)
        if: ${{ inputs.env != 'prod' || github.event_name == 'workflow_dispatch' }}
        working-directory: stacks/${{ inputs.stack }}
        run: |
          terraform apply -auto-approve tfplan

5.2 调用工作流（环境/分支规则）.github/workflows/tf-entry.yml
name: tf-entry
on:
  push:
    branches: [ "dev", "main" ]
    paths: [ "stacks/**", "modules/**", "envs/**", "pipeline/**" ]
  workflow_dispatch:
    inputs:
      env:
        description: "dit/uat/prod"
        required: true
        default: "dit"
      stack:
        description: "network/app"
        required: true
        default: "network"
      modules_ref:
        description: "override modules ref"
        required: false

jobs:
  map-env:
    runs-on: ubuntu-latest
    outputs:
      env: ${{ steps.map.outputs.env }}
      stack: app
    steps:
      - id: map
        run: |
          if [[ "${GITHUB_REF_NAME}" == "dev" ]]; then echo "env=dit" >> $GITHUB_OUTPUT; fi
          if [[ "${GITHUB_REF_NAME}" == "main" ]]; then echo "env=uat" >> $GITHUB_OUTPUT; fi

  run-tf:
    uses: ./.github/workflows/tf-reusable.yml
    with:
      env:  ${{ github.event_name == 'workflow_dispatch' && inputs.env  || needs.map-env.outputs.env }}
      stack: ${{ github.event_name == 'workflow_dispatch' && inputs.stack || 'network' }}
      modules_ref: ${{ inputs.modules_ref }}
    secrets:
      CLOUD_ROLE_ARN: ${{ secrets.CLOUD_ROLE_ARN }}
      VAULT_TOKEN:    ${{ secrets.VAULT_TOKEN }}
      SOPS_AGE_KEY:   ${{ secrets.SOPS_AGE_KEY }}


产线建议：在 GitHub “Environments” 中对 prod 开启 Required reviewers 审批；prod 仅允许 tag/release 触发。


