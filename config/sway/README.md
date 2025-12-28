# Sway 使用文档

基于 [Ruixi-rebirth/sway-dotfiles](https://github.com/Ruixi-rebirth/sway-dotfiles) 配置，保留原有键绑定设置。

## 目录

- [基础概念](#基础概念)
- [快捷键列表](#快捷键列表)
  - [基础操作](#基础操作)
  - [窗口导航](#窗口导航)
  - [工作区管理](#工作区管理)
  - [布局管理](#布局管理)
  - [窗口调整](#窗口调整)
  - [媒体控制](#媒体控制)
  - [系统操作](#系统操作)

---

## 基础概念

### 修饰键 (Mod Key)
- **$mod = Mod4**（通常是 Super/Win 键）

### 方向键
使用 Vim 风格的方向键：
- `h` = 左 (left)
- `j` = 下 (down)
- `k` = 上 (up)
- `l` = 右 (right)

你也可以使用传统的方向键（↑↓←→）

---

## 快捷键列表

### 基础操作

| 快捷键 | 功能 |
|--------|------|
| `Mod + Enter` | 打开终端 (foot) |
| `Mod + Shift + E` | 关闭当前窗口 |
| `Mod + D` | 打开应用程序启动器 (dmenu) |
| `Mod + Shift + C` | 重新加载配置文件 |
| `Mod + 鼠标左键` | 拖动浮动窗口 |
| `Mod + 鼠标右键` | 调整浮动窗口大小 |

---

### 窗口导航

#### 移动焦点（切换窗口）

| 快捷键 | 功能 |
|--------|------|
| `Mod + H` 或 `Mod + ←` | 焦点移到左边窗口 |
| `Mod + J` 或 `Mod + ↓` | 焦点移到下边窗口 |
| `Mod + K` 或 `Mod + ↑` | 焦点移到上边窗口 |
| `Mod + L` 或 `Mod + →` | 焦点移到右边窗口 |

#### 移动窗口位置

| 快捷键 | 功能 |
|--------|------|
| `Mod + Shift + H` 或 `Mod + Shift + ←` | 将窗口移到左边 |
| `Mod + Shift + J` 或 `Mod + Shift + ↓` | 将窗口移到下边 |
| `Mod + Shift + K` 或 `Mod + Shift + ↑` | 将窗口移到上边 |
| `Mod + Shift + L` 或 `Mod + Shift + →` | 将窗口移到右边 |
| `Mod + A` | 将焦点移到父容器 |

---

### 工作区管理

#### 切换工作区

| 快捷键 | 功能 |
|--------|------|
| `Mod + 1` | 切换到工作区 1 |
| `Mod + 2` | 切换到工作区 2 |
| `Mod + 3` | 切换到工作区 3 |
| `Mod + 4` | 切换到工作区 4 |
| `Mod + 5` | 切换到工作区 5 |
| `Mod + 6` | 切换到工作区 6 |
| `Mod + 7` | 切换到工作区 7 |
| `Mod + 8` | 切换到工作区 8 |
| `Mod + 9` | 切换到工作区 9 |
| `Mod + 0` | 切换到工作区 10 |

#### 移动窗口到工作区

| 快捷键 | 功能 |
|--------|------|
| `Mod + Shift + 1` | 将窗口移到工作区 1 |
| `Mod + Shift + 2` | 将窗口移到工作区 2 |
| `Mod + Shift + 3` | 将窗口移到工作区 3 |
| `Mod + Shift + 4` | 将窗口移到工作区 4 |
| `Mod + Shift + 5` | 将窗口移到工作区 5 |
| `Mod + Shift + 6` | 将窗口移到工作区 6 |
| `Mod + Shift + 7` | 将窗口移到工作区 7 |
| `Mod + Shift + 8` | 将窗口移到工作区 8 |
| `Mod + Shift + 9` | 将窗口移到工作区 9 |
| `Mod + Shift + 0` | 将窗口移到工作区 10 |

---

### 布局管理

| 快捷键 | 功能 |
|--------|------|
| `Mod + B` | 水平分割（左右布局） |
| `Mod + V` | 垂直分割（上下布局） |
| `Mod + S` | 堆叠布局 |
| `Mod + W` | 标签页布局 |
| `Mod + E` | 切换分割方向 |
| `Mod + F` | 全屏切换 |
| `Mod + Shift + Space` | 切换窗口为浮动模式 |
| `Mod + Space` | 在平铺区域和浮动区域之间切换焦点 |

---

### 窗口调整

#### 调整大小模式

1. 按 `Mod + R` 进入调整大小模式
2. 在调整大小模式下：

| 快捷键 | 功能 |
|--------|------|
| `H` 或 `←` | 缩小宽度（每次 10px） |
| `J` 或 `↓` | 增加高度（每次 10px） |
| `K` 或 `↑` | 缩小高度（每次 10px） |
| `L` 或 `→` | 增加宽度（每次 10px） |
| `Enter` 或 `Escape` | 退出调整大小模式 |

---

### 临时工作区 (Scratchpad)

| 快捷键 | 功能 |
|--------|------|
| `Mod + Shift + -` | 将当前窗口移到临时工作区（隐藏） |
| `Mod + -` | 显示/隐藏临时工作区的窗口 |

---

### 媒体控制

| 快捷键 | 功能 |
|--------|------|
| `XF86AudioRaiseVolume` | 增加音量（+5%） |
| `XF86AudioLowerVolume` | 降低音量（-5%） |
| `XF86AudioMute` | 切换静音 |
| `XF86AudioMicMute` | 切换麦克风静音 |
| `XF86MonBrightnessUp` | 增加屏幕亮度 |
| `XF86MonBrightnessDown` | 降低屏幕亮度 |
| `XF86AudioPlay` | 播放/暂停媒体 |
| `XF86AudioNext` | 下一首 |
| `XF86AudioPrev` | 上一首 |

---

### 系统操作

| 快捷键 | 功能 |
|--------|------|
| `Mod + Shift + C` | 重新加载 Sway 配置 |
| `Caps Lock` | 作为 Escape 键使用（需要在配置中启用） |

---

## 窗口规则

某些窗口类型会自动设置为浮动模式：
- 对话框（dialog, pop-up, bubble）
- 菜单（menu）
- 工具箱（toolbox）
- 设置对话框（Preferences, About, Organizer）
- Authy 认证窗口

---

## 外观设置

- **窗口边框**：3px 像素边框
- **窗口间距**：内部 5px，外部 0px
- **智能边框**：当只有一个窗口时自动隐藏边框
- **自适应同步**：启用（减少屏幕撕裂）

---

## 配置文件位置

- 主配置文件：`~/.config/sway/config`
- 脚本目录：`~/.config/sway/scripts/`

---

## 相关脚本

脚本位于 `~/.config/sway/scripts/` 目录：

- `install_waybar_deps.sh` - 安装 Waybar 依赖工具

更多脚本使用说明请查看 `~/.config/sway/scripts/README.md`

---

## 提示

1. **重新加载配置**：修改配置文件后，按 `Mod + Shift + C` 重新加载，无需重启 Sway
2. **查看键绑定**：使用 `swaymsg -t get_keybindings` 查看当前所有键绑定
3. **调试模式**：启动 Sway 时使用 `sway -d` 查看调试信息

---

## 参考

- [Sway 官方文档](https://swaywm.org/)
- [Sway 配置文件手册](https://man.archlinux.org/man/sway.5)
- [配置来源仓库](https://github.com/Ruixi-rebirth/sway-dotfiles)

