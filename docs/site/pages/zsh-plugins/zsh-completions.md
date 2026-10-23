> 摘要：zsh-completions 提供额外的命令补全定义，必须在 compinit 之前加载。

# zsh-completions

## 用途

Zsh 自带一部分命令补全，但覆盖不全。`zsh-users/zsh-completions` 收集社区维护的补全定义，补充 Docker、kubectl、git 扩展、各类 CLI 的补全。

它只提供**定义文件**，不改变补全的显示方式。显示层由 fzf-tab 负责。

## 加载方式

```zsh
zsh_plugins_load_pre_compinit() {
  zinit ice blockf
  zinit light zsh-users/zsh-completions
}
```

`blockf` 是这里的关键参数。

## blockf 是什么

默认情况下，Zinit 会把插件的目录加进 `$fpath`。对于补全插件，这会带来问题：`$fpath` 里多出一个没有 `_` 前缀文件的目录，`compinit` 可能报错或产生警告。

`blockf` 阻止这个行为。插件自己的 `zsh-completions.plugin.zsh` 会用 `fpath+=` 把正确的子目录加进去，不需要 Zinit 代劳。

## 为什么必须在 compinit 之前

Zsh 的补全系统是这样工作的：

```text
compinit
  ├── 扫描 $fpath 里所有以 _ 开头的文件
  ├── 读取每个文件的 #compdef 声明
  └── 生成 ~/.zcompdump 缓存

之后加载的补全定义 → 不会自动进入缓存 → 需要 rehash 或重启
```

所以补全定义必须**先**进 `$fpath`，**再**运行 `compinit`。

本仓库的顺序：

```zsh
zsh_plugins_load_pre_compinit   # ← zsh-completions 进 fpath
source plugins/completion/completion.zsh   # ← compinit
zsh_plugins_load_post_compinit  # ← fzf-tab
```

## 能补全什么

取决于插件目录里有哪些 `_` 文件。常见的：

| 命令 | 补全内容 |
|---|---|
| `docker` | 子命令、容器名、镜像名 |
| `docker compose` | 服务名、配置项 |
| `kubectl` | 资源类型、namespace、pod 名 |
| `git` | 部分子命令的扩展参数 |
| `npm` / `yarn` | script 名、包名 |
| `systemctl` | 单元名 |
| `gh` | 子命令与参数 |

具体清单：

```bash
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | head -40
```

## 验证是否生效

```bash
# 看 fpath 里有没有补全目录
print -l $fpath | grep -i completions

# 看某个命令有没有补全函数
which _docker

# 看补全定义文件数量
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | wc -l
```

`which _docker` 有输出说明补全函数已加载。

## 与 fzf-tab 的关系

| | zsh-completions | fzf-tab |
|---|---|---|
| 提供什么 | 补全的**内容** | 补全的**界面** |
| 时机 | compinit 前 | compinit 后 |
| 没有它会怎样 | 候选里缺少子命令 | 候选以原生菜单显示 |

两者互补，缺一不可。

## 排错

**某个命令没有补全**：先确认插件里有对应文件：

```bash
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | grep -i docker
```

有文件但补全不生效，多半是 `zcompdump` 过期：

```bash
rm -f ~/.zcompdump*
exec zsh
```

**`compinit: insecure directories` 警告**：`$fpath` 里某个目录的权限不对（组或其他用户可写）。按提示 `chmod` 修正。

**补全候选为空**：`compinit` 根本没运行。检查 `plugins/completion/completion.zsh` 是否被 source。

**新装的 CLI 没有补全**：有些工具自己提供补全（比如 `gh completion -s zsh`），需要单独生成，不在这个插件里。
