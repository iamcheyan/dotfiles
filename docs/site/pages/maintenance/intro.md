> 摘要：维护这套配置需要知道的事：谁拥有哪一层、怎么更新、怎么验证。

# 本章导读

## 三层配置

```text
┌─────────────────────────────────────────┐
│ 系统层（NixOS / nixos-config）          │
│   系统包、服务、硬件、用户组            │
├─────────────────────────────────────────┤
│ 私有层（chezmoi）                       │
│   Agent、输入法、终端、密钥、机器专属   │
├─────────────────────────────────────────┤
│ 公开层（本仓库）                        │
│   Zsh、CLI、应用配置、脚本              │
└─────────────────────────────────────────┘
```

同一份配置**只在一个仓库拥有**，不跨层复制。

## 本章内容

| 文档 | 回答什么 |
|---|---|
| [仓库边界](boundaries.html) | 什么该放这里，什么不该 |
| [更新流程](update.html) | git pull、子模块、Neovim 升级 |
| [检查与测试](checks.html) | 改完怎么验证 |
| [私人覆盖](local.html) | local/ 与 aliases 子仓库 |
| [本站构建](site.html) | 这个网站怎么生成和发布 |

## 维护者的日常

```bash
# 改配置
cd ~/dotfiles
$EDITOR zshrc

# 验证
zsh -d -n zshrc
git diff --check

# 提交
git add zshrc && git commit -m "..." && git push
```

Neovim 配置在独立仓库维护，dotfiles 只更新子模块指针。

## 普通用户的日常

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
bash dotlink/dotlink link
exec zsh
```

不需要改配置时，这就是全部。
