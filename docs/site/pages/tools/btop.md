> 摘要：btop 是终端资源监视器，显示 CPU、内存、磁盘、网络和进程。

# btop

## 用途

`btop` 是 `top`/`htop` 的现代替代：彩色、可鼠标操作、支持 CPU 每核心曲线、内存/交换/磁盘/网络面板、进程树。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 加载位置 | `plugins/tools/tools.zsh` |

```zsh
zi_cmd aristocratos/btop btop
```

## 启动

```bash
btop
```

## 界面结构

```text
┌─ CPU ─────────────────────────────────────┐
│ 每核心使用率曲线、总负载、频率            │
├─ MEM ─────────────┬─ NET ────────────────┤
│ 内存、交换、缓存  │ 上下行速率曲线       │
├─ PROC ────────────┴──────────────────────┤
│ 进程列表（CPU/内存排序）                 │
└──────────────────────────────────────────┘
```

默认布局可以用 `Esc` 打开的菜单调整，配置会保存。

## 常用按键

| 键 | 作用 |
|---|---|
| `m` | 打开/关闭菜单 |
| `Esc` | 返回/关闭菜单 |
| `+` / `-` | 调整刷新间隔 |
| `p` | 切换进程树视图 |
| `f` | 过滤进程 |
| `r` | 反向排序 |
| `t` | 切换树状/平铺 |
| `k` | 结束选中进程（需确认） |
| `q` | 退出 |

鼠标也能用：点面板切换、点列头排序、滚轮滚动。

## 配置

首次运行会生成 `~/.config/btop/btop.conf`。常用项：

| 配置 | 作用 |
|---|---|
| `update_ms` | 刷新间隔（毫秒） |
| `proc_sorting` | 进程排序字段 |
| `proc_tree` | 是否默认树状 |
| `shown_boxes` | 显示哪些面板 |
| `theme` | 配色主题 |

本仓库**没有**提供 btop 配置文件，用上游默认值。想定制就在本机生成后修改，不要放进公开仓库（配置里可能含本机路径）。

## 与其他监视工具的分工

| 工具 | 特点 |
|---|---|
| `btop` | 图形化曲线，鼠标友好，资源占用稍高 |
| `btm`（bottom） | 可配置性强，Rust 实现，启动快 |
| `procs` | 只看进程，输出可管道处理 |
| `duf` | 只看磁盘 |
| `top` / `htop` | 系统自带，最轻量 |

在 SSH 或低带宽环境里，`btm --basic` 或 `top` 更合适——btop 的曲线刷新会产生较多终端输出。

## 排错

**`btop: command not found`**：Zinit 未下载。`zinit list | grep btop` 确认。

**图形乱码**：终端字体或 `$TERM` 不支持 Unicode 制表符。在 tmux 里确认 `default-terminal` 是 `tmux-256color`。

**CPU 曲线不显示**：某些虚拟化环境没有暴露 per-core 数据。`btop` 会退化成总体使用率。

**刷新太频繁导致卡顿**：`update_ms` 调大，或按 `-` 键降低频率。

**结束进程失败**：权限不足。需要 sudo 的进程要 `sudo btop`。

<!-- lang:en -->
> Summary: btop is a terminal resource monitor showing CPU, memory, disks, network, and processes.

# btop

## Purpose

`btop` is a modern replacement for `top`/`htop`: colorful, mouse-operable, with per-CPU-core graphs, memory/swap/disk/network panels, and a process tree.

## Source and installation

| Item | Description |
|---|---|
| Source | Zinit, downloaded from GitHub Release |
| Load location | `plugins/tools/tools.zsh` |

```zsh
zi_cmd aristocratos/btop btop
```

## Launching

```bash
btop
```

## Interface layout

```text
┌─ CPU ─────────────────────────────────────┐
│ 每核心使用率曲线、总负载、频率            │
├─ MEM ─────────────┬─ NET ────────────────┤
│ 内存、交换、缓存  │ 上下行速率曲线       │
├─ PROC ────────────┴──────────────────────┤
│ 进程列表（CPU/内存排序）                 │
└──────────────────────────────────────────┘
```

The default layout can be adjusted through the menu opened with `Esc`, and the configuration is saved.

## Common keys

| Key | Action |
|---|---|
| `m` | Open/close the menu |
| `Esc` | Back/close the menu |
| `+` / `-` | Adjust the refresh interval |
| `p` | Toggle the process tree view |
| `f` | Filter processes |
| `r` | Reverse sorting |
| `t` | Toggle tree/flat mode |
| `k` | Kill the selected process (requires confirmation) |
| `q` | Quit |

The mouse works too: click panels to switch, click column headers to sort, scroll with the wheel.

## Configuration

The first run generates `~/.config/btop/btop.conf`. Common settings:

| Setting | Action |
|---|---|
| `update_ms` | Refresh interval (milliseconds) |
| `proc_sorting` | Process sorting field |
| `proc_tree` | Whether tree view is the default |
| `shown_boxes` | Which panels to show |
| `theme` | Color theme |

This repo does **not** ship a btop config file; upstream defaults are used. To customize, generate the file locally and edit it there — do not put it in the public repo (the config may contain local paths).

## Division of labor with other monitors

| Tool | Characteristics |
|---|---|
| `btop` | Graphical curves, mouse-friendly, slightly heavier |
| `btm` (bottom) | Highly configurable, Rust implementation, fast startup |
| `procs` | Processes only, pipeable output |
| `duf` | Disks only |
| `top` / `htop` | Ship with the system, lightest |

Over SSH or on low-bandwidth links, `btm --basic` or `top` is a better fit — btop's graph refreshes produce a fair amount of terminal output.

## Troubleshooting

**`btop: command not found`**: Zinit has not downloaded it. Confirm with `zinit list | grep btop`.

**Garbled graphics**: the terminal font or `$TERM` does not support Unicode box-drawing characters. In tmux, confirm `default-terminal` is `tmux-256color`.

**CPU graphs missing**: some virtualized environments do not expose per-core data. `btop` falls back to overall usage.

**Stuttering from too-frequent refreshes**: increase `update_ms`, or press `-` to lower the frequency.

**Killing a process fails**: insufficient permissions. Processes requiring sudo need `sudo btop`.

<!-- lang:ja -->
> 要約：btop は CPU・メモリ・ディスク・ネットワーク・プロセスを表示するターミナル用リソースモニターです。

# btop

## 用途

`btop` は `top`/`htop` の現代的な代替です。カラフルでマウス操作に対応し、CPU コアごとのグラフ、メモリ/スワップ/ディスク/ネットワークのパネル、プロセスツリーを備えます。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit、GitHub Release からダウンロード |
| 読み込み場所 | `plugins/tools/tools.zsh` |

```zsh
zi_cmd aristocratos/btop btop
```

## 起動

```bash
btop
```

## 画面構成

```text
┌─ CPU ─────────────────────────────────────┐
│ 每核心使用率曲线、总负载、频率            │
├─ MEM ─────────────┬─ NET ────────────────┤
│ 内存、交换、缓存  │ 上下行速率曲线       │
├─ PROC ────────────┴──────────────────────┤
│ 进程列表（CPU/内存排序）                 │
└──────────────────────────────────────────┘
```

デフォルトのレイアウトは `Esc` で開くメニューから調整でき、設定は保存されます。

## よく使うキー

| キー | 動作 |
|---|---|
| `m` | メニューを開く/閉じる |
| `Esc` | 戻る/メニューを閉じる |
| `+` / `-` | 更新間隔を調整 |
| `p` | プロセスツリービューを切り替え |
| `f` | プロセスをフィルタ |
| `r` | 並び順を反転 |
| `t` | ツリー/フラット表示を切り替え |
| `k` | 選択したプロセスを終了（確認あり） |
| `q` | 終了 |

マウスも使えます。パネルをクリックして切り替え、列ヘッダーをクリックしてソート、ホイールでスクロールします。

## 設定

初回実行時に `~/.config/btop/btop.conf` が生成されます。主な項目：

| 設定 | 動作 |
|---|---|
| `update_ms` | 更新間隔（ミリ秒） |
| `proc_sorting` | プロセスのソート項目 |
| `proc_tree` | デフォルトでツリー表示にするか |
| `shown_boxes` | 表示するパネル |
| `theme` | カラーテーマ |

本リポジトリは btop の設定ファイルを提供して**おらず**、上流のデフォルト値を使います。カスタマイズしたい場合は、ローカルで生成してから修正してください。公開リポジトリには入れないでください（設定にローカルのパスが含まれる可能性があります）。

## 他のモニターツールとの使い分け

| ツール | 特徴 |
|---|---|
| `btop` | グラフィカルな曲線、マウスに優しい、やや重い |
| `btm`（bottom） | 設定可能性が高く、Rust 実装、起動が速い |
| `procs` | プロセスのみ、パイプ処理しやすい出力 |
| `duf` | ディスクのみ |
| `top` / `htop` | システム付属、最も軽量 |

SSH や低帯域環境では `btm --basic` か `top` の方が適しています。btop のグラフ再描画はターミナル出力が多めになるためです。

## トラブルシューティング

**`btop: command not found`**：Zinit がダウンロードしていません。`zinit list | grep btop` で確認してください。

**グラフィックが文字化けする**：ターミナルのフォントか `$TERM` が Unicode の罫線文字に対応していません。tmux 内では `default-terminal` が `tmux-256color` か確認してください。

**CPU のグラフが表示されない**：一部の仮想化環境ではコアごとのデータが公開されていません。`btop` は全体使用率にフォールバックします。

**更新が頻繁すぎてカクつく**：`update_ms` を大きくするか、`-` キーで頻度を下げてください。

**プロセスの終了に失敗する**：権限が足りません。sudo が必要なプロセスには `sudo btop` を使います。
