> 摘要：evalcache 缓存 shell hook 的初始化输出，避免每次启动都执行子进程。

# evalcache

## 用途

很多工具通过 `eval "$(tool init zsh)"` 接入 shell。每次启动 shell 都要执行一次子进程，生成一段固定不变的 shell 代码。

`mroth/evalcache` 提供 `_evalcache` 函数：第一次执行并缓存输出，之后直接 source 缓存文件。

## 加载方式

```zsh
zsh_plugins_load_main() {
  zinit light mroth/evalcache
  ...
}
```

它加载得很早（在 vi-mode 之前），因为后面的 `zshrc` 要用它。

## 本仓库的用法

`zshrc` 里两处：

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi

if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  alias zi='z -i'
  alias za='z -a'
  alias zr='z -r'
fi
```

`_evalcache atuin init zsh` 等价于：

```zsh
eval "$(atuin init zsh)"
```

但只在缓存不存在或工具更新时真正执行。

## 缓存机制

```text
~/.cache/zsh/evalcache/
├── atuin-init-zsh
└── zoxide-init-zsh
```

缓存的键由「命令 + 参数」生成。文件里存的是该命令的输出。

失效条件：

| 情况 | 行为 |
|---|---|
| 缓存不存在 | 执行命令并写入缓存 |
| 工具版本变化 | evalcache 会比较二进制修改时间，过期则重算 |
| 手动删除缓存 | 下次启动重新生成 |

## 为什么值得

| | 不用 evalcache | 用 evalcache |
|---|---|---|
| 每次启动 | 执行 `atuin init zsh`（约 30–80ms） | 读一个文件（约 1ms） |
| 启动 10 次 | 累计 300–800ms | 累计 10ms |
| 磁盘占用 | 0 | 几十 KB |

对经常开新终端或新 tmux pane 的人来说，差别明显。

## 手动控制

```bash
# 看缓存内容
ls ~/.cache/zsh/evalcache/
cat ~/.cache/zsh/evalcache/zoxide-init-zsh | head

# 强制重建
rm -rf ~/.cache/zsh/evalcache
exec zsh
```

升级 atuin 或 zoxide 后如果行为异常，先清这个目录。

## 什么时候不该用

| 情况 | 原因 |
|---|---|
| 输出含动态路径 | 缓存后路径不会更新 |
| 输出依赖当前目录 | 缓存是全局的，会出错 |
| 工具每次输出都不同 | 缓存失去意义 |

`evalcache` 适合「输出只随版本变化」的工具，不适合「输出随环境变化」的工具。

## 与其它加速手段的区别

| 手段 | 优化什么 |
|---|---|
| evalcache | 缓存 `eval "$(...)"` 的输出 |
| fnm 惰性加载 | 推迟到第一次用 Node 时初始化 |
| Zinit 缓存 | 插件本体不重新下载 |
| `zinit ice lucid` | 延迟插件的键位绑定 |

它们解决不同环节，可以叠加。

## 排错

**`_evalcache: command not found`**：evalcache 没加载。检查 `zsh_plugins_load_main` 里那行，以及它是否在 `zshrc` 调用 `zsh_plugins_load_main` 之前定义。

**改了 atuin 配置但没生效**：缓存还是旧的。`rm -rf ~/.cache/zsh/evalcache`。

**缓存目录不存在**：第一次运行时自动创建。如果创建失败，检查 `$XDG_CACHE_HOME` 的权限。

**启动仍然慢**：用 `zsh -x -i -c true 2>&1 | tail -30` 看时间花在哪，可能不是这两个 hook。
