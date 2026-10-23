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

<!-- lang:en -->

> Summary: zsh-syntax-highlighting colors the command line in real time; it must load last or its hooks get overwritten.

# zsh-syntax-highlighting

## Purpose

It colors commands as you type: existing commands green, unknown ones red, with distinct colors for strings, variables, paths, and redirections. It lets you spot typos **before** pressing Enter.

## How It Loads

```zsh
zsh_plugins_load_main() {
  ...
  # 必须是最后一行
  zinit light zsh-users/zsh-syntax-highlighting
}
```

**The position is a hard constraint**, not a stylistic preference.

## Why It Must Be Last

It works via the `zle` `line-pre-redraw` hook: before every redraw of the command line, it reads the buffer contents and computes the highlight ranges.

Any plugin loaded after it that also sets a `line-pre-redraw` hook will **replace** rather than append, breaking the highlighting.

Plugins commonly affected by this:

| Plugin | Symptom of the conflict |
|---|---|
| zsh-autosuggestions | Suggestion text loses its gray color |
| zsh-vi-mode | Colors scramble after mode switches |
| fzf-tab | Highlighting residue remains after completion |

Conversely, if syntax-highlighting loads first and these plugins overwrite its hook, the result is **no syntax highlighting at all**.

## What It Can Highlight

| Element | Default color |
|---|---|
| Existing command | Green |
| Non-existent command | Red |
| Alias | Cyan |
| String `'...'` | Yellow |
| Variable `$VAR` | Cyan |
| Path (exists) | Underline |
| Path (does not exist) | Red |
| Redirection `>` | Purple |
| Option `-x` | Blue |
| Comment `#...` | Gray |

The concrete colors are controlled by `ZSH_HIGHLIGHT_STYLES`.

## Customizing Colors

```zsh
# 放在 zshrc 里，且在 zinit light 之前
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[path]='underline'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
```

This repository does not override them; it uses the upstream defaults.

## Working with vi-mode

Both modify `zle` behavior, but through different mechanisms:

| | syntax-highlighting | vi-mode |
|---|---|---|
| Effect | Coloring | Keybindings |
| Hook | `line-pre-redraw` | Keymap replacement |

As long as the order is correct (vi-mode first, highlighting last), the two do not interfere.

## Working with autosuggestions

autosuggestions colors suggestion text with `fg=8`. syntax-highlighting colors the part you have already typed. Their ranges do not overlap:

```text
[已输入部分: 语法高亮] [建议部分: fg=8 灰]
```

If the suggestion part also shows up green, autosuggestions' highlight style has been overwritten.

## Performance

Every redraw parses the entire command line. Very long commands (thousands of characters) can cause noticeable lag.

Mitigation:

```zsh
ZSH_HIGHLIGHT_MAXLENGTH=512
```

Anything beyond this length is no longer highlighted.

## Troubleshooting

**No colors at all**: the plugin did not load, or a later plugin overwrote it. Check that it is the last line of `zsh_plugins_load_main`.

**Some elements lack color**: `ZSH_HIGHLIGHT_STYLES` has been modified. Inspect it with `echo ${(kv)ZSH_HIGHLIGHT_STYLES}`.

**Colors clash with the terminal theme**: some color schemes have low green/red contrast. Change the values in `ZSH_HIGHLIGHT_STYLES`.

**Lag when typing very long commands**: set `ZSH_HIGHLIGHT_MAXLENGTH`.

**CJK characters render incorrectly**: highlighting is computed per byte, and CJK characters can misalign underlines. This is a known upstream limitation.

**No highlighting visible under `zsh -x` tracing**: `zle` does not work in non-interactive mode; this is expected.

<!-- lang:ja -->

> 要約：zsh-syntax-highlighting はコマンドラインをリアルタイムに着色します。最後に読み込まないと hook が上書きされます。

# zsh-syntax-highlighting

## 用途

入力中のコマンドをリアルタイムに着色します。存在するコマンドは緑、存在しないものは赤、文字列・変数・パス・リダイレクトにもそれぞれ色が付きます。Enter を押す**前に**タイプミスに気づけるのが利点です。

## 読み込み方法

```zsh
zsh_plugins_load_main() {
  ...
  # 必须是最后一行
  zinit light zsh-users/zsh-syntax-highlighting
}
```

**位置はハードな制約**であり、スタイルの好みではありません。

## なぜ最後でなければならないのか

`zle` の `line-pre-redraw` hook を通じて動作します。コマンドラインが再描画されるたびに、バッファの内容を読み取り、ハイライト区間を計算します。

それより後に読み込まれるプラグインが同じく `line-pre-redraw` hook を設定すると、追加ではなく**置き換え**になるため、ハイライトが壊れます。

影響を受けやすいプラグインの例：

| プラグイン | 衝突の症状 |
|---|---|
| zsh-autosuggestions | 補完候補の文字がグレーにならない |
| zsh-vi-mode | モード切替後に色が乱れる |
| fzf-tab | 補完後にハイライトの残りが出る |

逆に syntax-highlighting が先に読み込まれると、これらのプラグインが hook を上書きし、結果として**シンタックスハイライトが一切効かなくなります**。

## 何をハイライトできるか

| 要素 | 既定の色 |
|---|---|
| 存在するコマンド | 緑 |
| 存在しないコマンド | 赤 |
| エイリアス | シアン |
| 文字列 `'...'` | 黄 |
| 変数 `$VAR` | シアン |
| パス（存在する） | 下線 |
| パス（存在しない） | 赤 |
| リダイレクト `>` | 紫 |
| オプション `-x` | 青 |
| コメント `#...` | グレー |

具体的な色は `ZSH_HIGHLIGHT_STYLES` で制御されます。

## 色のカスタマイズ

```zsh
# 放在 zshrc 里，且在 zinit light 之前
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[path]='underline'
ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
```

本リポジトリでは上書きせず、上流の既定値を使っています。

## vi-mode との併用

両方とも `zle` の挙動を変えますが、仕組みは異なります：

| | syntax-highlighting | vi-mode |
|---|---|---|
| 役割 | 着色 | キーバインド |
| hook | `line-pre-redraw` | キーマップの置き換え |

順序さえ正しければ（vi-mode が先、highlighting が後）、両者は干渉しません。

## autosuggestions との併用

autosuggestions は `fg=8` で補完候補の文字に色を付けます。syntax-highlighting はすでに入力した部分に色を付けます。両者の適用区間は重なりません：

```text
[已输入部分: 语法高亮] [建议部分: fg=8 灰]
```

候補部分まで緑で表示されるなら、autosuggestions のハイライトスタイルが上書きされています。

## パフォーマンス

再描画のたびにコマンドライン全体を解析します。非常に長いコマンド（数千文字）では体感できる遅延が出ることがあります。

緩和方法：

```zsh
ZSH_HIGHLIGHT_MAXLENGTH=512
```

この長さを超えるとハイライトしなくなります。

## トラブルシューティング

**まったく色が付かない**：プラグインが読み込まれていないか、後続のプラグインに上書きされています。`zsh_plugins_load_main` の最終行になっているか確認してください。

**一部の要素に色が付かない**：`ZSH_HIGHLIGHT_STYLES` が変更されています。`echo ${(kv)ZSH_HIGHLIGHT_STYLES}` で確認できます。

**色がターミナルテーマと合わない**：配色によっては緑/赤のコントラストが低いものがあります。`ZSH_HIGHLIGHT_STYLES` の値を変更してください。

**非常に長いコマンドの入力時にカクつく**：`ZSH_HIGHLIGHT_MAXLENGTH` を設定してください。

**CJK 文字の表示が崩れる**：着色はバイト単位で計算されるため、CJK 文字で下線がずれることがあります。上流の既知の制限です。

**`zsh -x` でトレース中はハイライトが出ない**：非対話モードでは `zle` が動作しないためで、予期された挙動です。
