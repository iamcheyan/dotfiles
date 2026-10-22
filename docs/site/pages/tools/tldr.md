> 摘要：tldr 提供命令的常用示例，比 man 更快找到「我想干什么」。

# tldr (tealdeer)

## 用途

`man` 给出完整参考，但往往几百行。`tldr` 给出 5–10 个最常见用法，按「我想做某事」组织。

本仓库装的是 **tealdeer**，一个 Rust 实现的 tldr 客户端，可执行名仍是 `tldr`。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，按 OS/CPU 选择 Release 包 |
| 实现 | tealdeer（Rust） |
| 可执行名 | `tldr` |

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
  local tldr_arch="aarch64"
  [[ "$(uname -m)" == "x86_64" ]] && tldr_arch="x86_64"
  zinit ice as"command" from"gh-r" bpick"tealdeer-macos-${tldr_arch}" mv"tealdeer* -> tldr" pick"tldr"
else
  local tldr_arch="x86_64"
  [[ "$(uname -m)" == "aarch64" ]] && tldr_arch="aarch64"
  zinit ice as"command" from"gh-r" bpick"tealdeer-linux-${tldr_arch}-musl" mv"tealdeer* -> tldr" pick"tldr"
fi
zinit light tealdeer-rs/tealdeer
```

`mv"tealdeer* -> tldr"` 把下载的二进制改名为 `tldr`，保持和标准客户端一致。

## 基本用法

```bash
tldr tar                    # tar 的常用示例
tldr git log                # 子命令
tldr -l                     # 列出缓存里所有页面
tldr -u                     # 更新缓存
```

## 常用参数

| 参数 | 作用 |
|---|---|
| `-u` / `--update` | 更新本地缓存 |
| `-l` / `--list` | 列出缓存中所有命令 |
| `-p` / `--platform` | 指定平台：`linux`、`macos`、`windows`、`common` |
| `-L` / `--language` | 指定语言 |
| `-r` / `--raw` | 显示原始 Markdown |
| `-f` / `--render` | 渲染指定本地 Markdown 文件 |
| `-c` / `--clear-cache` | 清空缓存 |
| `--pager` | 用 pager 分页 |
| `--color` | `always`/`auto`/`never` |
| `--show-paths` | 显示缓存文件路径 |
| `--seed-config` | 生成默认配置 |
| `--edit-page` | 编辑自定义页面 |

## 首次使用

首次运行会下载整个页面缓存（几 MB）。之后离线可用。

```bash
tldr --update
tldr tar
```

## 输出示例

```text
tar

Archiving utility.
Often combined with a compression method, such as gzip or bzip2.
More information: https://www.gnu.org/software/tar.

 - Create an archive from files:
   tar cf target.tar file1 file2 file3

 - Create a gzipped archive:
   tar czf target.tar.gz file1 file2 file3

 - Extract an archive in the current directory:
   tar xf source.tar[.gz|.bz2|.xz]
```

每条都是「描述 + 命令」，比 man 的纯参数列表更贴近实际使用。

## 平台覆盖

同一个命令在不同平台用法不同，tldr 会按平台选页面：

```bash
tldr -p linux ip
tldr -p macos ip
tldr -p common tar
```

`common` 是跨平台通用部分。默认按当前系统自动选。

## 自定义页面

```bash
tldr --edit-page mycommand
```

编辑一个本地页面，优先于在线缓存。适合给内部工具写速查。

## 与 man / --help 的分工

| | man | --help | tldr |
|---|---|---|---|
| 完整度 | 最全 | 参数列表 | 常用示例 |
| 速度 | 慢 | 快 | 快 |
| 适合 | 查冷门参数 | 确认参数拼写 | 学怎么用 |

日常顺序：`tldr` 看例子 → `--help` 查参数 → `man` 查细节。

## 排错

**`tldr: command not found`**：Zinit 未下载，或 `mv` 规则没生效。检查 `~/.zinit/plugins/tealdeer-rs---tealdeer/`。

**缓存为空**：首次要 `tldr --update`。

**某命令没有页面**：tldr 页面由社区维护，冷门命令可能缺失。用 `--help` 替代。

**页面过期**：`tldr --update` 刷新。

**中文页面**：`tldr -L zh` 可以，但覆盖不全，多数页面只有英文。
