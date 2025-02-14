防火墙（Firewall）

RHEL/CentOS依赖包：firewalld（默认使用 firewalld）
  关闭 firewalld：
  sudo systemctl stop firewalld    # 停止 firewalld 服务
sudo systemctl disable firewalld # 禁用 firewalld 服务开机启动
   关闭 iptables（如果系统未使用 firewalld）：
  - sudo systemctl stop iptables     # 停止 iptables 服务
sudo systemctl disable iptables  # 禁用 iptables 服务开机启动
SELinux
RHEL/CentOS 默认启用了 SELinux，关闭 SELinux 操作如下：
- 临时禁用 SELinux：
- sudo setenforce 0
- 永久禁用 SELinux： 编辑 /etc/selinux/config 文件，将 SELINUX=enforcing 修改为 SELINUX=disabled，然后重启系统。
LVM 操作
RHEL/CentOS常用操作
- 安装 LVM 工具：sudo yum install lvm2
- 列出卷组（VG）：sudo vgs
- 列出逻辑卷（LV）：sudo lvs
- 创建卷组（VG）：sudo vgcreate <volume-group-name> /dev/sdX
- 创建逻辑卷（LV）：sudo lvcreate -n <logical-volume-name> -L <size> <volume-group-name>
- 扩展逻辑卷（LV）：sudo lvextend -L +<size> /dev/<volume-group-name>/<logical-volume-name>
sudo resize2fs /dev/<volume-group-name>/<logical-volume-name>
- 删除逻辑卷（LV）：sudo lvremove /dev/<volume-group-name>/<logical-volume-name>
- 删除卷组（VG）：  sudo vgremove <volume-group-name>
- 删除物理卷（PV）：sudo pvremove /dev/sdX
网络配置
RHEL/CentOS 7 之前的网卡配置
在 RHEL/CentOS 7 之前，网络配置通过编辑 /etc/sysconfig/network-scripts/ifcfg-<interface> 文件来管理。以下是一个典型的 ifcfg-eth0 配置文件示例：
# /etc/sysconfig/network-scripts/ifcfg-eth0

DEVICE=eth0                   # 网络接口名称
BOOTPROTO=static              # 配置静态 IP
ONBOOT=yes                    # 启动时启用该接口
IPADDR=192.168.1.100          # 静态 IP 地址
NETMASK=255.255.255.0         # 子网掩码
GATEWAY=192.168.1.1           # 默认网关
DNS1=8.8.8.8                  # DNS 服务器
DNS2=8.8.4.4                  # DNS 服务器
DEFROUTE=yes
配置示例解释：
- DEVICE=eth0：指定接口名称为 eth0。
- BOOTPROTO=static：使用静态 IP 配置。
- ONBOOT=yes：表示接口在启动时启用。
- IPADDR=192.168.1.100：配置静态 IP 地址。
- NETMASK=255.255.255.0：配置子网掩码。
- GATEWAY=192.168.1.1：指定默认网关。
- DEFROUTE=yes：将该接口设置为默认路由接口。
应用配置：sudo systemctl restart network

---
RHEL/CentOS 8 之后的网卡配置
  从 RHEL/CentOS 8 开始，网络管理工具变得更加现代化，开始默认使用 NetworkManager 或 nmcli 工具来管理网络，并且仍然兼容原有网络配置文件/etc/sysconfig/network-scripts/ifcfg-eth0 文件，可以通过以下命令重新加载修改后的网络配置：
- 使用 nmcli 重新加载接口：sudo nmcli connection reload
- 或重启网络接口：sudo nmcli connection down eth0 && sudo nmcli connection up eth0
验证网络配置
使用以下命令查看网络接口的状态，确保 NetworkManager 正确应用了 ifcfg-eth0 配置文件中的设置：nmcli connection show eth0
或者：ip a show eth0
