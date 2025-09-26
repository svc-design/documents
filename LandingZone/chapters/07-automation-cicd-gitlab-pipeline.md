# GitLab CI 的 Terraform Pipeline 模版

GitLab CI（模板 + 环境/分支 + 受保护变量）

.gitlab-ci.yml（顶层）：

```yaml
stages: [validate, plan, apply]

variables:
  TF_IN_AUTOMATION: "true"
  TF_INPUT: "false"

include:
  - local: 'pipeline/template.common.yml'   # 复用命令片段

.default_job:
  image: hashicorp/terraform:1.8
  before_script:
    - apk add --no-cache python3 git bash
    - python3 pipeline/render_backend.py --env "$ENV" --stack "$STACK" --config ".config"
    # OIDC to cloud（GitLab 支持 ID Token，结合云厂商Web身份联合）
    - ./pipeline/assume_role.sh "$CLOUD_ROLE_ARN"
    - ./pipeline/decrypt.sh "$ENV" "$STACK"

validate:
  stage: validate
  extends: .default_job
  script:
    - terraform -chdir=stacks/$STACK init -backend-config=../../envs/$ENV/backend.hcl
    - terraform -chdir=stacks/$STACK validate
  rules:
    - if: '$CI_COMMIT_BRANCH == "dev"'
      variables: { ENV: "dit", STACK: "network" }
    - if: '$CI_COMMIT_BRANCH == "main"'
      variables: { ENV: "uat", STACK: "network" }

plan:
  stage: plan
  extends: .default_job
  script:
    - terraform -chdir=stacks/$STACK plan -var-file=../../envs/$ENV/terraform.tfvars -out=tfplan
  artifacts:
    paths: [ "stacks/$STACK/tfplan" ]
  needs: [validate]
  rules:
    - if: '$CI_COMMIT_BRANCH'
      when: on_success

apply:
  stage: apply
  extends: .default_job
  environment:
    name: $ENV
    url: https://console.example.com/$ENV
    on_stop: stop_$ENV
  script:
    - terraform -chdir=stacks/$STACK apply -auto-approve tfplan
  needs: [plan]
  rules:
    - if: '$CI_COMMIT_BRANCH == "dev"'
      variables: { ENV: "dit", STACK: "network" }
      when: manual   # 可改为自动
    - if: '$CI_COMMIT_BRANCH == "main"'
      variables: { ENV: "uat", STACK: "network" }
      when: manual
    - if: '$CI_COMMIT_TAG'     # 仅 Tag 部署到 prod
      variables: { ENV: "prod", STACK: "network" }
      when: manual
      allow_failure: false
```


GitLab 敏感信息

使用 Settings → CI/CD → Variables 设置 CLOUD_ROLE_ARN / VAULT_TOKEN / SOPS_AGE_KEY，标记 Masked、Protected，并与 Protected Branch/Environment 绑定。

对 prod 环境设置 Approval（需要 Maintainer 点执行）。

7) pipeline-template 与 Python 渲染

pipeline/template.common.yml（供两边 include 或复制）

放通用片段：缓存、lint、生成文档、SOPS/Vault 解密脚本等。

pipeline/render_backend.py（示例核心逻辑）

#!/usr/bin/env python3
import json, os, sys, argparse, pathlib

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--env", required=True)
    ap.add_argument("--stack", required=True)
    ap.add_argument("--config", required=False, default="./.config")
    args = ap.parse_args()

    # 从集中配置仓库读取环境映射（非机密）
    cfg = json.loads(pathlib.Path(args.config, "envs.json").read_text())

    # 生成/覆盖 backend.hcl（仅非敏感项）
    backend = cfg["backends"][args.env]
    backend_hcl = "\n".join([f'{k} = "{v}"' for k, v in backend.items()])
    out = pathlib.Path(f"envs/{args.env}/backend.hcl")
    out.write_text(backend_hcl)
    print(f"[render] wrote {out}")

    # 输出 CI 可用的导出（可写到 $GITHUB_OUTPUT 或 CI变量）
    print(f"TF_VAR_env={args.env}")
    print(f"STACK={args.stack}")

if __name__ == "__main__":
    main()


这个脚本把“环境后端信息”集中在 config 仓库（非机密），流水线时拉取并渲染；机密交给 OIDC/Vault/SOPS/CI-Secret 注入。

8) 如何在流水线里引用 env（含 secrets）

非敏感 env：由 render_backend.py 或配置仓库注入普通变量/文件。

敏感 env：以 TF_VAR_password 形式注入（GitHub Actions/GitLab CI Secret），在 Terraform 中直接 var.password 使用。

SOPS/Vault：解密到 stacks/<stack>/secret.auto.tfvars，执行后删除。

云凭证：优先使用 OIDC 申请临时凭证（AWS STS / 阿里云 STS / GCP Workload Identity）。

9) 关键策略（简明）

分支到环境：dev → dit 自动；main → uat 审批；tag → prod 审批。

模块复用：固定 ?ref=tag，在 CI 提供 modules_ref 覆盖。

幂等保证：统一 backend 与 lock；Plan 产物作为 Apply 输入。

权限最小化：环境级 Role，流水线仅拿到临时凭证。

可审计：保存 Plan/State 变更摘要到制品或 PR 注释。

覆盖：可复用模板、环境映射（dev→dit / main→uat / tag→prod）、受保护变量、Plan/Apply 分离、SOPS/Vault 解密、OIDC 临时凭证、并行多 Stack、子流水线等。

目录建议

```text
pipeline/gitlab/
├─ _tf_base.yml                # 基础锚点/通用 job 片段（被其它模板 extends）
├─ tf_stack.yml                # 单 Stack 的可复用模板（plan/apply 两阶段）
├─ tf_mr_plan.yml              # 专供 Merge Request 的只 plan 模板
├─ tf_parent.yml               # 父流水线（触发子流水线/矩阵并行）
├─ fragments/_sops.yml         # SOPS/Vault 解密片段（可选）
├─ fragments/_oidc.yml         # OIDC AssumeRole 片段（可选，AWS/阿里云）
└─ README.md
```


你的业务仓库 .gitlab-ci.yml 只需 include 这些模板，然后用 rules/变量映射环境即可。

1) _tf_base.yml（基础片段与锚点）

```yaml
# pipeline/gitlab/_tf_base.yml
stages: [validate, plan, apply]

.default_vars: &default_vars
  TF_INPUT: "false"
  TF_IN_AUTOMATION: "true"
  TF_CLI_ARGS: "-no-color"
  # 允许栈级别覆盖
  ENV: ""      # dit / uat / prod
  STACK: ""    # network / app / ...

.cache_tf: &cache_tf
  cache:
    key: "$CI_COMMIT_REF_SLUG-terraform"
    paths:
      - .terraform/

.before_essentials: &before_essentials
  before_script:
    - apk add --no-cache bash git curl python3 jq openssl age
    - python3 pipeline/render_backend.py --env "$ENV" --stack "$STACK" --config ".config" || true
    - echo "[info] ENV=$ENV STACK=$STACK"

.image_tf: &image_tf
  image: hashicorp/terraform:1.8

.oidc: &oidc
  # 引用可选的 OIDC 片段（AWS/阿里云任选其一）
  - test -f pipeline/assume_role.sh && bash pipeline/assume_role.sh "$CLOUD_ROLE_ARN" || true

.sops: &sops
  # 可选：解密 tfvars 到 secret.auto.tfvars，任务结束清理
  - test -f pipeline/decrypt.sh && bash pipeline/decrypt.sh "$ENV" "$STACK" || true

.base_job:
  <<: *image_tf
  variables:
    <<: *default_vars
  <<: *cache_tf
  <<: *before_essentials
```

2) fragments/_oidc.yml（可选，示例 AWS）

```yaml
# pipeline/gitlab/fragments/_oidc.yml
# 结合 GitLab 的 OpenID Connect，把ID Token换成云端临时凭证
# 需要在 GitLab 项目：Settings → CI/CD → Token Access 打开 OpenID Connect
.oidc_aws: &oidc_aws
  - |
    if [ -n "$CLOUD_ROLE_ARN" ]; then
      echo "[oidc] assuming role $CLOUD_ROLE_ARN"
      # 示例：使用 awscli v2 也可；此处以 curl + STS 为伪代码，按你现网脚本替换
      export AWS_REGION=${AWS_REGION:-"ap-southeast-1"}
      # 获取 GitLab OIDC token（GitLab 会暴露ID_TOKEN给任务，需在Job中声明 id_tokens）
      # 在 job 下增加：
      # id_tokens:
      #   GITLAB_OIDC:
      #     aud: https://gitlab.com
      # 然后这里使用 $CI_JOB_JWT_V2 或自定义变量名
      # 假设 assume_role.sh 内部已处理上面细节，这里引用你的脚本更稳妥
    fi
```


简化：你也可以直接在 _tf_base.yml 用 ./pipeline/assume_role.sh 解决，保持脚本私有。

3) fragments/_sops.yml（可选：SOPS/Vault 解密）

```yaml
# pipeline/gitlab/fragments/_sops.yml
.sops_fragment: &sops_fragment
  - |
    if [ -n "$SOPS_AGE_KEY" ]; then
      echo "$SOPS_AGE_KEY" > ~/.config/sops/age/keys.txt
      chmod 600 ~/.config/sops/age/keys.txt
    fi
    if [ -f "stacks/$STACK/secret.auto.tfvars.enc" ]; then
      sops -d "stacks/$STACK/secret.auto.tfvars.enc" > "stacks/$STACK/secret.auto.tfvars"
      echo "[sops] decrypted secret.auto.tfvars"
    fi
```

4) tf_stack.yml（单 Stack 可复用模板）

```yaml
# pipeline/gitlab/tf_stack.yml
include:
  - local: 'pipeline/gitlab/_tf_base.yml'
  # - local: 'pipeline/gitlab/fragments/_oidc.yml'   # 如需，取消注释
  # - local: 'pipeline/gitlab/fragments/_sops.yml'   # 如需，取消注释

.validate:
  stage: validate
  extends: .base_job
  id_tokens:                         # 若要用 OIDC，开启ID Token
    GITLAB_OIDC:
      aud: https://gitlab.com
  script:
    - *oidc
    - *sops
    - terraform -chdir=stacks/$STACK init -backend-config=../../envs/$ENV/backend.hcl
    - terraform -chdir=stacks/$STACK validate
  artifacts:
    when: always
    reports:
      dotenv: artifacts/$ENV/$STACK.validate.env
  after_script:
    - mkdir -p artifacts/$ENV && echo "VALIDATED_STACK=$STACK" > artifacts/$ENV/$STACK.validate.env
  rules:
    # 默认规则由上层 .gitlab-ci.yml 决定 ENV/STACK；也可以提供兜底
    - if: '$ENV && $STACK'

.plan:
  stage: plan
  extends: .base_job
  needs: ["validate"]
  script:
    - *oidc
    - *sops
    - terraform -chdir=stacks/$STACK plan \
        -var-file=../../envs/$ENV/terraform.tfvars \
        -out=tfplan
  artifacts:
    paths:
      - stacks/$STACK/tfplan
    expire_in: 3 days
  rules:
    - if: '$ENV && $STACK'

.apply:
  stage: apply
  extends: .base_job
  needs: ["plan"]
  environment:
    name: $ENV
    # 可按需加外链：
    # url: https://console.example.com/$ENV
  resource_group: "$ENV-$STACK"  # 避免同栈并发 apply
  script:
    - *oidc
    - *sops
    - terraform -chdir=stacks/$STACK apply -auto-approve tfplan
  rules:
    # 仅 dev 分支（dit）自动，main（uat）手动，tag（prod）手动且不允许失败
    - if: '$CI_COMMIT_BRANCH == "dev"'
      variables: { ENV: "dit" }
      when: on_success
    - if: '$CI_COMMIT_BRANCH == "main"'
      variables: { ENV: "uat" }
      when: manual
      allow_failure: false
    - if: '$CI_COMMIT_TAG'
      variables: { ENV: "prod" }
      when: manual
      allow_failure: false
```

5) tf_mr_plan.yml（Merge Request 专用：只做 plan 并附工件）

```yaml
# pipeline/gitlab/tf_mr_plan.yml
include:
  - local: 'pipeline/gitlab/_tf_base.yml'

mr_plan:
  stage: plan
  extends: .base_job
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      variables:
        # MR 一般针对 dit 做计划，或根据标签推断
        ENV: "dit"
        STACK: "network"
  script:
    - terraform -chdir=stacks/$STACK init -backend-config=../../envs/$ENV/backend.hcl
    - terraform -chdir=stacks/$STACK plan -var-file=../../envs/$ENV/terraform.tfvars -out=tfplan
    - terraform -chdir=stacks/$STACK show -no-color tfplan > tfplan.txt
  artifacts:
    when: always
    paths:
      - stacks/$STACK/tfplan
      - stacks/$STACK/tfplan.txt
```

6) tf_parent.yml（父流水线：并行矩阵/子流水线）

```yaml
# pipeline/gitlab/tf_parent.yml
stages: [generate, validate, plan, apply]

generate_matrix:
  stage: generate
  image: python:3.12-alpine
  script:
    - pip install pyyaml
    - python3 - <<'PY'
import yaml, os, json
# 读取配置仓库生成矩阵（环境→stack 列表）
matrix = {
  "dit":  ["network","app"],
  "uat":  ["network"],
  "prod": ["network"]
}
print(json.dumps(matrix))
PY
  artifacts:
    reports:
      dotenv: matrix.env
  after_script:
    - echo "MATRIX_JSON=$(cat job.log | tail -1)" >> matrix.env
  rules:
    - if: '$CI_COMMIT_BRANCH'

child_tf:
  stage: plan
  trigger:
    include:
      - local: 'pipeline/gitlab/tf_stack.yml'
    strategy: depend
  parallel:
    matrix:
      - ENV: "dit"
        STACK: "network"
      - ENV: "dit"
        STACK: "app"
  rules:
    - if: '$CI_COMMIT_BRANCH == "dev"'
```


也可以把 parallel.matrix 用 MATRIX_JSON 动态生成（需要用 rules:exists 或 needs:artifacts 拉取 matrix，再用 yaml 模板渲染）。

7) 业务仓库的 .gitlab-ci.yml（消费模板）

```yaml
# .gitlab-ci.yml (在你的业务仓库)
include:
  - local: 'pipeline/gitlab/tf_stack.yml'
  - local: 'pipeline/gitlab/tf_mr_plan.yml'

variables:
  STACK: "network"   # 默认栈，可在 rules 中覆盖

# 校验（validate）和计划/执行（plan/apply）由模板定义
# 这里只做环境映射
.validate_env:
  rules:
    - if: '$CI_COMMIT_BRANCH == "dev"'
      variables: { ENV: "dit" }
    - if: '$CI_COMMIT_BRANCH == "main"'
      variables: { ENV: "uat" }
    - if: '$CI_COMMIT_TAG'
      variables: { ENV: "prod" }

# 使用模板：通过 needs 触发完整链路
validate:
  extends: [".validate", ".validate_env"]

plan:
  extends: [".plan"]
  needs: ["validate"]

apply:
  extends: [".apply"]
  needs: ["plan"]
```

8) 变量与安全（实践要点）

CI/CD → Variables：

CLOUD_ROLE_ARN（Protected + Masked）

VAULT_TOKEN / SOPS_AGE_KEY（Protected + Masked）

依据环境做 Environment-scoped 变量（dit/uat/prod 各不相同）。

Protected Branch & Environments：

只允许 Maintainer/Owner 对 prod 进行手动 apply。

并发保护：

resource_group: "$ENV-$STACK" 防止同栈并发 Apply。

审计：

artifacts 保留 tfplan 和 tfplan.txt，MR 中查看变更。

状态锁：

使用远端后端（S3+Dynamo/OSS+表）保证 Lock。

9) 脚本占位（按需添加到 pipeline/）

pipeline/assume_role.sh：从 $CI_JOB_JWT_V2 或者 GitLab 发行的 ID Token 获取云临时凭证（AWS STS / 阿里云 RAM 角色），导出标准环境变量（如 AWS_ACCESS_KEY_ID、AWS_SECRET_ACCESS_KEY、AWS_SESSION_TOKEN / ALIBABA_CLOUD_ACCESS_KEY_ID 等）。

pipeline/decrypt.sh：基于 $SOPS_AGE_KEY 或 $VAULT_TOKEN 解密 stacks/$STACK/secret.auto.tfvars.enc → secret.auto.tfvars；完成后 shred -u 清理。

pipeline/render_backend.py：从集中配置仓库或 .config/envs.json 渲染 envs/$ENV/backend.hcl（仅非敏感）。

需要的话，我可以把以上模板打包成最小可运行示例仓库结构（含占位脚本），你只需：

在 GitLab 中配置好 Protected Variables；

把 OIDC/STS 角色打通；

新建 dev/main 分支并推送一次，即可跑通 dit/uat。
