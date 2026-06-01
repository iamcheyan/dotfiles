# Zellij Plugins

## 已安装插件

| 插件 | 文件 | 状态 |
|---|---|---|
| zjstatus | `zjstatus.wasm` | 未启用 |
| zellij-attention | `zellij-attention.wasm` | 已启用 |

---

## zellij-attention

在 zellij tab 标题上显示通知图标，提醒你哪个 pane 需要关注。专为 Claude Code 设计。

### 效果

- **⏳** — Claude Code 在等你输入（权限确认、idle 等）
- **✅** — Claude Code 任务完成

切到对应 tab 后图标自动消失。

### 工作原理

通过 `zellij pipe --name` 发送消息给插件，插件收到后重命名 tab 标题追加图标。消息格式：

```
zellij-attention::EVENT_TYPE::PANE_ID
```

- `EVENT_TYPE`: `waiting` 或 `completed`
- `PANE_ID`: `$ZELLIJ_PANE_ID`

**注意：** 必须用 `--name`（广播），不能用 `--plugin`（定向），否则会创建新的插件实例。

### Claude Code Hooks 集成

在 `~/.claude/settings.json` 中配置：

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "zellij pipe --name \"zellij-attention::waiting::$ZELLIJ_PANE_ID\""
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "zellij pipe --name \"zellij-attention::completed::$ZELLIJ_PANE_ID\""
          }
        ]
      }
    ]
  }
}
```

| Claude Code 事件 | 图标 | 含义 |
|---|---|---|
| `Notification` | ⏳ | Claude 需要你关注（权限请求等） |
| `Stop` | ✅ | Claude 完成当前轮次 |

### 手动发送通知

```bash
# 等待中
zellij pipe --name "zellij-attention::waiting::$ZELLIJ_PANE_ID"

# 已完成
zellij pipe --name "zellij-attention::completed::$ZELLIJ_PANE_ID"
```

### Zellij 配置

在 `config.kdl` 中启用：

```kdl
plugins {
    tab-bar location="zellij:tab-bar"
    zellij-attention location="file:~/.config/zellij/plugins/zellij-attention.wasm"
}
load_plugins {
    zellij-attention
}
```

### 可选配置项

```kdl
load_plugins {
    "file:~/.config/zellij/plugins/zellij-attention.wasm" {
        enabled "true"
        waiting_icon "⏳"
        completed_icon "✅"
    }
}
```

### 来源

- GitHub: https://github.com/KiryuuLight/zellij-attention
