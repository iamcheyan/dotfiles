# Fedora Btrfs 快照与 GRUB 启动项配置文档

本文档记录了在 Fedora 系统上配置 `grub-btrfs` 和 `snapper` 的完整步骤，包括针对非标准挂载结构的特殊修复。

## 1. 安装软件包

### 启用 COPR 仓库并安装 grub-btrfs
`grub-btrfs` 负责将 Btrfs 快照集成到 GRUB 启动菜单中。
```bash
sudo dnf copr enable kylegospo/grub-btrfs
sudo dnf install grub-btrfs
```

### 安装 Snapper 及 DNF 插件
`snapper` 用于管理快照，插件确保在执行 `dnf` 操作前后自动触发快照。
```bash
sudo dnf install snapper python3-dnf-plugin-snapper
```

## 2. 配置 Snapper

### 创建根目录配置
```bash
sudo snapper -c root create-config /
```

### 修复 .snapshots 子卷
由于 Fedora 默认可能将 `.snapshots` 创建为普通目录而非子卷，需手动修复以确保快照独立存储：
```bash
sudo btrfs subvolume delete /.snapshots  # 如果已存在且是子卷则删除
sudo rmdir /.snapshots                   # 如果是普通目录则删除
sudo btrfs subvolume create /.snapshots
```

### 启用定时清理服务
```bash
sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
```

## 3. 配置 grub-btrfs 自动化

### 修复 grub-btrfs.path 依赖问题
在 Fedora 中，如果 `.snapshots` 不是独立的挂载点，`grub-btrfs.path` 默认会因为寻找 `\.snapshots.mount` 失败而无法启动。

**解决方案：**
1. 复制服务文件到系统配置目录：
   ```bash
   sudo cp /usr/lib/systemd/system/grub-btrfs.path /etc/systemd/system/grub-btrfs.path
   ```
2. 修改 `/etc/systemd/system/grub-btrfs.path`，删除以下行：
   - `Requires=\x2esnapshots.mount`
   - `After=\x2esnapshots.mount`
   - `BindsTo=\x2esnapshots.mount`
3. 将 `[Install]` 段落中的 `WantedBy` 改为 `multi-user.target`。

### 启用服务并刷新 GRUB
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now grub-btrfs.path
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

## 4. 常用操作命令

- **查看快照列表**：`sudo snapper list`
- **手动创建快照**：`sudo snapper create -d "描述名称"`
- **删除快照**：`sudo snapper delete <快照编号>`
- **更新 GRUB 菜单**（如果自动监控失效）：`sudo grub2-mkconfig -o /boot/grub2/grub.cfg`

## 5. 故障排查
如果开机没看到快照菜单，请检查 `/etc/default/grub-btrfs/config` 中的路径配置：
- `GRUB_BTRFS_GRUB_DIRNAME="/boot/grub2"`
- `GRUB_BTRFS_MKCONFIG=/usr/bin/grub2-mkconfig`
- `GRUB_BTRFS_SCRIPT_CHECK=grub2-script-check`
