> 摘要：Fresh 是终端文本编辑器，本仓库用 fr 别名启动，init.sh 按平台安装。

# Fresh

## 用途

Fresh 是一个终端里的文本编辑器，特点是有多光标、内置插件系统和 TS 配置。它和 Neovim 定位重叠，但交互更接近现代编辑器。

本仓库把它作为可选编辑器：`init.sh` 按平台安装，`aliases.conf` 提供 `fr` 别名。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | init.sh 的 `install_fresh` 步骤 |
| Linux/WSL | 官方 universal installer |
| macOS | Homebrew |
| Windows | winget |
| NixOS | 由系统配置的 `fresh-editor` 包管理 |

```zsh
alias fr="fresh"
```

## 基本用法

```bash
fr                    # 打开空缓冲区
fr file.txt           # 打开文件
fr file.txt:42        # 跳到第 42 行
fr file.txt:42:8      # 跳到第 42 行第 8 列
fr .                  # 打开目录
```

位置参数支持 `文件:行:列` 语法，方便从编译器错误输出直接跳转。

## 常用参数

| 参数 | 作用 |
|---|---|
| `--config <PATH>` | 指定配置文件 |
| `--no-init` | 不加载 `~/.config/fresh/init.ts` |
| `--no-plugins` | 禁用所有插件 |
| `--safe` | 安全模式：不加载 init 和插件，用于从错误配置中恢复 |
| `--stdin` | 从标准输入读取内容 |
| `-a` / `--attach [NAME]` | 连接到守护进程 |
| `--locale <CODE>` | 界面语言，如 `zh-CN`、`ja` |
| `--skill[=TOPIC]` | 显示操作指南 |

## 配置文件

主配置在 `~/.config/fresh/init.ts`，用 TypeScript 写：

```typescript
// 示例
export default {
  theme: "dark",
  lineNumbers: true,
  tabSize: 2,
};
```

本仓库**没有**提供 Fresh 配置文件——它属于可选工具，配置因人而异。

`--safe` 在配置写坏时救命：

```bash
fr --safe
```

跳过 init 和插件，直接进编辑器，然后修配置。

## 守护进程模式

```bash
fr -a                 # 连接到当前目录的守护进程
fr -a myproject       # 连接到命名守护进程
fr --cmd daemon list  # 列出运行中的守护进程
fr --cmd daemon kill  # 结束
```

守护进程模式让多个窗口共享同一个编辑器实例，打开文件更快。

## 界面语言

```bash
fr --locale zh-CN
fr --locale ja
fr --locale en
```

## 学习指南

```bash
fr --skill            # 交互式指南
fr --skill=tour       # 功能巡览
fr --skill=plugin     # 插件开发
```

这比读文档快——直接在编辑器里演示功能。

## 与 Neovim 的关系

| | Neovim | Fresh |
|---|---|---|
| 配置 | Lua | TypeScript |
| 生态 | 极大 | 小 |
| 键位 | Vim 模式 | 现代编辑器键位 |
| 多光标 | 需插件 | 内置 |
| 定位 | 主力编辑器 | 备选/轻量场景 |

本仓库的主力编辑器是 Neovim。Fresh 是「想换个手感」或「Neovim 出问题时」的备选。

## 排错

**`fr: command not found`**：init.sh 的 `install_fresh` 失败，或不在 PATH。检查 `~/.local/bin/fresh`。

**启动报配置错误**：`fr --safe` 进入安全模式，然后修 `init.ts`。

**界面是英文**：加 `--locale zh-CN`，或在配置里设默认语言。

**插件不加载**：`--no-plugins` 是否被误用？或插件目录损坏，试 `fr --safe`。

**NixOS 上找不到**：NixOS 不执行独立安装，需要在系统配置里加 `fresh-editor` 包。
