
etcd问题汇总
1. etcd存储空间占用问题
1.1 问题背景
    - 登录K8S集群，执行kubectl操作，响应特别慢
    - 单节点K8S集群运行不稳定
    - 查看系统负载
      top - 13:49:55 up 61 days,  2:30,  2 users,  load average: 26.59, 37.72, 30.98 Tasks: 741 total,   1 running, 740 sleeping,   0 stopped,   0 zombie %Cpu(s):  1.8 us,  1.6 sy,  0.0 ni, 94.2 id,  2.5 wa,  0.0 hi,  0.0 si,  0.0 st
    - 检查etcd存储
      cd /opt/lib/etcd/ #  du -hs *
517M    member
[root@etcd]# cd member/
[root@k8s-master-node member]# du -hs * 90M     snap 428M    wal [root@k8s-master-node member]# cd  wal/
[root@k8s-master-node wal]#
du -hs *
62M     0000000000000067-00000000005f06a4.wal.broken
62M     00000000000009ad-0000000008b4afe0.wal
62M     00000000000009ae-0000000008b591d9.wal
62M     00000000000009af-0000000008b66cb4.wal
62M     00000000000009b0-0000000008b74d95.wal
62M     00000000000009b1-0000000008b830cb.wal
62M     1.tmp
 [root@k8s-master-node wal]# du -hs 428M    .
1.2 异常结论
- 存储占用过高：总的 wal 文件占用了 428MB，这对于单节点系统来说是相对较大的数据量，尤其是当这些文件持续增长时，可能会导致存储压力增大，进而影响系统性能。
.wal.broken 文件的存在：文件中出现 .wal.broken 文件，表示系统在写入日志时发生了错误。此时需要排查系统磁盘、I/O 性能或其他异常。
- 缺乏清理机制：没有看到自动归档或删除旧日志的机制，可能导致 wal 文件和临时文件不断堆积，造成磁盘空间不足。
2 问题处理过程
2.1 查看etcd集群存储的状态
etcdctl --endpoints=https://10.237.239.23:2379 \
        --cacert=/etc/ssl/etcd/ssl/ca.pem \
        --cert=/etc/ssl/etcd/ssl/node-k8s-master-node.pem \
        --key=/etc/ssl/etcd/ssl/node-k8s-master-node-key.pem \
        endpoint status --write-out=table
[图片]
每列的含义：
暂时无法在飞书文档外展示此内容
2.2 查看当前版本号（非上表中版本）
etcdctl --endpoints=https://10.237.239.23:2379                             \
        --cacert=/etc/ssl/etcd/ssl/ca.pem                                  \
        --cert=/etc/ssl/etcd/ssl/node-k8s-master-node.pem     \
        --key=/etc/ssl/etcd/ssl/node-k8s-master-node-key.pem  \
        endpoint status --write-out="json" | egrep -o '"revision":[0-9]*' | egrep -o '[0-9].*'
会出现一串数字比如 1234567 此为版本号
3.3 执行空间压缩
etcdctl --endpoints=https://10.237.239.23:2379                             \
        --cacert=/etc/ssl/etcd/ssl/ca.pem                                  \
        --cert=/etc/ssl/etcd/ssl/node-k8s-master-node.pem     \
        --key=/etc/ssl/etcd/ssl/node-k8s-master-node-key.pem  \
        compact 1234567  （替换成节点的版本号）
4.1 重新检查etcd集群存储的状态
etcdctl --endpoints=https://10.237.239.23:2379                           \
        --cacert=/etc/ssl/etcd/ssl/ca.pem                                \
        --cert=/etc/ssl/etcd/ssl/node-k8s-master-node.pem   \           --key=/etc/ssl/etcd/ssl/node-k8s-master-node-key.pem         endpoint status --write-out=table
[图片]
清理完成后，DB SIZE从原来的94M -> 8.9M
4.2 检查系统状态
系统IO负载 立刻明显降低
top - 15:05:39 up 61 days,  3:46,  1 user,  load average: 6.97, 7.47, 7.83
Tasks: 728 total,   3 running, 725 sleeping,   0 stopped,   0 zombie
%Cpu(s): 20.3 us,  2.1 sy,  0.0 ni, 77.3 id,  0.2 wa,  0.0 hi,  0.0 si,  0.0 st


1. etcd 备份脚本
这个脚本会使用 etcdctl 工具进行 etcd 集群的备份，确保你能够恢复集群的数据。
备份脚本：etcd-backup.sh
bash
复制编辑
#!/bin/bash配置项
ETCDCTL_API=3
ETCD_ENDPOINTS="https://10.237.239.23:2379"
ETCD_CA_FILE="/etc/ssl/etcd/ssl/ca.pem"
ETCD_CERT_FILE="/etc/ssl/etcd/ssl/node-deepflow-slave5-dongjinjiang.pem"
ETCD_KEY_FILE="/etc/ssl/etcd/ssl/node-deepflow-slave5-dongjinjiang-key.pem"
BACKUP_DIR="/backup/etcd"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/etcd-backup-${DATE}.db"创建备份目录（如果不存在）mkdir -p $BACKUP_DIR执行备份
etcdctl --endpoints=$ETCD_ENDPOINTS \
        --cacert=$ETCD_CA_FILE \
        --cert=$ETCD_CERT_FILE \
        --key=$ETCD_KEY_FILE \
        snapshot save $BACKUP_FILE输出备份文件路径echo "Backup saved to $BACKUP_FILE"
说明：
- 使用 etcdctl snapshot save 命令来备份 etcd 数据。
- 备份文件将保存到指定的目录 (/backup/etcd)，文件名包含时间戳。
2. etcd 恢复脚本
此脚本会将 etcd 的数据恢复到指定的备份文件。
恢复脚本：etcd-restore.sh
#!/bin/bash配置项
ETCDCTL_API=3
ETCD_ENDPOINTS="https://10.237.239.23:2379"
ETCD_CA_FILE="/etc/ssl/etcd/ssl/ca.pem"
ETCD_CERT_FILE="/etc/ssl/etcd/ssl/node-deepflow-slave5-dongjinjiang.pem"
ETCD_KEY_FILE="/etc/ssl/etcd/ssl/node-deepflow-slave5-dongjinjiang-key.pem"
BACKUP_FILE="/backup/etcd/etcd-backup-YYYY-MM-DD_HH-MM-SS.db"  需要替换成具体备份文件路径恢复 etct 数据
etcdctl --endpoints=$ETCD_ENDPOINTS \
        --cacert=$ETCD_CA_FILE \
        --cert=$ETCD_CERT_FILE \
        --key=$ETCD_KEY_FILE \
        snapshot restore $BACKUP_FILE \
        --data-dir=/opt/lib/etcd

重启 etcd 服务（具体服务名和路径可能不同）
systemctl restart etcd

输出恢复完成信息echo "Restore completed from $BACKUP_FILE"
说明：
- etcdctl snapshot restore 命令用于恢复 etcd 数据。
- 恢复后的数据会被存放到 /opt/lib/etcd 目录，服务会在恢复后重启。
