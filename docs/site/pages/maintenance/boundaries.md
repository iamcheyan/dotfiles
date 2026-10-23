> 摘要：公开层、系统层、私有层各自拥有什么，以及为什么不能跨层复制配置。

# 仓库边界

## 三层分工

### 系统层

由 NixOS 配置管理（`~/nixos-config`）：

| 内容 | 例子 |
|---|---|
| 系统包 | `zsh`、`tmux`、`ripgrep` |
| 服务 | Docker、SSH |
| 硬件 | 显卡驱动、内核模块 |
| 用户组 | `docker`、`video` |
| 字体 | 系统级安装 |

### 私有层

由 Chezmoi 管理（`~/chezmoi`）：

| 内容 | 例子 |
|---|---|
| AI Agent | provider 配置、quota |
| 输入法 | Fcitx5、Karabiner |
| 终端 | Kitty、Zellij |
| Shell 私有扩展 | `~/.config/aliases.conf` |
| 凭据 | API key、token、`.env` |
| 机器专属 | 私有服务器地址、专属脚本 |

### 公开层

本仓库：

| 内容 | 例子 |
|---|---|
| Zsh 通用配置 | `zshrc`、`aliases.conf` |
| CLI 工具配置 | Starship、Atuin、Ranger、Vifm |
| 编辑器 | Vim、GVim、Neovim 子模块 |
| 脚本 | `dotlink`、`init.sh`、安装器 |
| 文档 | `docs/`、本站源文件 |

## 判断标准

一个配置该放哪层，问三个问题：

| 问题 | 是 → | 否 ↓ |
|---|---|---|
| 需要 `sudo` 或改系统？ | 系统层 | 下一问 |
| 含凭据、私有地址、个人身份？ | 私有层 | 下一问 |
| 别人克隆后能直接用？ | 公开层 | 私有层 |

## 公开仓库不接受的

| 类型 | 例子 | 原因 |
|---|---|---|
| 密码、token | API key、SSH 私钥 | 泄露即失效 |
| 私有地址 | 内网 IP、私有域名 | 暴露基础设施 |
| 个人身份 | 真实姓名、邮箱 | 隐私 |
| 机器专属 | 特定路径、专属脚本 | 对他人无用 |
| Agent 配置 | provider、quota | 含凭据 |
| 大文件 | 字体二进制、模型 | 仓库膨胀 |

`.gitignore` 里有对应规则，但**不要只依赖它**——提交前自己确认。

## 跨层协作的正确方式

### 公开层引用私有层

`zshrc` 里：

```zsh
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
```

私有文件存在就加载，不存在就跳过。公开层不知道私有层的内容。

### tmux

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

同样的模式：检测文件存在再加载。

### local/ 目录

```zsh
for dotfiles_local_file in "$dotfiles_root"/local/*(N.D.); do
    [[ "${dotfiles_local_file:t}" == "README.md" ]] && continue
    source "$dotfiles_local_file"
done
```

用户自己的覆盖放 `local/`，Git 忽略除 README 外的所有文件。

## 反模式

**不要**在公开配置里加机器特判：

```zsh
# 错误示范
if [[ "$(hostname)" == "my-laptop" ]]; then
  export SPECIAL_VAR=1
fi
```

正确做法是放进私有层。

**不要**把私有内容复制进公开仓库再 gitignore：

```bash
# 错误示范
cp ~/.config/private.conf ./config/   # 然后加进 .gitignore
```

文件在仓库里就可能在某个时刻被提交。直接放私有层。

**不要**在两个仓库维护同一份配置：改一处忘另一处会导致行为不一致。

## 检查是否误提交

```bash
git log --all --full-history -- '*token*' '*secret*' '*.env'
```

如果发现敏感文件曾进过历史，需要重写历史（`git filter-repo`）并轮换凭据。**仅仅删除文件不够**，历史里还能查到。

## 仓库的提交检查

`.github/workflows/enforce-commit-identity.yml` 会检查提交身份是否符合要求。

`.githooks/lib/privacy-check.sh` 是本地钩子，用于扫描敏感内容。新克隆的仓库会从 `init.templateDir` 拿到钩子。

## 排错

**某个配置在另一台机器上行为不同**：可能依赖了私有层的内容。检查该配置是否有 `if [ -f ... ]` 的降级分支。

**提交被拒**：检查 commit 作者身份是否符合 workflow 要求。

**不确定该放哪**：默认放私有层。从私有移到公开容易，反向很难（历史已公开）。
