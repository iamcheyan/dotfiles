# Agents

MiMo API 的 AI 编程助手合集，与用户自己安装的版本完全隔离。

## 快速开始

```bash
# 1. 选择一个 agent，进入目录
cd ~/dotfiles/agents/codex

# 2. 复制配置模板，填入 API Key
cp env.sample .env
vim .env

# 3. 直接运行（首次自动安装）
bash codex
```

## 别名

在 `aliases.conf` 中已配置：

| 别名 | Agent | 说明 |
|------|-------|------|
| `app:codex` | Codex CLI | OpenAI Codex，MiMo API |
| `app:cline` | Cline CLI | 自主编程代理，MiMo API |
| `app:opencode` | OpenCode CLI | 终端 AI 助手，MiMo API |
| `app:claudecode` | Claude Code | Anthropic Claude Code |

## 隔离机制

每个 agent 使用独立的 nvm alias，不影响用户全局安装的版本：

| 命令 | 来源 | API | 配置 |
|------|------|-----|------|
| `codex` | 全局 npm | ChatGPT (用户登录) | `~/.codex/` |
| `app:codex` | nvm codex-mimo | MiMo | `agents/codex/home/` |
| `claude` | 全局 | OAuth/API Key | `~/.claude/` |
| `app:claudecode` | 全局 | 同上 | 共享 symlink |
| `cline` | nvm cline | MiMo | 独立 |
| `opencode` | nvm opencode | MiMo | 独立 |

## API Key 获取

MiMo API (小米大模型):
- 按量付费: https://mimo.xiaomi.com/api-keys (key 格式: `sk-xxxxx`)
- Token Plan: https://mimo.xiaomi.com/subscription/manage (key 格式: `tp-xxxxx`)

Anthropic API:
- https://console.anthropic.com/settings/keys

## 目录结构

```
agents/
├── README.md
├── codex/
│   ├── codex          # 入口脚本
│   ├── env.sample     # 配置模板
│   ├── .env           # 用户配置 (gitignored)
│   └── home/          # CODEX_HOME (独立配置目录)
├── cline/
│   ├── cline
│   ├── env.sample
│   └── .env           # gitignored
├── opencode/
│   ├── opencode
│   ├── env.sample
│   └── .env           # gitignored
└── claude-code/
    ├── claudecode     # 入口脚本
    ├── env.sample     # 配置模板
    ├── settings.json  # Claude Code 配置 (symlink 到 ~/.claude/)
    └── projects/      # 项目配置 (symlink 到 ~/.claude/)
```

## 脚本逻辑

每个入口脚本的行为一致：

1. 加载 `.env` 环境变量
2. 检查工具是否已安装
3. 未安装 → 自动通过 nvm 安装
4. 启动工具

## 安全

- `.env` 文件被 `.gitignore` 过滤，不会提交到仓库
- `env.sample` 只包含模板，不含真实 key
- Git history 中无密钥记录
