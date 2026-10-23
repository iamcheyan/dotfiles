> 摘要：dotlink 实际部署了哪些配置，哪些在仓库里但不会自动链接。

# 本章导读

> **主题规范：** 本仓库终端配色统一遵循 [Neovim Blue / Nostalgia 标准](theme-standard.html)。新增或修改工具主题时，按该页的颜色角色和对比要求执行。

## 两类配置

| 类别 | 是否自动部署 |
|---|---|
| 列入 `dotlink/dotlinkrc` 的 | 是，`dotlink link` 时建立软链接 |
| 在 `config/` 但未列入的 | 否，需要手动链接 |

这个区别很重要：看到 `config/ghostty/config` 存在，不代表安装后 Ghostty 就用上了它。

## 阅读顺序

1. [映射清单](mapping.html) — 先看哪些配置真的会生效。
2. 然后按需跳转：Starship、tmux、Ranger、Vifm、Vim、Ghostty。
3. [Neovim 子模块](nvim.html) — 编辑器部分指向独立站点。

## 配置文件的共同特点

本仓库的配置遵循几条规则：

| 规则 | 体现 |
|---|---|
| 不写死个人路径 | 用 `$HOME`、相对路径、运行时推导 |
| 可选依赖先探测 | `command -v` 判断，缺失时降级 |
| 私有内容外部引入 | tmux 的 `private.conf`、`local/` 目录 |
| 单一职责 | 一个文件管一个程序 |

## 修改配置的流程

```bash
# 1. 改源文件，不要改软链接目标
$EDITOR ~/dotfiles/config/tmux/tmux.conf

# 2. 验证
bash -n ~/dotfiles/zshrc          # 如果是 shell
tmux source-file ~/.config/tmux/tmux.conf   # 如果是 tmux

# 3. 提交
cd ~/dotfiles && git diff && git commit
```

改完通常不需要重跑 `dotlink`，因为软链接指向的就是源文件。只有新增/删除映射时才需要。
