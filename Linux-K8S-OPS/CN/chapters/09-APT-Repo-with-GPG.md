# 使用 Nginx 或对象存储构建私有 APT 仓库并启用 GPG 签名

本文档整合了在 Debian/Ubuntu 系列发行版上搭建自建 APT 仓库的常见方案，介绍如何
利用 `apt-ftparchive` + `gpg` 手动生成索引与签名，以及使用 `reprepro` 更自动化地管理
仓库。通过配合 Nginx 或对象存储可快速提供对外访问，并可在 CI/CD 中实现自动化发布。

## 1. 基础目录结构
```
deb/
└── dists/
    └── stable/
        └── main/
            └── binary-amd64/
                ├── *.deb
                ├── Packages
                └── Packages.gz
```
其中 `Packages` 与 `Packages.gz` 记录了包元数据，客户端通过 `dists/stable/Release`
和 `Release.gpg` 验证仓库。

## 2. apt-ftparchive + gpg 手动方式
1. **生成索引文件**
   ```bash
   cd deb/dists/stable/main/binary-amd64
   dpkg-scanpackages . /dev/null > Packages
   gzip -fk Packages
   cd ../../..
   apt-ftparchive -c apt.conf release dists/stable > dists/stable/Release
   ```
   `apt.conf` 用于配置发行版名称、组件等元数据。
2. **GPG 签名 Release 文件**
   ```bash
   gpg --default-key "<your-name>" -abs \
       -o dists/stable/Release.gpg dists/stable/Release
   ```
   客户端需导入对应公钥后方可校验。

## 3. 使用 reprepro 自动管理
`reprepro` 提供更完整的仓库管理能力，自动维护 `pool/` 目录、索引及 GPG 签名，适合正
式私服场景。
1. **准备目录结构**
   ```bash
   /srv/aptrepo/
   ├── conf/
   │   ├── distributions
   │   └── options
   ```
2. **distributions 配置示例**
   ```conf
   Codename: stable
   Suite: stable
   Components: main
   Architectures: amd64
   Origin: MyRepo
   Label: My Custom Repo
   SignWith: <GPG-ID>
   ```
3. **添加包并生成索引**
   ```bash
   reprepro -b /srv/aptrepo includedeb stable mypkg_1.0.0_amd64.deb
   ```
   执行后会在 `pool/` 下存放包文件，并自动更新 `Packages`, `Release` 以及 `Release.gpg`。

## 4. Nginx/对象存储托管
生成的 `deb/` 或 `/srv/aptrepo/` 可直接由 Nginx 发布：
```nginx
server {
    listen 80;
    server_name your.repo.domain;
    location /deb/ {
        root /srv/;
        autoindex on;
    }
}
```
也可以同步至对象存储（如 OSS/S3）并在客户端源列表中使用 HTTP/HTTPS 地址：
```
deb [trusted=yes] https://your-bucket.cdn.example.com/deb/ stable main
```

## 5. 与 YUM 仓库方案的比较
- `apt-ftparchive` 更轻量，适合临时或小型仓库；`reprepro` 适用于持续维护、多发行版的场景。
- 两者均可通过 GPG 对 `Release` 文件签名，提高客户端安全性。

以上内容可结合 GitHub Actions 或其他 CI 流程实现自动上传、更新索引与签名。
