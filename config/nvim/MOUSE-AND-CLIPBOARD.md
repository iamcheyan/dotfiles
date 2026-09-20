# Neovim 鼠标划选与跨平台剪贴板指南 (Mouse & Clipboard Guide)

本文档说明本 Neovim 配置中的**鼠标交互设计**、**选中文本自动复制（Copy on Select）机制**以及在 **Linux 原生环境与 WSL (Windows Subsystem for Linux)** 下的跨平台剪贴板同步原理。

---

## 1. 核心交互特性

本配置已针对现代 GUI 与终端交互习惯进行了优化，兼顾了传统 Vim 模态效率与现代编辑器的顺畅体验：

| 触发动作 | 生效模式 | 产生效果 |
|---|---|---|
| **按住鼠标左键拖拽** | 普通模式 (Normal) / 插入模式 (Insert) | 自动进入可视模式（Visual）划选文本，**松开鼠标时自动复制到系统剪贴板** |
| **双击鼠标左键** | 任意模式 | 快速选中光标所在单词，**自动复制到剪贴板** |
| **双击 HEX 颜色** | 普通模式 | 在光标所在的 `#RGB` / `#RRGGBB` 上双击，打开 `ccc.nvim` 交互式取色器（`:CccPick`） |
| **三击鼠标左键** | 任意模式 | 快速选中整行文本，**自动复制到剪贴板** |
| **普通单击鼠标** | 任意模式 | 仅移动光标定位，**绝不触碰或覆盖**剪贴板历史数据 |
| **选区保持可见** | 可视模式 | 释放鼠标后选区依然高亮保留（`gv`），便于核对范围或继续按 `d`/`c` 操作 |

---

## 2. 配置实现细节

配置文件位于：[`config/nvim/lua/config/keymaps.lua`](lua/config/keymaps.lua)

```lua
-- 鼠标选中文本自动复制到系统剪贴板 (Copy on select)
vim.keymap.set({ "x", "s" }, "<LeftRelease>", '"+ygv', { desc = "Auto-copy selection to clipboard", silent = true })
```

同时结合 [`config/nvim/lua/config/options.lua`](lua/config/options.lua) 中的多设备剪贴板自适应配置：
```lua
vim.opt.clipboard = "unnamedplus" -- 默认 yank 操作与系统剪贴板 (+) 深度同步
vim.opt.mouse = "a"              -- 全局开启所有模式的鼠标支持

-- 多设备跨平台智能剪贴板适配 (本地原生工具优先，无独立 GUI 时自动退回 tmux / 终端 OSC 52)
if vim.env.WAYLAND_DISPLAY and vim.env.WAYLAND_DISPLAY ~= "" and vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
  vim.g.clipboard = "wl-copy"
elseif vim.fn.has("mac") == 1 and vim.fn.executable("pbcopy") == 1 then
  vim.g.clipboard = "pbcopy"
elseif vim.fn.executable("win32yank.exe") == 1 then
  vim.g.clipboard = "win32yank"
elseif vim.env.DISPLAY and vim.env.DISPLAY ~= "" and vim.fn.executable("xclip") == 1 then
  vim.g.clipboard = "xclip"
elseif vim.env.TMUX and vim.env.TMUX ~= "" and vim.fn.executable("tmux") == 1 then
  vim.g.clipboard = "tmux"
else
  -- 无原生 GUI 显示服务时（如纯终端 SSH 远程连接），优雅降级到终端 OSC 52
  vim.g.clipboard = "osc52"
end
```

### HEX 颜色取色

在普通模式下双击 `#RGB` 或 `#RRGGBB` 颜色值时，配置会检查鼠标位置；如果确实位于
HEX 颜色文本上，就执行 `:CccPick` 打开 `ccc.nvim` 取色器。双击其他文本仍保持原有的
选词行为。需要格式转换时，仍可直接使用 `:CccConvert`。

### 工作流程
1. 当用户按下并拖动鼠标时，Neovim 接收到终端的鼠标序列，自动开启 Visual 选区。
2. 选区完毕、手指松开鼠标按键时，触发 `<LeftRelease>` 事件。
3. 监听到处于 Visual/Select 模式，自动执行 `"+y`，把当前选中文本写入寄存器 `+`（系统剪贴板）。
4. 随后立即执行 `gv`，保持高亮选区状态，避免像传统 `y` 那样立刻退回普通模式导致视觉中断。

---

## 3. 设计原理解析：为什么传统 Vim 默认不这么做？

在初次使用 Vim/Neovim 时，很多用户会疑惑为什么它不能像 Fresh 或 VS Code 那样随时随地拿鼠标划选：

1. **模态编辑（Modal Editing）的铁律**：
   * 在无模式编辑器中，光标只有一种状态。
   * 在 Vim 的普通模式下，光标是一个**指令锚点**，按键代表命令（如 `d` 删、`c` 改、`j` 下移）。普通模式下**不存在“带选区的状态”**。只要产生选区，就必须切换到专门承载选区的**可视模式（Visual Mode）**。
2. **文本对象（Text Objects）的键盘效率哲学**：
   * Vim 推崇双手停留在主键区（Home Row）。
   * 针对代码编辑，Vim 提供了速度和精度远超鼠标拖拽的文本对象：
     * `viw`（选词）、`vi"`（选引号内）、`vi(`（选括号内参数）、`vip`（选段落）。
   * 两下按键就能精准选中语义块，因此传统 Unix 工具刻意弱化对鼠标划选的依赖。
3. **终端与应用对鼠标事件的捕获争夺**：
   * 终端自身拥有划选复制功能（操作系统剪贴板）。
   * 全屏 TUI 程序捕获鼠标后，若不精细配置，容易阻断终端的原生操作。当前配置通过专用 `<LeftRelease>` 拦截，既保证了 Neovim 内部精准选词选段，又实现了无感的系统级剪贴板写入。

---

## 4. WSL (Windows Subsystem for Linux) 跨平台同步指南

本套机制在 **WSL 1 / WSL 2** 环境下经过验证，**完全兼容且开箱即用**。

### 4.1 跨界同步链路
```text
┌──────────────────────────────────────────────────────────┐
│ Windows 宿主机 (Windows Terminal / WezTerm / Alacritty)   │
│   ▲                                                      │
│   │ 4. Ctrl+V 直接粘贴 (宿主系统剪贴板)                     │
│   │                                                      │
│   ▼                                                      │
│ ┌──────────────────────────────────────────────────────┐ │
│ │ WSL (Linux 环境)                                     │ │
│ │   ▲                                                  │ │
│ │   │ 3. Provider 自动跨界推送 (OSC 52 / win32yank)      │ │
│ │   │                                                  │ │
│ │   ▼                                                  │ │
│ │ Neovim 寄存器 (+) ◄── [鼠标划选松开触发 "+ygv]        │ │
│ └──────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

1. 在 WSL 内的 Neovim 中用鼠标划选文本并松开。
2. 触发 `"+ygv` 写入 Neovim 剪贴板寄存器 `+`。
3. Neovim 底层自动检测 WSL 环境，通过剪贴板 Provider 将内容同步注入 **Windows 宿主机剪贴板**。
4. 切换到 Windows 上的任何程序（微信、浏览器、Office、VS Code 等），按 `Ctrl+V` 即可直接粘贴。

### 4.2 WSL 最佳实践与避坑事项

#### 避坑 1：不要按住 `Shift` 键拖拽
* 像 **Windows Terminal** 这类终端，默认会将直接的鼠标划选透传给 WSL 内部的 Neovim。
* 如果按住了 `Shift` 键再划选，会触发 Windows Terminal 自身的“强制终端文本选择”，该操作绕过了 Neovim，无法触发 Neovim 的语法语义选区。日常使用时**直接松开键盘、单用鼠标划选**即可。

#### 避坑 2：剪贴板 Provider 性能优化（0 毫秒极速体验）
Neovim 在 WSL 下支持多种剪贴板通信协议，推荐优先级如下：

1. **OSC 52 协议（强烈推荐，0 延迟、无需安装任何工具）**：
   * Neovim 0.10+ 内置了原生的 OSC 52 支持。
   * 只要终端（Windows Terminal 1.18+、WezTerm 等）开启了 OSC 52 接收，Neovim 复制时直接向终端输出控制序列，完全不经过子进程调用，实现 0 毫秒瞬间同步。
2. **win32yank.exe（极速二进制桥接）**：
   * Neovim 官方为 WSL 推荐的极小体积桥接工具：[equalsraf/win32yank](https://github.com/equalsraf/win32yank)。
   * 下载后将 `win32yank.exe` 放入 WSL 的 `/usr/local/bin/` 或系统 PATH 中，并赋予可执行权限（`chmod +x`），Neovim 会优先调用它，复制无感秒同步。
3. **clip.exe（系统默认兜底）**：
   * 若无上述工具，Neovim 会自动调用 Windows 自带的 `clip.exe`。功能正常，但若划选数万行超大文本时，偶尔可能感受到底层跨子系统进程创建的微小开销。

### 4.3 Kitty 终端免弹窗配置 (OSC 52 读写授权)

在 Kitty 终端中，默认对通过 OSC 52 **读取**剪贴板的行为设置了安全确认弹窗（`read-clipboard-ask`，提示 `"A program running in this window wants to read from the system clipboard..."`）。

为避免在 SSH/远程或终端降级环境下粘贴时反复弹出确认框，Kitty 配置（`~/.config/kitty/kitty.conf`）已启用：
```conf
clipboard_control write-clipboard write-primary read-clipboard read-primary
```
这样不仅保障了远程与跨设备会话下的无感粘贴，配合 Neovim 的“本地工具优先、无环境自动降级 OSC 52”策略，完美兼顾了速度与全场景兼容性。

---

## 5. 现代编辑器操作流 (AI 协作与跨软件剪贴板协同)

为彻底解决与 AI 聊天、浏览器网页查资料时频繁复制粘贴的割裂感，本配置引入了与现代编辑器（VS Code / 浏览器）一致的核心键位，并兼顾了 Vim 的模态编辑特性：

| 快捷键 | 生效模式 | 产生效果 | 设计与防冲突说明 |
|---|---|---|---|
| **`Ctrl + A`** | 普通 (Normal) / 可视 (Visual) / 插入 (Insert) | **全选整个文件**（进入可视行选区 `ggVG`） | 替代繁琐的 `ggVG`。原数字加 1 功能移至 `<leader>a` |
| **`Ctrl + C`** | 可视模式 (Visual) | **复制当前选区至系统剪贴板**并退出可视模式 | 普通模式下保留原生的打断/取消行为，绝不破坏终端退出习惯 |
| **`Ctrl + X`** | 可视模式 (Visual) | **剪切当前选区至系统剪贴板** (`"+d`) | 普通模式保留数字减 1，插入模式保留 `<C-x><C-f>` 等路径补全 |
| **`p` / `Ctrl + V`** | 可视模式 (Visual) | **直接覆盖替换选区，绝不污染剪贴板** | 解决 Vim 祖传痛点：从 AI 复制的代码**不会**被删除的老代码冲掉，可连续粘贴多处 |
| **`Ctrl + V`** | 插入模式 (Insert) | **从系统剪贴板原样粘贴** (`<C-r><C-o>+`) | 保留代码原始缩进格式，避免自动缩进导致的阶梯式错位 |
| **`p`** | 普通模式 (Normal) | 在光标后粘贴系统剪贴板内容 | 单键粘贴极速高效；普通模式保留 `<C-v>` 为原生的**列块可视选择模式** |

### 5.1 极速 AI 协作工作流示例

1. **全选代码发给 AI**：
   * 在 Neovim 中按下 **`Ctrl + A`**（全选） $\to$ 按下 **`Ctrl + C`**（复制到系统剪贴板）。
   * 切到浏览器/聊天窗口，直接 `Ctrl + V` 发送给 AI。
2. **拿回 AI 代码覆盖原函数**：
   * 在 AI 聊天窗口点击复制新代码。
   * 切回 Neovim，可视模式选中老代码（鼠标拖选或按 `V`）。
   * 直接按下 **`p`** 或 **`Ctrl + V`**：选区瞬间被 AI 代码覆盖替换。
   * 如果还要在别处替换，剪贴板依然是 AI 代码，继续选中并按 `p` 覆盖即可，剪贴板绝不会被老代码污染。
