> 摘要：tmux 的 7 个插件各自负责什么，怎么安装，读哪一篇。

# 本章导读

## 插件全景

`config/tmux/tmux.conf` 声明 7 项：1 个管理器 + 6 个功能插件。

| 插件 | 一句话 | 文档 |
|---|---|---|
| TPM | 插件管理器本体 | [TPM](tpm.html) |
| tmux-sensible | 补上公认合理的默认值 | [sensible](sensible.html) |
| tmux-persist | 手动保存 / 恢复会话 | [persist](persist.html) |
| tmux-continuum | 自动保存、自动恢复 | [continuum](continuum.html) |
| tmux-yank | 复制到系统剪贴板 | [yank](yank.html) |
| vim-tmux-navigator | `Ctrl+h/j/k/l` 跨 Neovim 与 pane | [vim-navigator](vim-navigator.html) |
| tmux-fzf | fzf 查找 session / window / pane | [tmux-fzf](tmux-fzf.html) |

## 安装路径

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

插件装在 `~/.config/tmux/plugins/`，不在默认的 `~/.tmux/plugins/`。用 `run-shell` 是为了让 shell 先展开 `$HOME`，避免 tmux 解析环境变量的差异。

## 首次安装

```bash
# 1. 确保 tmux 已启动
tmux

# 2. Prefix + I
```

`Prefix` 默认是 `Ctrl+B`。`Prefix + I`（大写 i）让 TPM 克隆所有 `@plugin` 声明的仓库。

状态栏会显示安装进度，完成后提示 `TMUX environment reloaded`。

## 本仓库的相关配置

| 配置项 | 值 | 作用 |
|---|---|---|
| `@persist-strategy-vim` | `session` | 保存时记录 vim 状态 |
| `@persist-strategy-nvim` | `session` | 保存时记录 nvim 状态 |
| `@persist-hook-post-restore-all` | 重编号命令 | 恢复后统一窗口编号 |

没有为 yank、fzf、continuum 设置额外选项，都用上游默认值。

## 更新与清理

| 键 | 作用 |
|---|---|
| `Prefix + I` | 安装 / 更新 |
| `Prefix + U` | 更新（部分版本） |
| `Prefix + Alt+u` | 卸载未在配置里声明的插件 |

具体见 [TPM](tpm.html)。

## 两个私有接入点

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}

if-shell '[ -f "$HOME/.config/tmux/private-after.conf" ]' \
  'source-file "$HOME/.config/tmux/private-after.conf"'
```

| 文件 | 时机 |
|---|---|
| `private.conf` | 插件声明之前，可覆盖前面的选项 |
| `private-after.conf` | 全部配置之后，可覆盖插件设置 |

文件不存在时静默跳过。这是公开配置不含私有内容、但允许本机追加的机制。

## 排错起点

插件没生效时按顺序查：

```bash
ls ~/.config/tmux/plugins/          # 目录有没有
tmux show -g @plugin                # 声明有没有
echo $TMUX_PLUGIN_MANAGER_PATH      # 路径对不对（在 tmux 里执行）
```
