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

<!-- lang:en -->

> Summary: What you need to know to maintain this configuration: who owns which layer, how to update, and how to verify.

# Reading Guide for This Chapter

## The Three Configuration Layers

```text
┌─────────────────────────────────────┐
│ 系统层（NixOS / nixos-config）          │
│   系统包、服务、硬件、用户组            │
├─────────────────────────────────────┤
│ 私有层（chezmoi）                       │
│   Agent、输入法、终端、密钥、机器专属   │
├─────────────────────────────────────┤
│ 公开层（本仓库）                        │
│   Zsh、CLI、应用配置、脚本              │
└─────────────────────────────────────┘
```

The same configuration is **owned by only one repository** and is never copied across layers.

## What This Chapter Covers

| Document | What it answers |
|---|---|
| [Repository Boundaries](boundaries.html) | What belongs here and what does not |
| [Update Process](update.html) | git pull, submodules, Neovim upgrades |
| [Checks and Tests](checks.html) | How to verify after making changes |
| [Private Overrides](local.html) | local/ and the aliases sub-repository |
| [Building This Site](site.html) | How this site is generated and published |

## The Maintainer's Daily Routine

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

The Neovim configuration is maintained in a separate repository; dotfiles only updates the submodule pointer.

## The Ordinary User's Daily Routine

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
bash dotlink/dotlink link
exec zsh
```

When you do not need to change configuration, this is all there is.

<!-- lang:ja -->

> 要約：この設定を維持するために知っておくべきこと：誰がどの層を所有するか、どう更新するか、どう検証するか。

# 本章のガイド

## 3 層の設定

```text
┌─────────────────────────────────────┐
│ 系统层（NixOS / nixos-config）          │
│   系统包、服务、硬件、用户组            │
├─────────────────────────────────────┤
│ 私有层（chezmoi）                       │
│   Agent、输入法、终端、密钥、机器专属   │
├─────────────────────────────────────┤
│ 公开层（本仓库）                        │
│   Zsh、CLI、应用配置、脚本              │
└─────────────────────────────────────┘
```

同じ設定は**1 つのリポジトリだけが所有**し、層をまたいでコピーしません。

## 本章の内容

| ドキュメント | 回答すること |
|---|---|
| [リポジトリの境界](boundaries.html) | 何をここに置くべきか、何を置くべきでないか |
| [更新手順](update.html) | git pull、サブモジュール、Neovim のアップグレード |
| [チェックとテスト](checks.html) | 変更後にどう検証するか |
| [プライベートな上書き](local.html) | local/ と aliases サブリポジトリ |
| [本サイトのビルド](site.html) | このサイトの生成と公開の仕組み |

## メンテナーの日常

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

Neovim の設定は独立したリポジトリで管理されており、dotfiles はサブモジュールのポインタを更新するだけです。

## 一般ユーザーの日常

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
bash dotlink/dotlink link
exec zsh
```

設定を変更する必要がなければ、これですべてです。
