> 摘要：pay-respects 为错误命令提供修正建议；本仓库将 `F` 注册为建议别名。

# pay-respects
## 用途

pay-respects 会根据失败命令及错误信息查找可能的修正。运行 `F` 查看建议并选择是否执行；执行前应检查建议的命令内容。

## 安装

在支持的非 NixOS 系统运行仓库初始化脚本时，`init.sh` 会调用官方 Unix 安装器，将程序和模块安装到 `~/.local/bin`。安装器会询问是否保留可选 AI fallback 模块。请确保该目录已加入 `PATH`；重复运行时会检查 `PATH` 中是否已有 `pay-respects` 命令，并跳过安装。

NixOS 用户在 `nixos-config` 中管理系统包。也可参照 [上游安装说明](https://github.com/iffse/pay-respects#installing) 使用发行版包或官方安装器。

## 使用

在交互式 Zsh 中运行失败命令后按 `F`，查看 pay-respects 给出的修正建议。部分集成依赖终端保留命令输出；遇到没有建议的情况，可在终端中重试并确认错误输出仍可见。

重新打开 Zsh 后验证集成：

```zsh
whence -w __pr_main
bindkey | grep -E '"F"'
```

## 本仓库配置

`plugins/zsh-plugins.zsh` 在可选 shell 工具加载阶段检查 `pay-respects` 是否可用，再运行：

```zsh
eval "$(pay-respects zsh --alias F)"
```

因此，未安装程序时 Zsh 启动不受影响。安装器还会下载上游 runtime rules 和 AI fallback 模块；若不需要 AI 模块，可在官方安装提示中选择移除。

## 排错

- `pay-respects: command not found`：确认 `~/.local/bin` 在 `PATH` 中，再运行 `bash init.sh`。
- 按 `F` 没有反应：确认当前是交互式 Zsh、shell hook 已加载，并用 `bindkey` 检查按键绑定。
- 没有修正建议：pay-respects 只对可识别的错误提供建议；检查原始错误输出，并参照[上游文档](https://github.com/iffse/pay-respects)。
