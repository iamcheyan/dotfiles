> 摘要：--minimal 与 --repair 各自跳过或修复什么，以及未知参数会被如何处理。

# init.sh 选项

## 可用选项

```bash
bash init.sh              # 完整初始化
bash init.sh --minimal    # 轻量模式
bash init.sh --repair     # 额外修复 zinit 插件
```

两个选项可以同时使用：`bash init.sh --minimal --repair`。

## --minimal 跳过什么

脚本里明确跳过这些：

| 跳过项 | 原因 |
|---|---|
| 字体安装 | Meslo Nerd Font 和 Noto Serif CJK 体积大，下载慢 |
| Neovim 安装 | 已有编辑器的机器不需要再装一份 |
| translate-shell | 大型额外组件 |
| yt-dlp | 大型额外组件 |
| jq | 大型额外组件（若系统已装仍可用） |
| viu | 图片终端预览工具 |

启动时会打印一行提示，说明进入了 minimal 模式。适合：只想先拿到 shell 配置、或者在资源受限的机器上试装。

## --repair 修复什么

`--repair` 只做一件事：检查 Zinit 插件目录是否完整，不完整就重新拉取。它针对的是典型的半损坏状态：

- `~/.zinit/plugins/atuinsh---atuin` 存在但缺二进制
- `~/.zinit/plugins/Canop---broot` 下载中断
- 插件目录存在但 `zinit light` 加载时报错

它不会重装系统包，也不会覆盖你的配置文件。

## 未知参数的处理

```bash
bash init.sh --foo
```

当前实现里，参数解析用 `*) shift ;;` 兜底，未知参数被静默跳过，脚本照常按完整模式运行。这意味着**打错选项不会报错，而是执行了你没预期的完整安装**。执行前请核对拼写。

## 选项之外的可调项

`init.sh` 内部有几个环境变量可覆盖，主要用于测试和特殊环境：

| 变量 | 作用 |
|---|---|
| `NVIM_UPDATE_RELEASE_API_URL` | 替换 Neovim release API 地址 |
| `NVIM_UPDATE_INSTALL_ROOT` | 改变 Neovim 安装根目录 |
| `NVIM_UPDATE_BIN_DIR` | 改变 `nvim` 软链接所在目录 |
| `NVIM_UPDATE_TMPDIR` | 改变临时目录 |

这些变量主要由 `scripts/update_nvim.sh` 使用，测试脚本靠它们指向本地 fixture，避免真实下载。

## 什么时候不要用 init.sh

- 只想更新配置：用 `git pull` + `bash dotlink/dotlink link`。
- 只想装 Neovim：直接克隆 `iamcheyan/nvim` 跑它自己的 `init.sh`。
- 只想修复单个工具：用 `scripts/install/` 下的对应脚本。
