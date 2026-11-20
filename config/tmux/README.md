# 完整 Tmux 配置

`tmux.conf`、`restore.conf`、`restore-hooks.conf` 与 `scripts/` 均由 dotlink 部署到 `~/.config/tmux/`。独立克隆 dotfiles 后执行 `bash init.sh`，无需 chezmoi 即可安装 TPM、插件并使用会话持久化。

- `restore.conf`：15 分钟定时保存、编辑器与可选 Agent 进程恢复设置。
- `restore-hooks.conf`：退出时避免空会话覆盖有效快照，创建会话时选择有效快照恢复。
- `scripts/continuum_save_wrapper.sh`：让无 attached client 的定时保存覆盖全部会话。
- `scripts/persist_save_guard.sh` 与 `persist_restore_guard.sh`：保护有效保存记录。
- `scripts/pre-restore-agents.sh`：对已有 Agent 命令补充继续会话参数；未安装的工具无需安装，普通 shell 不受影响。

TPM 插件目录和快照属于用户运行时数据，不入库。可选 `private.conf`、`private-after.conf` 仍可用于个人覆盖，但不是完整功能的前提。迁移时只替换配置与脚本，不移动或删除已有插件、快照。
