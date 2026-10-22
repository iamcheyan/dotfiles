> 摘要：gitui 是 Rust 写的终端 Git 界面，启动快、内存占用低。

# gitui

## 用途

gitui 和 lazygit 定位相同：终端里的 Git 全功能界面。区别在实现——gitui 用 Rust，启动更快；lazygit 用 Go，功能迭代更激进。

本仓库同时提供两者，按偏好选。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，按 OS/CPU 选择 Release 包 |
| 加载位置 | `plugins/tools/tools.zsh` |

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
  local gitui_asset="gitui-mac.tar.gz"
  [[ "$(uname -m)" == "x86_64" ]] && gitui_asset="gitui-mac-x86.tar.gz"
  zinit ice as"command" from"gh-r" bpick"$gitui_asset" pick"gitui"
else
  local gitui_arch="x86_64"
  case "$(uname -m)" in
    aarch64|arm64) gitui_arch="aarch64" ;;
    armv7l) gitui_arch="armv7" ;;
    armv6l|arm) gitui_arch="arm" ;;
  esac
  zinit ice as"command" from"gh-r" bpick"gitui-linux-${gitui_arch}.tar.gz" pick"gitui"
fi
zinit light gitui-org/gitui
```

`bpick` 按架构挑压缩包，`pick` 指定解压后的可执行文件名。

## 启动

```bash
gitui                       # 当前目录
gitui -d ~/project          # 指定 git 目录
gitui -w ~/project          # 指定工作目录
gitui -f src/main.rs        # 打开时选中某文件
```

## 参数

| 参数 | 作用 |
|---|---|
| `-d` / `--directory` | Git 目录（等同 `GIT_DIR`） |
| `-w` / `--workdir` | 工作区（等同 `GIT_WORK_TREE`） |
| `-f` / `--file` | 打开时选中指定文件 |
| `-t` / `--theme` | 主题文件名，默认 `theme.ron` |
| `-k` / `--key-bindings` | 自定义键位文件 |
| `-s` / `--key-symbols` | 自定义符号文件 |
| `-l` / `--logging` | 启用日志 |
| `--logfile` | 指定日志路径 |
| `--watcher` | 用文件系统监听而非轮询 |
| `--bugreport` | 生成问题报告 |

## 面板与按键

| 键 | 作用 |
|---|---|
| `Tab` | 切换面板 |
| `↑` / `↓` / `j` / `k` | 移动 |
| `Enter` | 打开/进入 |
| `Space` | 暂存 |
| `c` | 提交 |
| `p` | push |
| `f` | fetch |
| `b` | 分支面板 |
| `?` | 帮助 |
| `q` | 退出 |

## --watcher

```bash
gitui --watcher
```

默认用轮询检测文件变化，每次间隔固定时间。`--watcher` 改用 `notify` 库监听 inotify 事件，变化响应更快、CPU 占用更低。

代价：某些文件系统（网络挂载、某些容器）不支持 inotify，会失效。上游文档建议在这些环境里不要开。

## 自定义主题与键位

```bash
gitui -t my-theme.ron -k my-keys.ron
```

`.ron` 是 Rust 的对象表示格式。默认主题文件在配置目录，可以用 `gitui --bugreport` 查看实际加载路径。

## 与 lazygit 的对比

| | gitui | lazygit |
|---|---|---|
| 语言 | Rust | Go |
| 启动速度 | 更快 | 快 |
| 内存 | 更低 | 稍高 |
| 功能覆盖 | 核心操作 | 更全（rebase 交互、submodule 等） |
| 配置格式 | RON | YAML |
| 社区 | 较小 | 活跃 |

日常 add/commit/push 两者都够。需要复杂 rebase 时 lazygit 更顺手。

## 排错

**`gitui: command not found`**：Zinit 未下载对应架构的包。`zinit list | grep gitui` 确认。

**启动报「not a git repository」**：当前目录不在仓库内。用 `-d` 指定。

**中文乱码**：终端字体缺 CJK 字形。

**`--watcher` 无效果**：文件系统不支持 inotify。去掉该参数。

**主题不生效**：`-t` 指定的是配置目录下的文件名，不是任意路径。先 `gitui --bugreport` 看配置目录在哪。
