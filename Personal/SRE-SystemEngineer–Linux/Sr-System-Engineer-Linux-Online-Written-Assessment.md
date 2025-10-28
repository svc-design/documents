# Sr. System Engineer (Linux) — 全面面试题库 & 答题思路

结构化覆盖：笔试/在线测评 → 一面（内核/性能/网络/存储）→ 二面（架构/稳定性/可观测）→ 终面（系统化方法论 & 事故复盘）。每节含：高频题、标准作答骨架、延伸 & 实战命令清单。

# 0. 面试总攻略（答题框架）

- STAR/SCQA：场景（S）→ 指标/约束（C）→ 方案（Q）→ 结果（A）。
- 四象限排障法：CPU / 内存 / I/O / 网络；
- 纵深 3 层：症状 → 资源 → 根因（代码路径/配置/硬件/流量）。

黄金工具链：top|htop、vmstat、iostat、pidstat、ss、sar、perf、bcc/bpftrace、journalctl、dmesg、strace/ltrace、systemd-analyze、nmcli、ethtool、fio、blktrace、pcp、tuned。

现场答题口头模板：先定义术语与前提 → 列出 80/20 主要方向 → 明确观测指标 & 复现实验 → 给出可回滚的最小变更方案。

# 1. 笔试 / 在线测评题库

## 1.1 文本处理与 Shell

- Q1：统计 /var/log/nginx/access.log 中访问最多的前 5 个 IP
A：

awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -5

扩展：

#排除健康检查、仅统计 200 成功且 /api 路径
awk '$9==200 && $7 ~ /^\/api\// {print $1}' access.log | sort | uniq -c | sort -nr | head -10
# 统计每分钟 QPS（含时间窗解析）
awk '{gsub(/\[|\]/,"",$4); t=substr($4,1,17) ";00"; c[t]++} END{for(k in c) print k, c[k]}' access.log | sort

- Q2：查找大文件 & 近 24h 内变更的配置

find / -xdev -type f -size +500M -printf '%s %p\n' | sort -nr | head -20
find /etc -type f -mtime -1 -print

- Q3：批量替换文本（幂等）

sed -ri 's/^(#?UseDNS)\s+.*/UseDNS no/' /etc/ssh/sshd_config && systemctl reload sshd

## 1.2 性能 & 指标理解

Q：Load average 高（>20），CPU 仅 30%
**答题骨架：**
- load 包含 R(运行) + D(IO 不可中断)；多见于 IO/锁/进程调度。
- 先看 vmstat 1 的 r/b、wa；i
- ostat -x 1 看 await/svctm/util；
- pidstat -d 1 找罪魁进程；
- 必要时 perf top/offcpu 分析。
- 一键： vmstat 1; iostat -x 1; pidstat -rud 1

## 1.3 配置与安全

Q：不重启修改内核参数

sysctl -w net.ipv4.ip_forward=1
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-custom.conf
sysctl --system

## 1.4 连接问题

Q：SSH 登录延迟 10s，ping 正常

UseDNS no、GSSAPIAuthentication no；

/etc/hosts 反解；
ss -tn state syn-recv；
熵不足 cat /proc/sys/kernel/random/entropy_avail；

PAM/脚本钩子；

sshd -T 验证有效配置。

# 2. Linux 启动体系：早期 vs 现代

## 2.1 早期（BIOS/MBR → LILO/GRUB → 内核 → SysVinit）

MBR 仅 446B bootloader 首段；`

init 读取 /etc/inittab，运行 rc 脚本（/etc/rc*.d/）。

## 2.2 现代（UEFI → GRUB2 → Kernel + initramfs → systemd）

- UEFI + GPT；GRUB2 菜单；内核参数通过 GRUB_CMDLINE_LINUX; dracut 生成 initramfs；
- systemd：unit 依赖、target、systemd-analyze blame/critical-chain、journalctl -b。

快速定位启动慢：

systemd-analyze time
systemd-analyze blame
systemd-analyze critical-chain

救援：在 GRUB 编辑增加 systemd.unit=rescue.target 或 rd.break；chroot 修复 fstab / 密码。

# 3. systemd / 服务管理

- Unit 类型：service、socket、timer、path、mount、slice、target。
- 常用命令：systemctl status|restart|cat、show -p、list-dependencies、edit --full。
- 定时替代 cron：*.timer（优势：依赖/日志/失败重试）。
- 资源控制：systemctl set-property <u>.service CPUQuota=50% MemoryMax=2G（cgroup v2）。

# 故障复盘模板：

journalctl -u xxx -b -1；2) systemctl show -p 看失败原因；3) ExecStart 手工前台运行；4) Type/After/Requires 校验；5) SELinux/AppArmor。

# 4. 内核、进程与调度

- 调度器：CFS；nice/renice，chrt（RT），taskset/cset 绑核，irqbalance、isolcpus、nohz_full。
- 内核观测：/proc、/sys、sysctl、pressure stall (psi)：cat /proc/pressure/{cpu,io,memory}。
- 火焰图 / eBPF：perf record/report，bcc（execsnoop, opensnoop, biolatency, runqlat），bpftrace one-liners。
- 死锁与 D 状态：echo t > /proc/sysrq-trigger dump 任务；关注堆栈 D/blocked on IO。

# 5. 内存与存储


- 内存：页缓存/匿名页；free -m、/proc/meminfo、smem、slabtop；vm.swappiness；透明大页 THP；OOM：dmesg|journalctl -k，oom_score_adj。
- 文件系统：ext4（通用）、xfs（大文件/日志型）、btrfs（快照/压缩）、ZFS（EC/L2ARC）——优缺点与适用场景。
- LVM/RAID：pvcreate/vgcreate/lvcreate；mdadm --detail；在线扩容：lvextend -r。

# 性能工具：iostat -x、fio、blktrace|btt、smartctl。

常见题：inode 耗尽、no space left 但 df 有空（reserved blocks/目录项）、目录百万小文件导致 readdir 慢。

6. 网络：栈、调优与排障

- 基础面：ip a|r|neigh、ss -tunap、tcpdump、ethtool -k（卸载）、mtu/TSO/GRO、rps/rfs/xps。
- 连接追踪：conntrack -L、nf_conntrack_max、TIME_WAIT、tw_reuse 注意语义差异（新内核已废弃场景）。
- 队列与拥塞：qdisc（fq/codel）、tc qdisc，net.ipv4.tcp_congestion_control=bbr。
- 防火墙：nftables（推荐）/iptables；firewalld 上层；Zeroconf/ARP/邻居缓存。

常见考点：

SYN 洪泛 → syn_cookies、backlog、somaxconn、反向代理缓冲；
高并发长连接 → ip_local_port_range、tcp_fin_timeout、keepalive；
三层/四层定位：mtr, traceroute -T, ss -i, tcpdump 'tcp[tcpflags] & (tcp-syn) != 0'。

# 7. 安全、用户与认证

- 账户/权限：sudoers 最小权限，setfacl/getfacl；
- PAM：登录流程，/etc/pam.d/*；
- SELinux/AppArmor：getenforce、semanage fcontext、restorecon、audit2allow；

审计/合规：auditd 规则、aide 完整性；fail2ban；SSH 硬化项清单。

# 8. 日志、时间与可观测性

systemd-journald → rsyslog 流；journalctl -u svc --since -1h；
时间同步：chrony（首推）/ntpd；timedatectl；leap 秒/漂移。
性能历史：sysstat (sar)、pcp、atop；容量预测：sar -b, sar -d。

# 9. 虚拟化与容器基础

KVM/QEMU/libvirt：virsh dominfo、vCPU 绑核、HugePages；
容器：namespaces、cgroups v2、systemd 与容器的协作；podman/docker 网络模式对比；日志/ulimit；

内核接口：/sys/fs/cgroup、/proc/<pid>/cgroup；容器内排障与宿主机观测的边界。

# 10. 发行版与包管理

RHEL 系：dnf/yum、rpm -q --changelog、alternatives、firewalld、SELinux；

Deb 系：apt、dpkg -S、update-alternatives；

内核模块/DKMS：modprobe, lsmod, dkms status；

构建题：自编译 NGINX 带模块（--with-openssl=...）、动态模块开启、systemd unit 编写。

11. 高频场景题（附命令清单）
11.1 “CPU 100%” 快速定位
top -H -p $(pgrep -d, -f myproc)
pidstat -t -p <pid> 1
perf top -p <pid>

回答点：区分用户态/内核态，热点函数→锁竞争→系统调用；必要时火焰图。

11.2 “内存泄漏 / OOM”
journalctl -k | grep -i oom
cat /proc/meminfo; slabtop; pmap -x <pid>

回答点：区分 RSS 增长 vs page cache；jemalloc/malloc trim；cgroup 限额。

11.3 “磁盘 100% util”
iostat -x 1; pidstat -d 1; fio --filename=/dev/nvme0n1 --rw=randread --iodepth=32 --bs=4k --runtime=60 --name=bench

回答点：随机/顺序、队列深度、IO 大小、对齐、文件系统选型与挂载选项（noatime, discard）。

11.4 “网络抖动/丢包”
mtr -rwzc100 target
ethtool -S eth0 | egrep 'err|drop'
ss -tin 'sport = :443'

回答点：队列拥塞、重传率、GRO/TSO、网卡中断绑核、RPS/XPS。

11.5 “启动慢 / 服务依赖错乱”
systemd-analyze blame; systemctl list-dependencies svc.service; journalctl -u svc -b

回答点：After/Requires/Wants、Type=notify、Restart=、ExecStartPre= 可观测。

12. sysctl 常见调优模板（按场景）
Web 高并发（谨慎按需）
net.core.somaxconn = 1024
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 4096
# 拥塞控制
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
低延迟服务 / 金融撮合（示例）
kernel.sched_migration_cost_ns = 500000
kernel.sched_autogroup_enabled = 0
vm.swappiness = 1
13. 安全硬化核查表（面试可快速背诵）

SSH：禁 root 密钥外登录、AllowUsers 白名单、KexAlgorithms/MACs/Ciphers 收敛；

系统：最小化安装、自动安全更新、umask/limits、fs.protected_*；

日志：auditd 关键目录、journald 永久存储；

SELinux：enforcing，自定义策略变更留审计；

防火墙：nftables 明确入站策略，必要端口限速；

供应链：仓库加签、rpm --verify/debsums；

备份与演练：/etc, systemd units, crontab, ssh keys, scripts。

14. 架构/稳定性开放题（面试二面/三面）

Q：如何设计 10 万 QPS 的 Nginx 入口层？
答题骨架：多 AZ、Anycast/DNS；LB 层 4/7；Nginx worker/reuseport；epoll、零拷贝；连接复用；限流/熔断；日志异步；可观测（status、exporter、EBPF）。

Q：一次“load 飙升”事故复盘
答题骨架：时间线 → 指标（CPU/IO/队列/连接）→ 临时措施（限流/扩容/kill -STOP）→ 根因（SQL/锁/磁盘）→ 长期措施（容量、压测、报警、变更流程）。

Q：如何在不影响业务前提下内核升级？

答题骨架：蓝绿/金丝雀；kexec fast reboot；内核包 DKMS 驱动验证；回滚路径；变更窗口与指标观测。

15. 现场动手实验（面试官爱考）

定位最耗 IO 的进程：pidstat -d 1、iotop -oPa；

抓 TCP 三次握手与重传：tcpdump -i eth0 tcp and port 443 -vv -w cap.pcap、tcptracer-bpfcc；

重放 IO 工作负载：fio job 文件；

写 systemd timer 替换 cron：/etc/systemd/system/logrotate.timer + logrotate.service；

bpftrace one-liner：bpftrace -e 'kprobe:tcp_v4_connect { @[comm] = count(); }'

16. 附：标准回答句式（英文版要点）

“First, I would validate the symptom and quantify it with metrics (CPU, run queue, I/O wait, retransmits). Then I’d narrow it down by correlating processes, syscalls and kernel events using pidstat, perf, and eBPF tools. Finally, I’d apply the smallest safe change and keep a clear rollback path.”

“I always separate transient mitigation from permanent fixes, and I document the incident with a clear timeline and actionable follow-ups.”

17. 面试清单（携带脑图）

- 观测工具速记；
- sysctl 模板；
- SSH/系统安全硬化 10 条；
- 故障复盘骨架；
- 不同发行版差异点（RHEL vs Debian）。

需要的话，我可以根据贵司栈（RHEL/Debian、云厂商、容器/虚拟化、NGINX/Kafka/MySQL 等）再生成“定制题库 + 标准答案 + 上机实验脚本”。
