# 使用 Nginx 和对象存储构建私有 YUM 仓库

本文档整合了使用 nginx 及对象存储搭建自建 YUM 仓库的步骤，并给出了 Dockerfile、Ansible 剧本和 GitHub Actions 自动化示例。

## 1. 基础环境
1. **安装依赖**：在 CentOS/RHEL/Rocky Linux 上安装 `nginx` 与 `createrepo`。
   ```bash
   sudo dnf install -y nginx createrepo
   ```
2. **准备仓库目录**：创建仓库结构并生成元数据。
   ```bash
   sudo mkdir -p /srv/repos/myrepo/{x86_64,src}
   sudo createrepo /srv/repos/myrepo/x86_64
   ```

## 2. Nginx 发布配置
在 `/etc/nginx/conf.d/yumrepo.conf` 中加入：
```nginx
server {
    listen 80;
    server_name your.repo.domain;

    location /myrepo/ {
        autoindex on;
        root /srv/repos/;
    }
}
```
重载服务：
```bash
sudo nginx -s reload
```

## 3. 导入 RPM 包
1. 拷贝新包到仓库目录：`cp myapp.rpm /srv/repos/myrepo/x86_64/`
2. 更新元数据：`createrepo --update /srv/repos/myrepo/x86_64`
可以封装脚本自动处理。

## 4. 结合对象存储
将 `/srv/repos/myrepo/` 同步到对象存储（S3、OSS 等）。常用工具如 `awscli`、`ossutil` 或 `rclone`。
示例：
```bash
aws s3 sync /srv/repos/myrepo s3://your-bucket/yum/
```
对象存储可再通过 CDN 暴露，或直接由 nginx 挂载（例如通过 rclone mount）。

## 5. Dockerfile 示例
```Dockerfile
FROM centos:8
RUN dnf install -y nginx createrepo rsync && \
    mkdir -p /repo/x86_64 && \
    createrepo /repo/x86_64
COPY ./rpms/*.rpm /repo/x86_64/
RUN createrepo --update /repo/x86_64
COPY nginx.repo.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
```
构建镜像后，可运行容器并将内容同步到对象存储。

## 6. Ansible 剧本片段
项目结构：
```
ansible/
├── inventory.ini
├── playbook.yml
└── roles/
    └── yum_repo/
        ├── tasks/main.yml
        └── templates/nginx.repo.conf.j2
```
`tasks/main.yml` 核心步骤：
```yaml
- name: Install packages
  dnf:
    name:
      - nginx
      - createrepo
    state: present

- name: Create repo directory
  file:
    path: /srv/repos/myrepo/x86_64
    state: directory
    recurse: yes

- name: Copy RPM packages
  copy:
    src: files/
    dest: /srv/repos/myrepo/x86_64/

- name: Create or update repo metadata
  command: createrepo --update /srv/repos/myrepo/x86_64

- name: Configure nginx
  template:
    src: nginx.repo.conf.j2
    dest: /etc/nginx/conf.d/yumrepo.conf

- name: Start nginx
  service:
    name: nginx
    state: restarted
    enabled: true
```

## 7. GitHub Actions 工作流程
`.github/workflows/publish.yml` 示例：
```yaml
name: Build & Publish RPM
on:
  push:
    paths:
      - "rpms/**.rpm"

jobs:
  upload-rpm:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install s3cmd
        run: sudo apt-get install -y s3cmd
      - name: Upload RPM
        run: s3cmd put rpms/*.rpm s3://your-bucket/yum/x86_64/ --acl-public
      - name: Update repo metadata
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.REPO_HOST }}
          username: ${{ secrets.REPO_USER }}
          key: ${{ secrets.REPO_SSH_KEY }}
          script: sudo createrepo --update /srv/repos/myrepo/x86_64
```
该流程在推送 RPM 后自动上传到对象存储并远程更新元数据。

---
以上即为基于 nginx 和对象存储的自建 YUM 仓库的整体方案，既能快速部署，也方便在 CI/CD 流程中自动发布。
