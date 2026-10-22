> 摘要：Pet 管理命令片段，用 Ctrl+X Ctrl+R 把选中片段填进命令行。

# Pet

## 用途

Pet 是一个命令片段库：把常用命令存起来，用的时候搜索、选中、填入命令行。它和 shell 别名不同——别名是固定的，片段可以带占位符。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| shell 集成 | `plugins/zsh-plugins.zsh` |
| 片段文件 | 默认 `~/.config/pet/snippet.toml` |

```zsh
zi_cmd knqyf263/pet pet
```

## shell 集成

```zsh
if command -v pet >/dev/null 2>&1; then
    function pet-select() {
      BUFFER="$(pet search --query "$LBUFFER")"
      CURSOR=$#BUFFER
      zle redisplay
    }
    zle -N pet-select
    bindkey '^X^R' pet-select
fi
```

`BUFFER` 是 Zsh 的行编辑缓冲区，`LBUFFER` 是光标左侧部分。这个函数：

1. 用当前已输入的内容作为初始查询
2. 调 `pet search`，选中后返回命令文本
3. 把结果写回 `BUFFER`
4. 光标移到末尾

所以你可以先打 `docker`，按 `Ctrl+X` `Ctrl+R`，它就从含 `docker` 的片段里筛。

## 基本用法

```bash
pet new                # 新建片段
pet search             # 搜索
pet search --query git # 带初始查询
pet list               # 列出全部
pet edit               # 编辑片段文件
pet exec               # 选中并直接执行
pet clip               # 选中并复制到剪贴板
pet configure          # 打开配置文件
pet sync               # 同步（需配置）
```

## 新建片段

```bash
pet new
```

交互式提问：

```text
Command> git log --oneline -20
Description> 最近 20 条提交
Tag> git
```

保存后可以用 `pet search` 搜到。

## 片段文件格式

`~/.config/pet/snippet.toml`：

```toml
[[snippets]]
  command = "git log --oneline -20"
  description = "最近 20 条提交"
  output = ""

[[snippets]]
  command = "kubectl get pods -n {{namespace}}"
  description = "列出指定 namespace 的 pod"
  output = ""

[[snippets]]
  command = "ssh {{host}}"
  description = "连接服务器"
  tag = ["ssh", "remote"]
```

`{{placeholder}}` 是占位符，选中后 Pet 会提示你填写。

## 快捷键

| 键 | 作用 |
|---|---|
| `Ctrl+X` 然后 `Ctrl+R` | 在命令行里搜索片段 |
| `Ctrl+X` 然后 `Ctrl+S` | 直接执行选中片段（部分版本） |

本仓库只绑定了 `Ctrl+X` `Ctrl+R`，不占用 Atuin 的上箭头。

## 与其他工具的对比

| | Pet | navi | 别名 |
|---|---|---|---|
| 存储 | TOML 文件 | .cheat 文件 | shell 配置 |
| 占位符 | `{{name}}` | `<name>` | 无 |
| 交互 | fzf | 自己的界面 | 无 |
| 同步 | 支持 Gist/GitLab | repo 机制 | 靠 dotfiles |
| 适合 | 短命令 | 带参数的命令 | 固定命令 |

Pet 比别名灵活（有占位符），比 navi 轻量（不需要 cheatsheet 语法）。

## 同步

```bash
pet sync
```

需要在 `~/.config/pet/config.toml` 里配置 Gist 或 GitLab Snippets：

```toml
[General]
  snippetfile = "~/.config/pet/snippet.toml"

[Gist]
  file_name = "pet-snippet.toml"
  access_token = "..."

[GitLab]
  file_name = "pet-snippet.toml"
  access_token = "..."
```

**access_token 不要提交到公开仓库。** 本仓库不提供这个配置文件。

## 排错

**`Ctrl+X Ctrl+R` 没反应**：`zsh_plugins_load_shell_tools` 没执行，或 pet 没装。`type pet-select` 确认函数存在。

**片段文件损坏**：`pet list` 会报 TOML 解析错误。用 `pet edit` 修复或从备份恢复。

**占位符不提示**：`pet search` 才有填参流程，`pet exec` 会跳过。确认用的是 search。

**中文描述乱码**：文件编码问题。确认是 UTF-8。

**同步冲突**：多机同时改会冲突。`pet sync` 前先 `pet edit` 检查本地版本。
