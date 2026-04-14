# Git 工作流增强

当前 dotfiles 已把 `delta` 和 `gitui` 接入 Zsh 工作流。

## 包含内容

- `delta`: 作为 Git diff / log / show 的高亮分页器
- `gitui`: 作为终端内的 Git TUI
- Zsh 快捷入口:
  - `g:ui`: 直接打开 `gitui`
  - `git:ui`: `gitui` 的函数入口
  - `git:delta:init`: 一次性写入全局 Git 的 `delta` 配置
  - `git:diff`: 用 `delta` 查看 `git diff`
  - `git:diff:staged`: 用 `delta` 查看暂存区 diff
  - `git:log:patch`: 用 `delta` 查看补丁式日志

## 安装来源

- `delta` 通过 [dandavison/delta](https://github.com/dandavison/delta) 的 GitHub Releases 由 Zinit 安装
- `gitui` 通过 [gitui-org/gitui](https://github.com/gitui-org/gitui) 的 GitHub Releases 由 Zinit 安装

相关配置文件:

- [plugins/tools/tools.zsh]($HOME/.dotfiles/plugins/tools/tools.zsh)
- [aliases.conf]($HOME/.dotfiles/aliases.conf)

## 首次启用

重载 shell 让 Zinit 拉起新工具:

```zsh
source ~/.dotfiles/zshrc
```

如果你想让 Git 全局默认使用 `delta`，执行一次:

```zsh
git:delta:init
```

这会写入这些全局配置:

```gitconfig
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    side-by-side = true
    line-numbers = true

[merge]
    conflictStyle = zdiff3
```

## 日常用法

```zsh
g:ui
git:diff
git:diff:staged
git:log:patch --stat
```

常见工作流:

1. 用 `g:s` 看改动摘要
2. 用 `git:diff` 或 `git:diff:staged` 看高亮 diff
3. 用 `g:ui` 进入交互式暂存、提交、切分 hunk、切分 line

## 说明

- `git:diff*` / `git:log:patch` 即使还没执行 `git:delta:init`，也会优先尝试用 `delta`
- `git:delta:init` 只在你明确执行时才会改全局 Git 配置，不会在 shell 启动时自动写入
- `gitui` 适合做交互式 stage / commit / stash / branch 操作，`delta` 更适合审阅 diff 和 patch

## 参考

- [gitui-org/gitui](https://github.com/gitui-org/gitui)
- [dandavison/delta](https://github.com/dandavison/delta)
