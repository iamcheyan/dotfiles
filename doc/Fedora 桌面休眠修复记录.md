# Fedora 桌面休眠修复记录（深度进阶版）

本文记录了在 Fedora (AMD 平台) 上彻底修复休眠（Hibernate）功能的完整方案。除了常规的 Swap 和 GRUB 配置，还深入解决了内核地址随机化 (KASLR)、AMD 内存加密 (SME) 以及硬件 IOMMU 导致的休眠镜像校验失败问题。

## 问题现象
1.  **自动唤醒**：进入休眠后风扇停转，但几秒钟内自动重启。
2.  **休眠失败（直接重启）**：点击休眠后机器重启，回到登录界面，所有工作内容丢失。
3.  **架构数据不匹配**：日志显示 `PM: hibernation: Image mismatch: architecture specific data`，即使内核版本一致也无法恢复。
4.  **休眠后数小时自动开机，恢复时屏幕不亮**：系统 hibernate 成功关机，但几小时后自己启动，电源灯亮、风扇转，屏幕却黑屏无信号，只能强制关机。内核日志大量出现 `amdgpu: failed to write reg 28b4 wait reg 28c6` 等 GPU 恢复错误。
5.  **休眠镜像创建失败**：日志显示 `Failed to put system to sleep. System resumed again: Cannot allocate memory`，因可用内存不足导致无法创建休眠镜像。

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

防止鼠标移动、USB 信号或网络包导致意外唤醒。

### 4.1 ACPI 唤醒设备禁用
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

启用：
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now disable-wakeup.service
```

### 4.2 USB 设备唤醒禁用（关键）
无线鼠标/键盘接收器（如 Logitech Unifying、2.4G 接收器）在 `s2idle` 模式下极其敏感，轻微震动或信号干扰即可唤醒系统。

创建 `/etc/systemd/system/disable-usb-wakeup.service`：
```ini
[Unit]
Description=Disable USB wakeup sources
After=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for d in /sys/bus/usb/devices/*/power/wakeup; do [ -f "$d" ] && echo disabled > "$d" 2>/dev/null; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
```

启用：
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now disable-usb-wakeup.service
```

### 4.3 网卡 Wake-on-LAN 禁用
部分网卡默认开启 WOL，局域网内的唤醒包可导致意外恢复。

创建 `/etc/systemd/system/disable-nic-wol.service`：
```ini
[Unit]
Description=Disable NIC Wake-on-LAN
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for nic in /sys/class/net/*; do nic=$(basename "$nic"); [ "$nic" = "lo" ] && continue; [ -d "/sys/class/net/$nic/device" ] || continue; /usr/sbin/ethtool -s "$nic" wol d 2>/dev/null || true; done'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

启用：
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now disable-nic-wol.service
```

### 4.4 验证唤醒源状态
```bash
# 查看 ACPI 唤醒设备
cat /proc/acpi/wakeup

# 查看 USB 设备唤醒状态
for f in /sys/bus/usb/devices/*/power/wakeup; do
    [ -f "$f" ] && echo "$(basename $(dirname $f)): $(cat $f)"
done

# 查看网卡 WOL 状态
sudo ethtool <网卡名> | grep Wake-on

# 查看 RTC 定时唤醒是否被设置
cat /sys/class/rtc/rtc0/wakealarm
cat /proc/driver/rtc | grep alarm
```
预期结果：除电源按钮（PBTN/LNXPWRBN）外，所有设备状态应为 `disabled`；RTC alarm 应为空。

---

### 4.5 休眠前钩子脚本（关键：防止 Hibernate 后自动开机）

> **重要区别**：前面 4.1~4.3 的 systemd 服务在**开机后**运行，只能防止 `suspend`（睡眠）后的意外唤醒；`hibernate`（休眠）的本质是**关机**，关机后的自动开机由 BIOS/硬件决定，操作系统已不存在。
>
> 但软件层面仍有一个可控点：**RTC alarm**。某些程序（包括 systemd timer、NetworkManager 等）可能在休眠前通过 RTC 设置定时唤醒。如果 hibernate 成功关机后数小时（如 10~12 小时）系统自己开机，RTC alarm 是最大嫌疑。

创建 `/usr/lib/systemd/system-sleep/disable-wake`，systemd 会在每次休眠/睡眠前自动调用：

```bash
#!/bin/sh
# 在休眠/睡眠前禁用所有软件层面的唤醒源
# 注意：hibernate(S4)本质上是关机，自动开机由BIOS/硬件决定，
# 此脚本只能清除Linux可控的RTC alarm和ACPI/USB唤醒，
# BIOS中的WOL/RTC/USB唤醒需在BIOS里手动关闭

case $1 in
    pre)
        # 1. 清除RTC定时唤醒（防止systemd timer或其他程序设置了RTC alarm）
        if [ -w /sys/class/rtc/rtc0/wakealarm ]; then
            echo 0 > /sys/class/rtc/rtc0/wakealarm 2>/dev/null
        fi

        # 2. 禁用ACPI唤醒源（对suspend有效，hibernate作用有限但无害）
        if [ -w /proc/acpi/wakeup ]; then
            grep -E '^[^ ]+[[:space:]]+S[34]' /proc/acpi/wakeup 2>/dev/null | \
            while read -r line; do
                dev=$(echo "$line" | awk '{print $1}')
                status=$(echo "$line" | awk '{print $3}')
                if [ "$status" = "*enabled" ] || [ "$status" = "enabled" ]; then
                    echo "$dev" > /proc/acpi/wakeup 2>/dev/null
                fi
            done
        fi

        # 3. 禁用USB设备唤醒
        for f in /sys/bus/usb/devices/*/power/wakeup; do
            [ -w "$f" ] && echo disabled > "$f" 2>/dev/null
        done

        # 4. 禁用PCI设备唤醒
        for f in /sys/bus/pci/devices/*/power/wakeup; do
            [ -w "$f" ] && echo disabled > "$f" 2>/dev/null
        done

        # 5. 禁用网络接口的WoL（如果ethtool可用）
        if command -v ethtool >/dev/null 2>&1; then
            for iface in /sys/class/net/*; do
                iface=$(basename "$iface")
                [ "$iface" = "lo" ] && continue
                ethtool -s "$iface" wol d 2>/dev/null
            done
        fi
        ;;
esac
```

赋予执行权限：
```bash
sudo chmod +x /usr/lib/systemd/system-sleep/disable-wake
```

**此脚本与 4.1~4.3 的 systemd 服务不冲突**，可以共存：钩子脚本在**每次休眠前**清除 RTC alarm，服务在**开机后**持久化禁用 ACPI/USB/NIC 唤醒。

---

## 五、 Hibernate 自动开机排查与 BIOS 设置

如果执行了上述全部软件层面的配置后，hibernate 仍然数小时后自动开机，说明唤醒源在 **BIOS/UEFI** 中，必须进 BIOS 手动关闭。

### 5.1 典型症状判断

| 现象 | 最可能原因 |
|---|---|
| hibernate 后**立刻**自动开机（几秒~几分钟） | 休眠镜像创建失败、驱动恢复失败、ACPI/USB 唤醒 |
| hibernate 后**数小时**自动开机（如 6h/12h/24h） | **RTC Alarm** 或 BIOS 定时唤醒 |
| 恢复后屏幕不亮、电源灯亮、风扇转 | AMDGPU 驱动恢复失败（见第六节） |

### 5.2 BIOS 中必须关闭的唤醒选项

开机按 `Del`/`F2` 进入 BIOS，在 **Power Management** / **ACPI Settings** / **Advanced** 菜单中找到以下选项并设为 **Disabled**：

- **Resume By Alarm** / **RTC Wake** / **Wake on RTC** — RTC 定时开机
- **Wake on LAN (WoL)** / **Power On By PCIE** — 网卡/PCIe 设备唤醒
- **Wake From USB** / **USB Wake Support** — USB 设备唤醒（鼠标键盘移动即开机）
- **Power On By Keyboard/Mouse** — 键鼠开机
- **Restore on AC/Power Loss** — 来电自启（断电恢复后自动开机）
- **Wake on Pattern Match** / **Wake on PME** — 某些主板特有的网络包/电源管理事件唤醒

> **注意**：不同主板厂商（ASRock/ASUS/MSI/Gigabyte）菜单名称不同。你的主板 BIOS 厂商是 **ALASKA (AMI)**，通常在 `Advanced -> ACPI Configuration` 或 `Advanced -> South Bridge Configuration` 中。

---

## 六、 AMDGPU 显卡恢复失败导致黑屏

### 6.1 问题现象

从 hibernate 恢复后，系统实际已在后台正常运行（网络连接、服务启动），但屏幕完全黑屏、无信号。内核日志出现大量重复错误：

```
amdgpu 0000:04:00.0: amdgpu: failed to write reg 28b4 wait reg 28c6
amdgpu 0000:04:00.0: amdgpu: failed to write reg 1a6f4 wait reg 1a706
```

这是 AMD APU（Renoir / Cezanne，如 Ryzen 5000/6000 系列）的 **SMU（System Management Unit）** 在休眠恢复时通信失败，显示核心（DCN）未能重新初始化。内核版本 `6.19.12` 在该型号的电源管理恢复路径上存在已知 bug。

### 6.2 临时缓解方案

如果黑屏频繁发生，可在恢复后尝试**盲操作**切换 TTY 强制重新初始化显卡：
```bash
# 恢复后黑屏时，按 Ctrl+Alt+F3 再按 Ctrl+Alt+F1
# 或盲输入重启 GDM：
sudo systemctl restart gdm
```

### 6.3 内核参数缓解（未经验证，可尝试）

在 GRUB 参数中添加 AMDGPU 电源管理调试掩码，禁用部分恢复路径：
```bash
sudo grubby --update-kernel=ALL --args="amdgpu.dcdebugmask=0x410"
```

或在 modprobe 配置中禁用运行时电源管理：
```bash
echo 'options amdgpu runpm=0' | sudo tee /etc/modprobe.d/amdgpu-hibernate.conf
sudo dracut -f --regenerate-all
```

> **注意**：`runpm=0` 会阻止显卡在运行时进入低功耗状态，可能影响续航和发热，仅建议桌面主机使用。

### 6.4 根本解决建议

- **升级内核**：Fedora 43 的 `6.19.12` 在 AMD APU 休眠恢复上有较多问题，建议跟进 `6.20+` 或 Fedora 官方更新的稳定版内核。
- **改用 suspend（睡眠）而非 hibernate**：suspend（S3）不保存磁盘镜像，显卡恢复路径与 hibernate 不同，黑屏概率通常更低。代价是睡眠期间需要持续供电。
- **或彻底放弃休眠/睡眠**：直接普通关机，配合浏览器/IDE 的会话恢复功能恢复工作状态。

---

## 七、 策略优化：内存镜像与关机模式

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

## 八、 验证、测试与调试

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
*   ✅ **USB / NIC 唤醒禁用**: 解决无线接收器、网卡 WOL 导致的休眠后意外唤醒。
*   ✅ **systemd-sleep 钩子脚本 (disable-wake)**: 在每次休眠前清除 RTC alarm 和 ACPI/USB/PCI 唤醒，防止 hibernate 后数小时自动开机。
*   ✅ **BIOS 唤醒选项禁用**: 软件层面无法阻止的硬件唤醒源（RTC Alarm / WoL / USB Wake）需在 BIOS 中手动关闭。
*   ⚠️ **amdgpu hibernate 恢复黑屏**: AMD APU 在 `6.19.12` 内核上存在已知 bug，建议升级内核或改用 suspend/普通关机。

---
*最后更新日期：2026年4月29日*
