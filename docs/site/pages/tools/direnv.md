> 摘要：direnv 按目录加载环境变量，进入项目自动生效，离开自动清理。

# direnv

## 用途

`direnv` 让环境变量跟着目录走。项目根目录放一个 `.envrc`，`cd` 进去时自动加载，离开时自动卸载。解决「不同项目需要不同 API key、不同 Python 虚拟环境、不同数据库地址」的问题。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载单个二进制 |
| 加载位置 | `plugins/tools/tools.zsh` |
| 可执行名 | `direnv` |

```zsh
zinit ice as"command" from"gh-r" sbin"direnv"
zinit light direnv/direnv
```

## shell 集成

```zsh
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
```

hook 注册了 `chpwd`，每次切换目录时检查当前路径及所有父目录里有没有已授权的 `.envrc`。

## 基本用法

```bash
cd ~/project
echo 'export DATABASE_URL=postgres://localhost/dev' > .envrc
direnv allow                 # 首次必须显式授权
```

之后每次进入该目录，`DATABASE_URL` 自动设置；离开后自动 unset。

## 子命令

| 命令 | 作用 |
|---|---|
| `direnv allow [path]` | 授权加载 |
| `direnv deny [path]` | 撤销授权 |
| `direnv edit [path]` | 编辑并自动授权 |
| `direnv reload` | 重新加载当前目录 |
| `direnv status` | 显示当前加载状态 |
| `direnv exec DIR CMD` | 在指定目录的环境里执行命令 |
| `direnv export SHELL` | 输出环境差异（调试用） |
| `direnv prune` | 清理过期的授权记录 |
| `direnv stdlib` | 显示可用的标准库函数 |

## 为什么必须 allow

`.envrc` 是**可执行的 shell 脚本**，能运行任意命令。如果自动加载，克隆一个恶意仓库就可能被执行代码。所以 direnv 要求你对每个文件内容做一次显式授权，并把文件哈希记在 `~/.local/share/direnv/allow/` 里。

`.envrc` 被修改后哈希失效，需要重新 `direnv allow`。这是安全设计，不是 bug。

## .envrc 里能写什么

`.envrc` 是 bash 语法，direnv 提供了标准库函数：

```bash
# 加载 .env 文件
dotenv

# 加载 .env 并允许缺失
dotenv_if_exists

# 使用 Python 虚拟环境
layout python3
layout python ~/.venv/myproject

# 使用 Node 版本
use node 20

# 使用 nix shell
use nix

# 添加 PATH
PATH_add bin

# 设置变量
export API_URL=https://api.example.com
```

`layout python3` 会自动创建/激活 `.direnv/python-3.x.x` 下的虚拟环境，并把 `VIRTUAL_ENV`、`PATH` 都设好。

## 实用模式

### 每个项目独立的 Python 环境

```bash
cd ~/projects/foo
echo 'layout python3' > .envrc
direnv allow
```

### 加载本地密钥（不提交）

```bash
# .envrc
dotenv_if_exists .env.local
```

`.env.local` 加进 `.gitignore`，`.envrc` 提交进仓库。这样别人克隆后只要建自己的 `.env.local`。

### 配合 fnm 固定 Node 版本

```bash
# .envrc
use node
```

它读 `.nvmrc` 或 `.node-version`。

## 与其它工具的关系

| 工具 | 分工 |
|---|---|
| fnm | 只管 Node 版本切换 |
| direnv | 管任意环境变量，也可以调用 fnm |
| Zsh 的 `export` | 全局生效，不随目录变化 |

两者可以叠加：direnv 在项目目录里设 `PATH`，fnm 的 `--use-on-cd` 也监听 `cd`。如果两者都改 Node 版本，行为取决于执行顺序，通常让 direnv 负责更可控。

## 排错

**进入目录没反应**：`.envrc` 没 allow。`direnv status` 会明确说「not allowed」。

**改了 .envrc 不生效**：哈希变了，重新 `direnv allow`。

**变量没清理**：离开目录后应该自动 unset。如果没清理，说明 hook 没注册，检查 `direnv hook zsh` 是否执行。

**`direnv: error .envrc is blocked`**：安全拦截，按提示 `direnv allow`。

**加载很慢**：`.envrc` 里有耗时命令（比如 `nix develop`）。考虑把结果缓存，或改用更轻的方案。

**和 tmux 会话冲突**：tmux 新建 pane 时继承的是创建时的环境，不会重新触发 direnv。在 pane 里手动 `direnv reload`。
