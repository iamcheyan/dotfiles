# Codex CLI Plugin (MiMo)

通过 `xmcodex` 使用 MiMo API，完全隔离不影响用户默认的 `codex`（ChatGPT）。

## 原理

| 命令 | 版本 | Config | API |
|------|------|--------|-----|
| `codex` | 全局 (0.80.0) | `~/.codex/config.toml` | ChatGPT |
| `xmcodex` | nvm codex-mimo (0.78.0) | `home/config.toml` | MiMo |

`CODEX_HOME` 环境变量让 codex 读取插件目录的配置，不碰用户的 `~/.codex/`。

## 首次运行

```bash
xmcodex
```

自动安装 codex 0.78.0 到 nvm alias `codex-mimo`，无需手动操作。

## 配置

API key 在 `.env` 文件中，已 gitignore。
