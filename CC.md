# cc — Claude Code 启动器

`cc` 是 `claude` (Claude Code) 的封装脚本，自动处理 nvm 环境、provider/model 切换、会话管理等功能。

## 快速开始

```bash
cc                          # 启动 Claude Code（使用上次的 provider/model）
cc mimo-anthropic           # 使用指定 provider
cc mimo-anthropic mimo-v2.5 # 使用指定 provider + model
cc -s                       # 交互式选择 model
cc -c                       # 继续上次的对话
cc -r                       # 交互式选择历史对话
```

## 功能一览

| 分类 | 命令 | 说明 |
|------|------|------|
| **启动** | `cc` | 启动 Claude Code |
| | `cc <provider>` | 使用指定 provider（取第一个 model） |
| | `cc <provider> <model>` | 使用指定 provider 和 model |
| | `cc -s` / `cc --select` | 交互式选择 provider/model |
| **会话** | `cc -c` / `cc --continue` | 继续当前目录下最近的对话 |
| | `cc -r` / `cc --resume` | 打开交互式对话选择器 |
| | `cc -r <session-id>` | 恢复指定 session |
| | `cc --session-id <uuid>` | 使用指定 session ID |
| | `cc --fork-session` | 恢复时创建新 session（不覆盖原对话） |
| | `cc --from-pr [pr]` | 恢复与 PR 关联的 session |
| **模式** | `cc -p <prompt>` / `cc --print` | 非交互模式，输出后退出 |
| | `cc --bare` | 极简模式（跳过 hooks、LSP、CLAUDE.md 等） |
| **会话设置** | `cc -n <name>` / `cc --name` | 设置 session 显示名称 |
| | `cc --effort <level>` | 设置 effort 级别：low / medium / high / xhigh / max |
| | `cc --permission-mode <mode>` | 权限模式：acceptEdits / auto / bypassPermissions / default / dontAsk / plan |
| | `cc --model <model>` | 临时覆盖 model |
| **工作区** | `cc -w` / `cc --worktree` | 为本次 session 创建 git worktree |
| **调试** | `cc -d` / `cc --debug [filter]` | 开启 debug 模式 |
| **版本** | `cc -v` / `cc --version` | 查看当前 vs 最新版本 |
| | `cc --versions` | 查看最近 10 个版本 |

## Provider 配置

Provider 信息从 `~/.config/opencode/opencode.json` 读取，格式如下：

```json
{
  "provider": {
    "mimo-anthropic": {
      "options": {
        "apiKey": "sk-xxx",
        "baseURL": "https://api.example.com"
      },
      "models": {
        "mimo-v2.5-pro": {},
        "mimo-v2.5": {}
      }
    },
    "deepseek": {
      "options": {
        "apiKey": "sk-xxx",
        "baseURL": "https://api.deepseek.com"
      },
      "models": {
        "deepseek-v4-flash": {}
      }
    }
  }
}
```

脚本会自动将 provider 的 `apiKey`、`baseURL`、`model` 映射为 Claude Code 需要的环境变量：

- `ANTHROPIC_API_KEY`
- `ANTHROPIC_BASE_URL`
- `ANTHROPIC_MODEL`

## 使用示例

### 基础启动

```bash
# 直接启动（使用上次记住的 provider/model）
cc

# 指定 provider，自动使用该 provider 的第一个 model
cc mimo-anthropic

# 指定 provider 和 model
cc mimo-anthropic mimo-v2.5
cc deepseek deepseek-v4-flash
cc kimi kimi-k2.6

# 交互式选择
cc -s
```

### 会话恢复

```bash
# 继续当前目录最近的对话
cc -c

# 打开对话选择器，从历史中挑选
cc -r

# 恢复指定 session
cc -r 0821a093-1828-4453-9eeb-b620a9073c14

# 恢复时 fork（不修改原对话）
cc -c --fork-session
cc -r 0821a093-... --fork-session

# 从 PR 恢复关联的 session
cc --from-pr 123
cc --from-pr https://github.com/org/repo/pull/123
```

### 组合使用

Provider/model 和 Claude Code 参数可以任意顺序混用：

```bash
# provider 在前，flag 在后
cc mimo-anthropic -c
cc deepseek -r abc123-...

# flag 在前，provider 在后
cc -c mimo-anthropic
cc -r abc123-... deepseek

# 同时指定 provider + model + flag
cc mimo-anthropic mimo-v2.5 -c
cc -p "fix the bug" kimi kimi-k2.6
```

### 非交互模式

```bash
# 输出结果后退出（适合管道或脚本中使用）
cc -p "列出所有 TODO 注释"
cc mimo-anthropic -p "解释这个函数的作用"

# 从管道读取输入
cat error.log | cc -p "分析这个错误日志"
```

### 高级用法

```bash
# 极简模式（跳过所有自动发现和 hooks）
cc --bare -p "hello"

# 设置 effort 级别
cc --effort max

# 临时换 model
cc --model claude-opus-4-8

# 开启 debug
cc -d
cc -d api,hooks

# 创建 worktree 工作
cc -w

# 设置 session 名称
cc -n "refactor-auth"
```

## 记忆功能

`cc` 会自动记住上次使用的 provider 和 model（存储在 `~/.cache/cc_last_model`）。

- 无参数启动 `cc` 时，自动使用上次的 provider/model
- 有参数启动时，不读取缓存，使用本次指定的 provider/model
- 仅在指定 provider 时才会更新缓存

## 自动更新

当带参数启动时（如 `cc mimo-anthropic`），脚本会在启动前自动检查并更新 `@anthropic-ai/claude-code`。无参数启动时不触发更新。

## 依赖

- **nvm** — 用于加载 Node.js 环境
- **node** — 用于解析配置和运行选择器
- **@anthropic-ai/claude-code** — 未安装时自动安装
- **~/.config/opencode/opencode.json** — provider 配置文件（使用 provider 时必需）
