# Fedora 桌面休眠修复记录（深度进阶版）

本文记录了在 Fedora (AMD 平台) 上彻底修复休眠（Hibernate）功能的完整方案。除了常规的 Swap 和 GRUB 配置，还深入解决了内核地址随机化 (KASLR)、AMD 内存加密 (SME) 以及硬件 IOMMU 导致的休眠镜像校验失败问题。

## 问题现象
1.  **自动唤醒**：进入休眠后风扇停转，但几秒钟内自动重启。
2.  **休眠失败（直接重启）**：点击休眠后机器重启，回到登录界面，所有工作内容丢失。
3.  **架构数据不匹配**：日志显示 `PM: hibernation: Image mismatch: architecture specific data`，即使内核版本一致也无法恢复。

---

## 一、 存储基础：Swap 分区与优先级

### 1. 确认 Swap 分区
休眠必须使用物理 Swap 分区（建议大小 $\ge$ 内存容量）。
```bash
swapon --show
```
确保显示的是 `/dev/nvme...` 或 `/dev/sd...` 物理分区，而非 `zram`。

### 2. 彻底禁用 zram 干扰
Fedora 默认使用 zram，这会干扰休眠逻辑。
```bash
# 卸载 zram 生成器
sudo dnf remove -y zram-generator-defaults zram-generator
# 立即关闭当前 zram
sudo swapoff /dev/zram0
sudo modprobe -r zram
```

### 3. 设置物理 Swap 优先级
编辑 `/etc/fstab`，确保物理 Swap 分区的优先级（pri）高于一切。
```text
UUID=6dd61338-ca03-4ad2-a86f-cc821c6b2e17  none  swap  defaults,pri=150  0 0
```
修改后执行 `sudo systemctl daemon-reload`。

---

## 二、 核心修复：内核参数与硬件兼容性

这是解决 `Image mismatch` 的关键。AMD 系统和现代内核需要特定参数来固定内存映射。

### 1. 使用 grubby 注入启动参数
```bash
# 1. 禁用 KASLR（防止内存地址随机偏移）
# 2. 禁用 SME 内存加密（防止冷启动密钥丢失）
# 3. 禁用 IOMMU（规避硬件映射冲突）
# 4. 指定 resume 分区
sudo grubby --update-kernel=ALL --args="nokaslr mem_encrypt=off iommu=off resume=UUID=6dd61338-ca03-4ad2-a86f-cc821c6b2e17"

# 建议移除 quiet rhgb 以便观察恢复进度
sudo grubby --update-kernel=ALL --remove-args="quiet rhgb"
```

### 2. 修正 BLS 配置
Fedora 使用 BLS 启动规范，如果参数未生效，检查 `/boot/loader/entries/` 下的 `.conf` 文件中的 `options` 行。

---

## 三、 驱动强化：Initramfs 预加载

必须确保内核在恢复瞬间就能识别 NVMe 硬盘。

### 1. 配置 dracut
创建 `/etc/dracut.conf.d/99-resume.conf`：
```bash
# 强制添加 resume 模块和 nvme 驱动
add_dracutmodules+=" resume "
add_drivers+=" nvme "
```

### 2. 重新生成映像
```bash
sudo dracut -f --regenerate-all
```

---

## 四、 电源管理：持久化禁用唤醒源

防止鼠标移动或总线信号导致意外唤醒。

### 1. 创建自动禁用服务
创建 `/etc/systemd/system/disable-wakeup.service`：
```ini
[Unit]
Description=Disable ACPI Wakeup Devices
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "for dev in $(awk '/enabled/ {print $1}' /proc/acpi/wakeup | grep -v PBTN); do echo $dev > /proc/acpi/wakeup; done"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

### 2. 启用服务
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now disable-wakeup.service
```

---

## 五、 策略优化：休眠镜像压缩

### 1. 为什么需要优化？
通过 `free -h` 可以发现，本机的物理内存为 **62GiB**，而物理 Swap 分区 (`/dev/nvme0n1p3`) 仅为 **60.5GiB**。
*注意：休眠无法使用 zram，因此物理 Swap 分区必须能容纳压缩后的内存镜像。*

由于物理分区（60.5GiB）略小于内存总量（62GiB），如果内存占用较高，休眠可能会因空间不足而失败。

### 2. 强制压缩配置
创建 `/etc/tmpfiles.d/hibernate-image-size.conf`：
```text
# w 代表写入，将 image_size 设为 0 (最小化策略)
# 这会强制内核在休眠时尽可能压缩镜像，确保 62GB 的内存数据能安全塞进 60.5GB 的物理分区。
w /sys/power/image_size - - - - 0
```

---

## 六、 验证与调试

### 1. 验证参数是否生效
重启后检查：
```bash
cat /proc/cmdline  # 应该包含 nokaslr, mem_encrypt=off
swapon --show      # 物理分区优先级应为 150
```

### 2. 测试休眠
```bash
sudo systemctl hibernate
```

### 3. 日志排查
如果失败，重启后第一时间查看：
```bash
journalctl -b -1 | grep -iE "PM:|hibernation|resume"
```

---

## 最终结果总结
*   ✅ **nokaslr**: 解决了架构数据不匹配问题。
*   ✅ **mem_encrypt=off**: 解决了 AMD 平台加密干扰。
*   ✅ **nvme driver**: 确保了恢复时能读到磁盘。
*   ✅ **disable-wakeup**: 解决了自动唤醒问题。
*   ✅ **image_size=0**: 解决了内存压缩与空间适配。

---
*最后更新日期：2026年4月19日*
