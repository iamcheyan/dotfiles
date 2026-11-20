# find / grep 兼容 wrapper

本目录提供两个 shell wrapper，目标是让 **`find` / `grep` 始终作为用户接口**：

- 本机：继续输入熟悉的 `find` / `grep`，简单调用由 `fd` / `rg` 加速。
- 远程 Linux：SSH 不会把本机 alias 传过去，仍然直接使用服务器上的原生 `find` / `grep`。
- 日常使用不需要记忆 `fd` / `rg` 参数；它们只是本机 wrapper 的实现后端。

- `find.sh`：优先使用 `fd`，否则调用系统 `find`
- `grep.sh`：优先使用 `rg`，否则调用系统 `grep`

`~/dotfiles/aliases.conf` 中的 `find`、`grep` alias 指向这两个脚本，因此打开新的 zsh 后，原来的命令写法仍然可用。

## 设计原则

1. **用户接口固定**：只面向传统 `find` / `grep` 语法，不把 `fd` / `rg` 参数暴露给用户。
2. **兼容优先**：无法可靠转换的参数不猜测，直接交给原生工具。
3. **新工具可选**：没有 `fd` / `rg` 时不报错、不要求安装，自动回退。
4. **旧参数尽量保留**：常用的路径、通配名、类型、深度和递归搜索参数被转换。
5. **默认不漏隐藏/忽略文件**：wrapper 调用 `fd` / `rg` 时启用 `--hidden --no-ignore`，更接近 `find` 与递归 `grep` 的传统行为。
6. **脚本内部绕过 alias**：wrapper 使用已解析的系统命令路径，避免递归调用自身。

## 本机与远程的使用方式

本机 shell 中，alias 只改变实现，不改变你的命令习惯：

```text
find / grep
    ↓
wrapper
    ├─ 可安全转换的常见参数 → fd / rg
    └─ 复杂或有语义差异的参数 → 原生 find / grep
```

通过 SSH 执行时，本机 alias 不会进入远程 shell：

```bash
ssh server 'find /var/log -type f -name "*.log"'
ssh server 'grep -rni "error" /var/log'
```

这两条命令使用的是远程服务器自己的 `find` / `grep`，因此本地和远程可以保持同一套使用习惯。

## 与其他命令组合

wrapper 的目标是保持传统命令的输入和常见输出形式，因此普通管道可以继续照常使用：

```bash
find . -type f -name '*.log' | grep -i error | sort
find . -type f -print0 | xargs -0 grep -n TODO
grep -rni error . | awk -F: '{print $1}'
find . -type f | sort | uniq
```

这些命令在本机交互式 shell 中通常会形成：

```text
find wrapper → fd（可安全转换时）
grep wrapper → rg（可安全转换时）
sort/awk/xargs/uniq → 系统命令
```

`-print0` 和 `xargs -0` 可以继续配合使用，适合处理包含空格或换行的文件名。

### 会自动回退的组合

复杂表达式不会被强行转换。例如：

```bash
find . -type f -exec grep -n TODO {} \;
grep -P 'pattern' file
grep -Rni 'pattern' .
```

`find -exec` 会让 `find` wrapper 使用原生 `find`；`-exec` 中的 `grep` 也由子进程直接执行，通常是原生 `grep`。`grep -P`、`grep -R` 等参数同样会回退到系统 grep。

### 不是完全的字节级替代

普通文本管道通常兼容，但 `fd` / `rg` 与系统 `find` / `grep` 在边缘情况下仍可能有差异：

- 二进制文件的提示文字；
- 多文件搜索时的文件名前缀或输出格式；
- 颜色、编码和特殊字符处理；
- 某些命令的错误信息和退出状态细节。

因此，接着 `awk`、`sed` 等工具做严格文本解析时，普通文本场景可以直接使用；如果脚本依赖精确输出，建议显式使用 `native-find` / `native-grep`。

### 交互式 shell 与脚本的区别

alias 主要服务于交互式 zsh：

```bash
find . -type f | grep TODO
```

脚本通常不会自动加载交互式 alias，因此脚本里的 `find` / `grep` 默认仍然是系统原生命令。这可以避免脚本意外依赖个人配置，也更接近远程服务器的执行环境。

## find.sh

### 可转换到 fd 的参数

```text
find [PATH...] -name PATTERN
find [PATH...] -iname PATTERN
find [PATH...] -type f|d|l|b|c|s|p
find [PATH...] -maxdepth N
find [PATH...] -mindepth N
find [PATH...] -print
find [PATH...] -print0
```

示例：

```bash
find . -type f -name '*.ts'
find ~/development -type d -iname '*research*' -maxdepth 3
find . -name '*.json' -print0 | xargs -0 printf '%s\n'
```

### 自动回退的参数

包含以下表达式时，为避免结果语义变化，直接使用系统 `find`：

- `-exec` / `-execdir` / `-delete`
- `-prune`、`-o`、`!` 等复杂表达式
- `-size`、`-mtime`、`-newer`、`-user`、`-perm`
- `-printf`、`-ls`
- `-L`、`-H`、`-xdev`、`-mount`
- 未知选项或多个 `-name` 条件

回退仍然保留用户传入的全部原始参数：

```bash
find . -type f -name '*.log' -exec gzip {} \;
```

## grep.sh

### 可转换到 rg 的参数

支持常用 grep 选项及其组合：

- 搜索方式：`-r`、`-F`；`-R` 保留给原生 grep
- 匹配：`-i`、`-v`、`-w`、`-x`、`-e`
- 输出：`-n`、`-H`、`-h`、`-o`、`-c`、`-l`、`-L`、`-q`、`-s`、`-b`、`-I`
- 上下文：`-A`、`-B`、`-C`
- 限制：`-m`
- 文件过滤：`--include`、`--exclude`、`--exclude-dir`
- 其他：`-Z` / `--null`、`--color`

示例：

```bash
grep -rni --include='*.ts' 'TODO' .
grep -rIl --exclude-dir=node_modules '旧 API' ~/development
grep -F -n 'literal [text]' README.md
printf '%s\n' "$text" | grep -i 'warning'
```

递归模式下 wrapper 会让 `rg` 同时搜索隐藏文件和被 ignore 的文件。
`-R` 会回退到原生 grep，因为 BSD grep、GNU grep 和 rg 对目录符号链接的处理不同。
如果希望本机使用 `rg` 加速递归搜索，使用传统的 `grep -r` 参数即可：

```bash
rg --hidden --no-ignore PATTERN PATH
```

上面的 `rg` 仅用于说明 wrapper 的内部实现，不是需要记忆的新用法。

### 自动回退的参数

遇到 Perl 正则、设备/目录处理、外部 pattern 文件或未知选项时，直接调用系统 `grep`，不改变原始参数：

- `-P` / `--perl-regexp`
- `-E` / `-G`（grep 的 BRE/ERE 与 rg 的正则语法不完全相同）
- `-R`（保留当前系统 grep 的符号链接语义）
- `-D`、`-d`、`--devices`、`--directories`
- `--binary-files`、`--label`、`--file`、`--exclude-from`
- 未知短选项或不完整选项

此外，非递归 grep 如果目标参数是目录，也会回退，避免把传统的目录错误误变成 `rg` 的递归搜索。

## Alias 与使用方式

源文件：

```text
~/dotfiles/tools/find.sh
~/dotfiles/tools/grep.sh
~/dotfiles/tools/README-find-grep.md
~/dotfiles/aliases.conf
```

部署后：

```text
~/dotfiles/tools/find.sh
~/dotfiles/tools/grep.sh
~/dotfiles/tools/README-find-grep.md
```

重新打开 zsh 后即可继续使用：

```bash
find . -name '*.md'
grep -rni '关键词' .
```

查看实际使用的是 wrapper：

```bash
type -a find grep
```

查看本机加速后端是否可用：

```bash
command -v fd
command -v rg
```

如果需要强制使用原生命令，在 zsh 中使用：

```bash
native-find ...
native-grep ...
```

`native-find` 和 `native-grep` 会绕过 wrapper，直接调用系统命令；需要临时使用
原生命令时不必改变当前 alias 配置。
