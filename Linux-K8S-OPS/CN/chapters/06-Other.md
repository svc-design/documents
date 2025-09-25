# Windows 11 电脑安装双系统 Linux 的 BIOS/UEFI 和 Windows 设置

## 目标
在已安装 **Windows 11** 的桌面电脑上，正确配置 **BIOS/UEFI** 和 **Windows** 以支持 **Linux 双系统**，并 **保留 TPM**（可信平台模块）。

---

## 1. BIOS/UEFI 设置

### 1.1 进入 BIOS/UEFI
1. **重启电脑**，在开机 Logo 显示时按 **F2 / F12 / DEL / ESC**（不同品牌主板按键不同）。
2. **找到 Secure Boot 选项**（通常在 `Security` 或 `Boot` 选项卡中）。
3. **进入 Advanced Mode（高级模式）**（部分 BIOS 可能需要）。

### 1.2 修改 BIOS 选项

| **设置项**       | **修改方式**                                      | **说明** |
|------------------|------------------------------------------------|---------|
| **Secure Boot**  | **Disabled（禁用）**                           | 允许启动非微软签名的系统，如 Linux |
| **Boot Mode**    | **UEFI（推荐）** / Legacy（部分系统可能支持）  | 选择 **UEFI** 以支持 GPT 分区表 |
| **TPM**（Intel PTT / AMD fTPM） | **Enabled（启用）**            | 保留 TPM，以支持 BitLocker 或远程认证 |
| **Boot Order**（引导顺序） | **Linux / Windows Boot Manager** | 确保引导 Linux 安装介质 |

### 1.3 保存并退出 BIOS
1. 按 **F10** 保存设置并退出。
2. 系统自动重启。

---

## 2. Windows 11 相关设置

### 2.1 关闭 BitLocker（磁盘加密）
> **如果 BitLocker 已启用，建议先关闭，否则 Linux 可能无法访问磁盘**
1. **Win + S** 搜索 “BitLocker” 并打开 **BitLocker 驱动器加密**。
2. **找到 C 盘**，点击 **关闭 BitLocker**，等待解密完成。

### 2.2 关闭内核隔离
> **避免 Linux 驱动兼容问题**
1. **Win + I** 打开 **设置 > 隐私和安全 > Windows 安全中心**。
2. 进入 **设备安全性 > 核心隔离**，关闭 **内存完整性**。

### 2.3 禁用 Modern Standby（现代待机）
> **部分设备可能需要，以避免 Linux 兼容性问题**
1. 以管理员权限打开 **CMD**，输入：
   ```powershell
   powercfg /h off

禁用休眠模式，避免影响 Linux 启动。

2.4 关闭 Windows 快速启动

	防止 Windows 影响 GRUB 引导

	1.	进入 控制面板 > 电源选项 > 选择电源按钮的功能。
	2.	点击 更改当前不可用的设置。
	3.	取消勾选 启用快速启动。

2.5 关闭 VBS（虚拟化安全）（可选）

	如果 Linux 兼容性受影响，可关闭 VBS

	1.	进入 Windows 安全中心 > 设备安全性。
	2.	关闭 内存完整性 选项。

分区准备（Linux 安装前）

3.1 调整 Windows 分区

	给 Linux 预留空间（建议 30GB+）

	1.	Win + X 选择 磁盘管理。
	2.	右键 C 盘 > 压缩卷，分配出 未分配空间，作为 Linux 安装分区。

3.2 准备 Linux 安装介质
	1.	下载 Linux ISO（如 Ubuntu、Debian、Arch）。
	2.	使用 Rufus 创建 UEFI 启动 U 盘。

 安装 Linux

4.1 进入 U 盘引导
	1.	插入 Linux 启动 U 盘，重启电脑。
	2.	在开机 Logo 时按 F12 / ESC 进入 Boot Menu。
	3.	选择 U 盘（UEFI 模式） 进行安装。

4.2 安装 Linux
	1.	选择 “自定义分区”，使用之前释放的未分配空间创建：
	•	根分区（/）：50GB+（建议 EXT4）
	•	Swap 交换分区（可选）：8GB（等于物理内存）
	2.	选择 GRUB 安装到 EFI 分区（通常是 /boot/efi）。
	3.	完成安装，重启系统。

解决双系统引导问题

5.1 进入 BIOS 重新调整引导顺序
	•	如果 Windows 11 启动 而非 Linux：
	1.	进入 BIOS > Boot Order。
	2.	选择 GRUB / Linux Boot Manager 作为默认启动项。
	3.	保存并重启。

5.2 进入 Windows 修复 GRUB

	如果 Windows 更新导致 Linux 无法启动

	1.	进入 Windows，使用管理员权限打开 CMD：

```cmd
bcdedit /set {bootmgr} path \EFI\ubuntu\grubx64.efi
```

.	重启，GRUB 应该可以正常显示。

6. 总结

BIOS/UEFI 必须调整

✅ 关闭 Secure Boot
✅ 保持 TPM 启用
✅ 启用 UEFI 模式（不建议 Legacy）
✅ 设置 正确的 Boot Order（Linux/Windows Boot Manager）

Windows 11 必须调整

✅ 关闭 BitLocker（防止磁盘加密导致 Linux 访问失败）
✅ 关闭核心隔离（避免 Linux 兼容性问题）
✅ 禁用 Modern Standby（某些设备可能需要）
✅ 关闭 Windows 快速启动（防止影响 GRUB）
✅ 调整 Windows 分区（为 Linux 预留空间）


