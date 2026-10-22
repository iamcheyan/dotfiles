> 摘要：navi 搜索 cheatsheet 并填写参数，把命令放回命令行再执行。

# navi

## 用途

`navi` 是一个交互式 cheatsheet 浏览器：你搜索「怎么解压 tar」，它列出相关命令，选中后按提示填参数，最后把命令送到命令行。

它解决的是「记不住语法但知道要干什么」的问题。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| shell 集成 | `plugins/zsh-plugins.zsh` 里的 `zsh_plugins_load_shell_tools` |
| cheatsheet 目录 | 默认 `~/.local/share/navi/cheats/` |

```zsh
zi_cmd denisidoro/navi navi
```

## shell 集成

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
```

有 `command -v` 判断，navi 没装时静默跳过，不影响 shell 启动。

## 基本用法

```bash
navi                    # 打开交互界面
navi --print            # 只打印命令，不执行
navi --query git        # 带初始查询
navi --tldr             # 用 tldr 页面作为数据源
navi fn widget::last_command   # 在 widget 里调用
```

## 交互界面

| 键 | 作用 |
|---|---|
| 输入 | 模糊搜索 |
| `↑` / `↓` | 移动 |
| `Enter` | 选中，进入参数填写 |
| `Ctrl+O` | 切换来源 |
| `Esc` | 退出 |

选中后会显示该条目需要的参数，逐个填写。填完后命令写入当前命令行（不是直接执行），可以先改再回车。

## cheatsheet 格式

`.cheat` 文件是纯文本：

```text
% git, branch

# 创建并切换到分支
 git switch -c <branch>

$ branch: git branch --format='%(refname:short)'
```

| 语法 | 含义 |
|---|---|
| `% 标签1, 标签2` | 分组标签 |
| `# 说明` | 注释 |
| 缩进的行 | 命令模板 |
| `<name>` | 待填参数 |
| `$ name: 命令` | 参数候选值来源 |

`$ branch: git branch ...` 会用该命令的输出作为候选，让你从现有分支里选，而不是手打。

## 仓库管理

```bash
navi repo add denisidoro/cheats     # 添加社区 cheatsheet 仓库
navi repo browse                    # 浏览可用仓库
navi repo browse --list             # 列出已添加的
```

首次使用时 navi 会提示导入 cheatsheet 仓库。

## 配置

```bash
navi info config-path     # 配置路径
```

默认在 `~/.config/navi/config.yaml`：

```yaml
cheats:
  paths:
    - ~/.local/share/navi/cheats
    - ~/dotfiles/cheats

style:
  tag:
    color: cyan
  comment:
    color: white
```

`cheats.paths` 可以指向多个目录，方便把项目自己的 cheatsheet 放进去。

## 与 tldr / --help 的分工

| | tldr | navi | --help |
|---|---|---|---|
| 内容 | 社区维护的常用示例 | 你自己的 cheatsheet | 完整参数 |
| 交互 | 只读 | 可搜索、可填参 | 只读 |
| 输出 | 显示 | 送到命令行 | 显示 |
| 适合 | 学新命令 | 记住自己的常用命令 | 查参数 |

三者的关系：tldr 学通用用法，navi 存自己的高频命令，`--help` 查细节。

## 实用场景

### 存自己的常用命令

```bash
mkdir -p ~/dotfiles/cheats
cat > ~/dotfiles/cheats/deploy.cheat <<'EOF'
% deploy, k8s

# 滚动更新 deployment
 kubectl rollout restart deployment/<name> -n <namespace>

$ name: kubectl get deploy -o name | cut -d/ -f2
$ namespace: kubectl get ns -o name | cut -d/ -f2
EOF
```

然后在 navi 里搜索 `rollout` 就能找到。

### 配合 fzf 直接用

```bash
navi --print | fzf
```

## 排错

**`navi: command not found`**：Zinit 未下载。`zinit list | grep navi` 确认。

**没有 widget**：`eval "$(navi widget zsh)"` 没执行。检查 `zsh_plugins_load_shell_tools` 是否被调用。

**cheatsheet 不显示**：确认路径在 `config.yaml` 的 `cheats.paths` 里。

**参数候选为空**：`$ name: 命令` 里的命令执行失败。先单独运行它确认。

**中文显示问题**：终端字体缺 CJK。
