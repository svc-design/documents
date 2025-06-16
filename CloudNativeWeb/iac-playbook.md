# IAC 与 Ansible Playbook 设计

本节介绍使用 IAC 与 Ansible Playbook 自动部署和配置 CloudNative Web v1.0 的示例思路。

## 目录结构示例

```
playbook/
  roles/
    common/
      tasks/
        main.yml
    web/
      tasks/
        main.yml
  site.yml
terraform/
  main.tf
  variables.tf
```

- `playbook/` 下存放 Ansible 角色和入口 Playbook。
- `terraform/` 用于定义云资源，例如阿里云 OSS、CDN 等。

## Terraform 模块示例

```hcl
resource "alicloud_oss_bucket" "static_site" {
  bucket = var.bucket_name
  acl    = "public-read"
  region = var.region
}
```

以上示例展示了在指定区域创建 OSS Bucket 的基本模板。实际使用时可以根据需要扩展网络、CDN 域名等资源。

## Ansible Playbook 示例

```yaml
---
- hosts: web
  roles:
    - common
    - web
```

`roles/common/tasks/main.yml` 可以配置基础环境，如安装 Nginx、设置防火墙。
`roles/web/tasks/main.yml` 负责同步站点文件到 OSS 或轻量服务器，并重启服务。

在 CI/CD 流程中，可先运行 Terraform 部署基础设施，再通过 Ansible 完成应用层配置。

