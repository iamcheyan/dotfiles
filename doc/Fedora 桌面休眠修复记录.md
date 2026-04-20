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
UUID=0f321df1-dd36-4116-bc55-56c51cde7cbc  none  swap  defaults,pri=150  0 0
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
sudo grubby --update-kernel=ALL --args="nokaslr mem_encrypt=off iommu=off resume=UUID=0f321df1-dd36-4116-bc55-56c51cde7cbc"

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

## 五、 策略优化：内存镜像与关机模式

### 1. 镜像大小限制（高性能模式）
如果 Swap 分区大于或等于物理内存（例如 64GB Swap / 62GB RAM），**强烈建议取消压缩限制**。
*   **原因**：在高性能 AMD 平台上，强制压缩 (`image_size=0`) 会导致极高的 CPU/内存瞬时负载，可能触发内核崩溃或休眠前重启。
*   **配置**：创建 `/etc/tmpfiles.d/hibernate-image-size.conf`：
    ```text
    # 将 image_size 设为 Swap 分区大小（例如 64GB），实现不压缩写入
    w /sys/power/image_size - - - - 64000000000
    ```

### 2. 强制关机模式
确保休眠后系统彻底断电，防止热重启导致 UEFI 丢失恢复签名。
*   **配置**：创建或修改 `/etc/systemd/sleep.conf`：
    ```ini
    [Sleep]
    HibernateMode=shutdown
    ```

---

## 六、 验证、测试与调试

### 1. 模拟测试框架（pm_test）
如果点击休眠后直接重启，使用内核测试模式定位故障环节（系统会模拟过程并自动返回桌面）：
```bash
# 测试级别 1：模拟设备驱动挂起（最常用，排查驱动冲突）
echo devices | sudo tee /sys/power/pm_test
sudo systemctl hibernate

# 测试级别 2：模拟核心系统挂起
echo core | sudo tee /sys/power/pm_test
sudo systemctl hibernate

# 测试完成后必须恢复正常模式
echo none | sudo tee /sys/power/pm_test
```

### 2. 日志排查
如果恢复失败，重启后第一时间查看：
```bash
# 查看上一次尝试休眠时的日志结尾
journalctl -b -1 | grep -iE "PM:|hibernation|resume"
# 查看本次启动是否识别到恢复签名
journalctl -b 0 | grep -i "PM: hibernation"
```

---

## 最终结果总结
*   ✅ **nokaslr / mem_encrypt=off**: 解决内存映射与加密冲突。
*   ✅ **HibernateMode=shutdown**: 解决 UEFI 恢复签名丢失问题。
*   ✅ **High Image Size**: 解决大内存机型由于过度压缩导致的休眠前崩溃。
*   ✅ **pm_test**: 提供了驱动级故障的快速排查手段。

---
*最后更新日期：2026年4月20日*
