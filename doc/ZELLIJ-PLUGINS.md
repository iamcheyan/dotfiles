# Zellij 插件说明

这份文档只保留你最终决定继续使用的插件。

保留列表：

- `fzf-zellij`
- `zellij-pane-picker`
- `zellij-newtab-plus`
- `zellij-sessionizer`
- `zj-quit`
- `zellij-notepad`
- `zellij-attention`
- `zjstatus`
- `zjstatus-hints`

说明：

- `zellij-sessionizer` 依赖 `zellij-switch.wasm`
- `zjstatus-hints` 依赖 `zjstatus`

## 当前快捷键

- `Alt+w`：打开 `zellij-pane-picker`
- `Alt+t`：打开 `zellij-newtab-plus`
- `Alt+Shift+s`：运行 `zellij-sessionizer`
- `Alt+q`：打开 `zj-quit`
- `Alt+f`：切换 `zellij-notepad`

后台常驻：

- `zellij-attention`

状态栏候选：

- `zjstatus`
- `zjstatus-hints`

## 首次授权

下面这些插件第一次打开时可能会弹权限确认：

- `zellij-pane-picker`
- `zellij-newtab-plus`
- `zjstatus`
- `zjstatus-hints`

如果打开后像“没反应”：

- 先把焦点切到插件 pane
- 按 `y` 授权

## 插件说明

### fzf-zellij

作用：

- 让 `fzf` 在 Zellij 中自动用浮动窗打开

当前行为：

- 在 Zellij 里执行 `fzf`：自动走浮动窗
- 在 Zellij 外执行 `fzf`：保持原始行为

直接示例：

```bash
fzf-zellij
FZF_ZELLIJ_HEIGHT=80% FZF_ZELLIJ_WIDTH=90% fzf-zellij
```

适合场景：

- 你已经大量使用 `fzf`
- 但不想每次都把当前 pane 挤乱

### zellij-pane-picker

作用：

- 搜索 pane
- 给 pane 打星
- 在 pane 之间快速跳转

打开方式：

- `Alt+w`

使用示例：

- 按 `Alt+w`
- 输入关键字过滤 pane
- 按 `Space` 给某个 pane 打星
- 按 `Enter` 跳转

适合场景：

- 你常常在多个 pane 之间切来切去
- 而且希望把几个关键 pane 固定收藏起来

### zellij-newtab-plus

作用：

- 创建新 tab 时先输入名字
- 可以结合 `zoxide` 直接选择目录

打开方式：

- `Alt+t`

使用示例：

- 按 `Alt+t`
- 输入 tab 名，比如 `notes`
- 选择目录
- 按 `Enter`

当前配置：

- `use_zoxide true`

适合场景：

- 你经常新建 tab
- 而且希望 tab 名称和目录一步到位

### zellij-sessionizer

作用：

- 按项目目录搜索并切换整个 Zellij session

打开方式：

- `Alt+Shift+s`

安装位置：

- `~/.local/bin/zellij-sessionizer`

依赖：

- `~/.config/zellij/plugins/zellij-switch.wasm`

使用示例：

- 按 `Alt+Shift+s`
- 选择一个项目目录，比如 `~/dotfiles`
- 自动创建或切换到同名 session

默认搜索路径：

- `~/Projects`
- `~/Code`
- `~/dotfiles`
- `~/dotfiles/.config/nvim`

适合场景：

- 你按项目维度切换 session

### zj-quit

作用：

- 退出当前 session 前先确认

打开方式：

- `Alt+q`

使用示例：

- 按 `Alt+q`
- 按 `q` 确认退出
- 按 `Esc` 取消

注意：

- `Ctrl+q` 仍然是直接退出
- `Alt+q` 是安全退出入口

### zellij-notepad

作用：

- 在 Zellij 里弹出一个浮动笔记

打开方式：

- `Alt+f`

使用示例：

- 按 `Alt+f`
- 写一些临时记录
- 关闭编辑器

再次按 `Alt+f` 会在“显示 / 聚焦 / 隐藏”之间切换，这是插件自己的 toggle 行为。

笔记保存位置：

- `~/.config/zellij/notes/`

### zellij-attention

作用：

- 在 tab 名字上标记“等待处理”或“已完成”

它是后台插件，没有专门的弹窗快捷键。

使用示例：

```bash
zellij pipe --name "zellij-attention::waiting::$ZELLIJ_PANE_ID"
zellij pipe --name "zellij-attention::completed::$ZELLIJ_PANE_ID"
```

含义：

- `waiting`：当前 pane 需要你回来处理
- `completed`：任务结束

### zjstatus

作用：

- 高度可定制的状态栏

试用步骤：

先做首次授权：

```bash
zellij -l zjstatus-setup
```

聚焦状态栏插件 pane 后按 `y` 授权。

授权完成后，再用正式试用布局：

```bash
zellij -l compact-zjstatus
```

适合场景：

- 你想要比内置状态栏更强的自定义能力

### zjstatus-hints

作用：

- 给 `zjstatus` 增加当前 mode 的快捷键提示

注意：

- 它依赖 `zjstatus`
- 不适合单独启用

当前状态：

- 已安装
- 已在后台默认加载
- `compact-zjstatus` / `zjstatus-setup` 已经接好了 `{pipe_zjstatus_hints}`

## 推荐试用顺序

建议你按这个顺序感受：

1. `Alt+w` 试 `zellij-pane-picker`
2. `Alt+t` 试 `zellij-newtab-plus`
3. `Alt+Shift+s` 试 `zellij-sessionizer`
4. `Alt+q` 试 `zj-quit`
5. `Alt+Shift+n` 试 `zellij-notepad`
6. `zellij -l zjstatus-setup` 完成首次授权
7. `zellij -l compact-zjstatus` 正式试 `zjstatus`
8. 看看 `zjstatus-hints` 的提示信息是否对你有价值

## 重载方式

修改完成后：

- 重启当前 Zellij
- 或重新开一个 session

如果还想让 shell 侧包装立即生效：

```bash
source ~/.zshrc
```
