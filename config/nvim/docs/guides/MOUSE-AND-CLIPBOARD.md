# Neovim 鼠标与剪贴板

这份说明按当前公开配置和可选私有 `smart-paste.nvim` 集成整理。`<leader>` 默认为空格。

## 鼠标选择

- `mouse=a` 开启 Neovim 的鼠标支持，可在窗口中定位和拖选。
- Visual/Select 选区释放鼠标时，`<LeftRelease>` 会把选区复制到系统剪贴板并重新显示选区。
- 双击的自定义处理只检查鼠标所在位置是不是 `#RGB` 或 `#RRGGBB`。命中颜色值时打开 ccc 取色器；其他位置只移动光标，不会由本配置执行“选中单词”。

## 常用键位

| 操作 | 键位 | 行为 |
|---|---|---|
| 全选文件 | `<C-a>` | Normal/Visual 进入全文件选区；Insert 先离开插入模式再全选 |
| 复制选区 | Visual `<C-c>` | 复制到系统剪贴板 |
| 剪切选区 | Visual `<C-x>` 或 `m` | 写入系统剪贴板并删除选区 |
| 智能粘贴系统剪贴板 | Normal `<C-v>` / `<leader>p`，Insert `<C-v>`，Visual `<C-v>` | 私有 `smart-paste.nvim` 提供；多行内容按目标缩进调整 |
| 普通 yank/put | `y`、`p`、`P`、`gp`、`gP` | 由 Yanky 增强；`[p`/`]p` 切换粘贴历史，`<leader>fy` 浏览历史 |
| 纯删除/修改 | `d`、`c`、`x` 等 | 写入黑洞寄存器，不覆盖系统剪贴板 |
| 专用剪切 | Normal `m` + motion、`mm`、`M`；Visual `m`/`<C-x>` | 剪切到系统剪贴板；原生 mark 改用 `<leader>m` |

私有 `smart-paste.nvim` 不存在时，系统剪贴板的多行智能缩进映射不可用；公开配置仍通过 Neovim 的 `+` 寄存器和系统剪贴板适配器工作。

## 跨平台剪贴板适配

配置设置 `clipboard=unnamedplus`，并按可用环境选择剪贴板后端，顺序为：

1. Wayland：`wl-copy` / `wl-paste`
2. macOS：`pbcopy`
3. Windows/WSL：`win32yank.exe`
4. X11：`xclip`
5. tmux：`tmux`
6. 以上皆不可用时：终端 OSC 52

选择的外部工具需要在 `PATH` 中可执行。远程终端是否支持 OSC 52 也取决于终端模拟器设置。

## 配置位置

- 鼠标、全局剪贴板选项与双击颜色检测：[`lua/config/keymaps.lua`](../../lua/config/keymaps.lua)、[`lua/config/options.lua`](../../lua/config/options.lua)
- yank/put 历史：[`lua/plugins/yanky-substitute.lua`](../../lua/plugins/yanky-substitute.lua)
- 私有智能粘贴：`~/chezmoi/dot_config/nvim-private/lua/plugins/smart-paste.lua`
