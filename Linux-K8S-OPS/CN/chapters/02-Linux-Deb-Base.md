防火墙（Firewall）
Debian/Ubuntu:
- 依赖包：ufw（Uncomplicated Firewall）或 iptables
  - 关闭 UFW 防火墙（默认使用 UFW）：
  - sudo ufw disable             # 禁用 UFW 防火墙
sudo systemctl disable ufw   # 禁用 UFW 服务开机启动
  - 关闭 iptables：
  - sudo systemctl stop iptables     # 停止 iptables 服务
sudo systemctl disable iptables  # 禁用 iptables 服务开机启动
AppArmor
Debian/Ubuntu 默认没有启用 SELinux，而是使用 AppArmor 进行访问控制。如果你需要使用 SELinux，可以通过安装 selinux 包来启用：
- 安装 SELinux：
  sudo apt update
sudo apt install selinux-basics selinux-policy-default
- 临时禁用 SELinux：
  sudo setenforce 0
- 永久禁用 SElinux：
编辑 /etc/selinux/config，将 SELINUX=enforcing 修改为 SELINUX=disabled，然后重启系统。
LVM 操作
Debian/Ubuntu:
-  LVM 工具依赖包：lvm2
  sudo apt update
sudo apt install lvm2
  LVM常用操作
  - 列出卷组（VG）：   sudo vgs
  - 列出逻辑卷（LV）：sudo lvs
  - 创建卷组（VG）：   sudo vgcreate <volume-group-name> /dev/sdX
  - 创建逻辑卷（LV）：sudo lvcreate -n <logical-volume-name> -L <size> <volume-group-name>
  - 扩展逻辑卷（LV）：sudo lvextend -L +<size> /dev/<volume-group-name>/<logical-volume-name>
sudo resize2fs /dev/<volume-group-name>/<logical-volume-name>
  - 删除逻辑卷（LV）：sudo lvremove /dev/<volume-group-name>/<logical-volume-name>
  - 删除卷组（VG）：   sudo vgremove <volume-group-name>
  - 删除物理卷（PV）：sudo pvremove /dev/sdX
网络配置
Ubuntu 20.04之前 使用 interfaces 配置模板
在 Ubuntu 20.04 之前，网络配置文件通常为 /etc/network/interfaces。以下是一个传统的配置模板：
/etc/network/interfacesLoopback interface
auto lo
iface lo inet loopback

Wired interface (eth0) with static IP
auto eth0
iface eth0 inet static
    address 192.168.1.100        设置静态 IP
    netmask 255.255.255.0        设置子网掩码
    gateway 192.168.1.1          设置默认网关
    dns-nameservers 8.8.8.8 8.8.4.4   设置 DNS 服务器Wired interface (eth0) with DHCP

auto eth0
iface eth0 inet dhcp            使用 DHCP 获取 IP 地址Wireless interface (wlan0) with static IP
auto wlan0
iface wlan0 inet static
    address 192.168.1.101
    netmask 255.255.255.0
    gateway 192.168.1.1
    wpa-ssid "YourNetworkName"    Wi-Fi 网络名称
    wpa-psk "YourNetworkPassword"  Wi-Fi 密码
- auto eth0：表示接口 eth0 会在启动时自动启用。
- iface eth0 inet static：设置静态 IP。
- iface eth0 inet dhcp：使用 DHCP 自动获取 IP 地址。
- dns-nameservers：配置 DNS 服务器。

---
Ubuntu 20.04+ 使用 netplan 配置模板
从 Ubuntu 20.04 开始，netplan 成为了默认的网络配置工具，配置文件通常位于 /etc/netplan/ 目录下。以下是一个典型的 50-cloud-init.yaml 配置模板：
# /etc/netplan/50-cloud-init.yaml

network:
  version: 2
  renderer: networkd        # 使用 systemd-networkd 作为渲染器
  ethernets:
    eth0:                   # 网卡名称
      dhcp4: false          # 禁用 DHCP 获取 IPv4 地址
      addresses:
        - 192.168.1.100/24  # 设置静态 IP 和子网掩码
      gateway4: 192.168.1.1  # 设置默认网关
      nameservers:
        addresses:
          - 8.8.8.8        # 设置 DNS 服务器
          - 8.8.4.4
配置示例解释：
- version: 2：指定 netplan 配置的版本。
- renderer: networkd：指定使用 systemd-networkd 渲染器（也可以使用 NetworkManager，取决于系统配置）。
- eth0：网卡名称，可能根据你的系统不同而不同。
- dhcp4: false：禁用 DHCP。
- addresses：设置静态 IP 地址。
- gateway4：设置默认网关。
- nameservers：设置 DNS 服务器。
在编辑完配置文件后，应用新的网络配置：sudo netplan apply
