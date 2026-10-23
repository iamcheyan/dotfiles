> 摘要：zsh-syntax-highlighting 实时给命令行上色，必须最后加载否则会被覆盖。

# zsh-syntax-highlighting

## 用途

输入命令时实时着色：存在的命令绿色、不存在的红色、字符串、变量、路径、重定向各有颜色。它让你在按回车**之前**看出拼写错误。

## 加载方式

```zsh
zsh_plugins_load_main() {
  ...
  # 必须是最后一行
  zinit light zsh-users/zsh-syntax-highlighting
}
```

**位置是硬约束**，不是风格偏好。

## 为什么必须最后

它通过 `zle` 的 `line-pre-redraw` hook 工作：每次命令行重绘前，读取缓冲区内容并计算高亮区间。

任何在它之后加载的插件，如果也设置了 `line-pre-redraw` hook，会**替换**而不是追加，导致高亮失效。

常见会被它影响的插件：

| 插件 | 冲突表现 |
|---|---|
| zsh-autosuggestions | 建议文字没有灰色 |
| zsh-vi-mode | 模式切换后颜色错乱 |
| fzf-tab | 补全后高亮残留 |

反过来，如果 syntax-highlighting 先加载，这些插件覆盖它的 hook，结果是**完全没有语法高亮**。

## 能高亮什么

| 元素 | 默认颜色 |
|---|---|
| 存在的命令 | 绿 |
| 不存在的命令 | 红 |
| 别名 | 青色 |
| 字符串 `'...'` | 黄 |
| 变量 `$VAR` | 青 |
| 路径（存在） | 下划线 |
| 路径（不存在） | 红 |
| 重定向 `>` | 紫 |
| 选项 `-x` | 蓝 |
| 注释 `#...` | 灰 |

具体颜色由 `ZSH_HIGHLIGHT_STYLES` 控制。

## 自定义颜色

```zsh
# 放在 zshrc 里，且在 zinit light 之前
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[path]='underline'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
```

本仓库没有覆盖，用上游默认值。

## 与 vi-mode 的配合

两者都改 `zle` 行为，但机制不同：

| | syntax-highlighting | vi-mode |
|---|---|---|
| 作用 | 着色 | 键位 |
| hook | `line-pre-redraw` | 键位表替换 |

只要顺序正确（vi-mode 先、highlighting 后），两者互不干扰。

## 与 autosuggestions 的配合

autosuggestions 用 `fg=8` 给建议文字上色。syntax-highlighting 给已输入部分上色。两者作用区间不重叠：

```text
[已输入部分: 语法高亮] [建议部分: fg=8 灰]
```

如果建议部分也显示成绿色，说明 autosuggestions 的高亮样式被覆盖了。

## 性能

每次重绘都要解析整个命令行。对超长命令（几千字符）会有可感知延迟。

缓解：

```zsh
ZSH_HIGHLIGHT_MAXLENGTH=512
```

超过这个长度不再高亮。

## 排错

**完全没有颜色**：插件没加载，或被后续插件覆盖。检查它是否是 `zsh_plugins_load_main` 的最后一行。

**部分元素没颜色**：`ZSH_HIGHLIGHT_STYLES` 被改过。`echo ${(kv)ZSH_HIGHLIGHT_STYLES}` 查看。

**颜色和终端主题冲突**：某些配色的绿/红对比度低。改 `ZSH_HIGHLIGHT_STYLES` 里的值。

**输入很长的命令时卡顿**：设 `ZSH_HIGHLIGHT_MAXLENGTH`。

**中文显示异常**：着色按字节计算，CJK 字符可能让下划线错位。这是上游已知限制。

**`zsh -x` 追踪时看不到高亮**：非交互模式下 `zle` 不工作，属预期。
