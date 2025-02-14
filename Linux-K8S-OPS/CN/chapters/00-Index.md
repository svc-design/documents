# 系统管理索引

## 1. 系统信息管理

### 1.1 系统信息
- `uname -a` — 显示内核版本和操作系统信息
- `hostnamectl` — 查看和设置主机名
- `uptime` — 查看系统运行时间
- `top` — 实时查看系统进程
- `htop` — 更友好的系统进程查看器

### 1.2 软件包管理

#### 查询
- `dpkg -l` — 列出已安装的软件包（Debian/Ubuntu）
- `rpm -qa` — 列出已安装的软件包（RHEL/CentOS/Fedora）

#### Debian/Ubuntu（APT）
- `sudo apt update` — 更新软件源
- `sudo apt upgrade` — 升级已安装的软件包
- `sudo apt install <package>` — 安装软件包
- `sudo apt remove <package>` — 移除软件包
- `sudo apt search <package>` — 搜索软件包

#### RHEL/CentOS/Fedora（DNF）
- `sudo dnf update` — 更新软件包（Fedora 22 以后，RHEL 8/CentOS 8）
- `sudo dnf install <package>` — 安装软件包
- `sudo dnf remove <package>` — 移除软件包
- `sudo dnf search <package>` — 搜索软件包
- `sudo dnf upgrade` — 升级软件包

#### 旧版（YUM for CentOS 7 / RHEL 7）
- `sudo yum update` — 更新软件包
- `sudo yum install <package>` — 安装软件包
- `sudo yum remove <package>` — 移除软件包
- `sudo yum search <package>` — 搜索软件包

### 1.3 系统日志
- `journalctl` — 查看系统日志
- `dmesg` — 查看内核日志
- `/var/log/` — 查看其他日志文件，如 syslog、auth.log

## 2. 文件系统管理

### 2.1 查看磁盘信息
- `df -h` — 查看磁盘空间使用情况
- `du -sh /path/to/dir` — 查看目录的总大小
- `lsblk` — 列出所有块设备
- `fdisk -l` — 列出所有磁盘分区

### 2.2 创建和管理文件系统
- `sudo mkfs.ext4 /dev/sdX1` — 创建 ext4 文件系统
- `sudo mkfs.xfs /dev/sdX1` — 创建 xfs 文件系统
- `sudo mkfs.btrfs /dev/sdX1` — 创建 btrfs 文件系统
- `sudo mount /dev/sdX1 /mnt` — 临时挂载磁盘
- `sudo umount /mnt` — 卸载挂载的磁盘

### 2.3 `/etc/fstab` 配置
- `sudo nano /etc/fstab` — 编辑 fstab 文件，设置开机自动挂载，示例配置：
/dev/sda1 /mnt/data ext4 defaults 0 0

### 2.4 磁盘加密
- `sudo cryptsetup luksFormat /dev/sdX1` — 创建加密分区
- `sudo cryptsetup luksOpen /dev/sdX1 my_encrypted_disk` — 打开加密分区

## 3. 网络管理

### 3.1 网络配置

#### 查看网络接口信息
- `ip addr show` — 显示网络接口的 IP 地址信息
- `ifconfig` — 旧版命令，显示网络接口信息

#### 配置静态 IP 地址
- **Debian/Ubuntu**：编辑 `/etc/network/interfaces` 文件
```bash
iface eth0 inet static
  address 192.168.1.100
  netmask 255.255.255.0
  gateway 192.168.1.1
RHEL/CentOS/Fedora：使用 nmcli 命令

sudo nmcli con mod "System eth0" ipv4.addresses 192.168.1.100/24
sudo nmcli con mod "System eth0" ipv4.gateway 192.168.1.1
sudo nmcli con mod "System eth0" ipv4.method manual
sudo nmcli con up "System eth0"
3.2 网络诊断
ping <hostname> — 测试与远程主机的连通性
traceroute <hostname> — 跟踪网络路由
netstat -tuln — 查看系统中正在监听的端口
nc (Netcat)
nc -zv <hostname> <port-range> — 扫描主机某个端口范围是否开放
nc -l <port> — 监听某个端口，作为服务器端使用
nc <hostname> <port> — 连接到远程主机指定端口，作为客户端使用
nc -v <hostname> <port> — 显示连接详细信息
nmap
nmap <hostname> — 扫描目标主机的开放端口
nmap -sP <subnet> — Ping 扫描一个子网，列出存活的主机
nmap -sS <hostname> — 使用 SYN 扫描进行端口扫描（更隐蔽）
nmap -O <hostname> — 检测目标主机的操作系统
Tcpdump
tcpdump -i eth0 — 在接口 eth0 上抓取所有流量
tcpdump -i eth0 port 80 — 仅抓取 HTTP 流量（端口 80）
tcpdump -w output.pcap — 将捕获的数据包写入文件
tcpdump -r output.pcap — 读取捕获的文件进行分析
3.3 DNS 配置
sudo nano /etc/resolv.conf — 配置 DNS 服务器
nginx
复制
nameserver 8.8.8.8
nameserver 8.8.4.4
4. 安全管理
4.1 用户管理
sudo useradd username — 创建新用户
sudo userdel username — 删除用户
sudo passwd username — 设置用户密码
sudo groupadd groupname — 创建新用户组
sudo gpasswd -d username groupname — 将用户从组中删除
4.2 权限管理
chmod 755 <file> — 修改文件权限
chown user:group <file> — 修改文件所有者和用户组
chgrp <groupname> <file> — 修改文件的用户组
4.3 防火墙管理
查看当前防火墙状态
sudo ufw status （Debian/Ubuntu）
sudo firewall-cmd --state （RHEL/CentOS/Fedora）
启用防火墙
sudo ufw enable （Debian/Ubuntu）
sudo systemctl start firewalld （RHEL/CentOS/Fedora）
添加防火墙规则
sudo ufw allow 22/tcp （Debian/Ubuntu，允许 SSH）
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent （RHEL/CentOS/Fedora，允许 HTTP）
4.4 SELinux 配置（仅适用于 RHEL/CentOS/Fedora）
getenforce — 查看 SELinux 当前状态（Enforcing、Permissive、Disabled）
sudo setenforce 0 — 临时禁用 SELinux
sudo nano /etc/selinux/config — 永久禁用 SELinux（修改 SELINUX=disabled）
5. 服务和进程管理
5.1 管理服务
使用 systemctl 管理服务（适用于 RHEL/CentOS/Fedora 以及使用 systemd 的系统）

sudo systemctl start <service> — 启动服务
sudo systemctl stop <service> — 停止服务
sudo systemctl restart <service> — 重启服务
sudo systemctl enable <service> — 设置服务开机自启
sudo systemctl status <service> — 查看服务状态
5.2 管理进程
ps aux — 查看当前系统上的所有进程
top — 实时查看进程信息
kill <pid> — 终止进程
killall <process_name> — 终止指定名称的所有进程
6. 备份和恢复
6.1 使用 tar 进行备份/恢复文件
tar -czvf backup.tar.gz /path/to/directory
tar -xzvf backup.tar.gz -C /path/to/restore/
6.2 使用 rsync 进行文件同步
同步文件：
rsync -avz /path/to/source/ /path/to/destination/
7. 系统配置
7.1 查看系统性能
free -h — 查看内存使用情况
top — 查看 CPU 和内存使用情况
iostat — 查看磁盘 I/O 性能
vmstat — 查看虚拟内存使用情况
7.2 配置系统调度策略
sudo sysctl -w vm.swappiness=10 — 设置交换分区的优先级
