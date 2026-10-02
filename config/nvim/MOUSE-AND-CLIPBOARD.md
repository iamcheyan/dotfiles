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

---

## 6. 全面纯删除与专属剪切体系 (True Delete & Dedicated Cut)

### 6.1 痛点背景与老旧插件翻车分析

在标准 Vim/Neovim 中，任何未显式指定寄存器的删除操作（`d`、`c`、`x`、`s`）本质上都是“剪切（Cut）”，会默认写入无名寄存器（`""`）；一旦启用了 `vim.opt.clipboard = "unnamedplus"`，每一次删除都会自动同步并覆写系统剪贴板（`"+"`）。

这导致了极度恶劣的跨软件交互体验：
> **典型场景**：从网页/浏览器复制了一段代码或 URL $\to$ 切回 Neovim 准备替换旧代码 $\to$ 使用 `ci"` 或 `dw` 删掉旧代码 $\to$ 按粘贴时惊愕地发现：刚删掉的旧代码把从网页复制的内容给覆盖冲掉了！

此前曾短暂引入第三方插件 `svermeulen/vim-cutlass`，但在复杂配置中暴露出严重缺陷：
1. **加载时序滞后（`event = "VeryLazy"`）**：新打开文件时插件尚未加载，早期按键直接走原生逻辑污染剪贴板。
2. **弱映射避让机制（Weak Mapping，致命硬伤）**：插件源码中如果检测到某个模式或前缀已有现有映射（`which-key`、`mini.ai`、`flash`），就会**静默放弃映射**，导致 `ci"`、`ca"`、`s` 等极其常用的组合根本没被送进黑洞寄存器。
3. **架构老旧**：近十年未维护的 VimScript 脚本，无法与现代 Neovim 0.11 的 Treesitter、Lua text-objects 协调。

### 6.2 架构重构：原生零延迟黑洞映射体系

我们在 [`config/nvim/lua/config/keymaps.lua`](lua/config/keymaps.lua) 中直接采用 Neovim 原生无条件黑洞寄存器（`"_`）重定向，并在启动第一时间生效（0 插件依赖、0 延迟、0 避让死角）：

#### A. 增加与配置的纯删除动作清单 (100% 进黑洞 `"_`，绝不污染剪贴板)

| 类别 | 映射键位 | 覆盖的操作与组合 | 说明 |
|---|---|---|---|
| **修改 (Change)** | `c` $\to$ `"_c`<br>`cc` $\to$ `"_S`<br>`C` $\to$ `"_C` | `ci"`、`ca"`、`ciw`、`caw`、`cw`、`c$`、`cc`、`C` 及 `mini.ai` 自定义文本对象 | 彻底解决修改操作中旧内容冲掉剪贴板的头号痛点 |
| **删除 (Delete)** | `d` $\to$ `"_d`<br>`dd` $\to$ `"_dd`<br>`D` $\to$ `"_D` | `di"`、`da"`、`diw`、`daw`、`dw`、`d$`、`dd`、`D` 及结合任意 motion/光标跳转 | 所有的基础删除变为现代编辑器的纯删除 |
| **字符删除 (Char)** | `x` $\to$ `"_x`<br>`X` $\to$ `"_X`<br>`<Del>` $\to$ `"_x` | 行内单字符删除与键盘 Delete 键 | 无论按 `x` 还是键盘 Delete 键均不污染剪贴板 |
| **可视选区 (Visual)** | 可视模式下的 `d` / `c` / `x` / `D` / `C` / `<Del>` | 鼠标或键盘选中文本后的任意删除/修改 | 选区内容直接蒸发，绝不反客为主覆盖系统剪贴板 |
| **选择模式 (Select)** | 针对可打印字符、退格与空格包装为 `<c-o>"_c` | LSP 补全、代码片段 Snippet 占位符高亮时直接打字替换 | 替换占位符参数时，旧参数不会被意外塞入剪贴板 |

#### B. 增加的专属剪切 (Dedicated Cut) 操作流

删除了传统 Vim 中“删除即剪切”的绑定后，若需要真正的剪切（Cut）移动代码，使用以下专属现代剪切流：

| 快捷键 | 生效模式 | 对应原生操作 | 产生效果 |
|---|---|---|---|
| **`m`** | 普通模式 (Normal) | `"+d` | **剪切操作符**：结合任意 motion/文本对象剪切至系统剪贴板（如 `mw` 剪切词、`mi"` 剪切引号内、`ma(` 剪切括号内） |
| **`mm`** | 普通模式 (Normal) | `"+dd` | **剪切整行**至系统剪贴板（等价于原本的剪切版 `dd`） |
| **`M`** | 普通模式 (Normal) | `"+D` | **剪切到行尾**至系统剪贴板（等价于原本的剪切版 `D`） |
| **`<C-x>` / `m`** | 可视模式 (Visual) | `"+d` | **剪切选区**至系统剪贴板 |
| **`<leader>m`** | 普通模式 (Normal) | `m` | **标记 (Mark)** 备用快捷键（保留 Vim 原生打标记功能） |

#### C. 彻底删除的项目

- **删除文件**：`config/nvim/lua/plugins/vim-cutlass.lua`（移除第三方 `svermeulen/vim-cutlass` 插件依赖）。
- **清理缓存**：通过 `Lazy! clean` 彻底清除插件下载缓存与加载痕迹。

### 6.3 最佳操作习惯总结

- **想纯删除/修改**：像往常一样大胆使用 `d`、`dd`、`dw`、`ci"`、`cw`、`x`，无论何时都不会损坏外部剪贴板。
- **想复制**：继续使用 `y`、`yy`、`yi"` 或可视模式 `<C-c>`。
- **想剪切**：普通模式用 `m`（`mw`、`mm`、`M`），可视模式用 `<C-x>` 或 `m`。
- **想粘贴**：普通模式按 `p`，插入模式按 `<C-v>`，可视模式按 `p` 或 `<C-v>` 覆盖替换。
