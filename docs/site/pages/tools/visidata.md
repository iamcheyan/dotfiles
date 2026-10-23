> 摘要：VisiData 是终端里的电子表格多面手，本仓库用它交互式地探索、清洗和整理 CSV/TSV/JSON 等表格数据，与批处理的 qsv、跑 SQL 的 tabiew 互补。

# VisiData

## 用途

`VisiData` 是一个终端表格数据浏览器/编辑器：把 CSV、TSV、JSON、Excel 等文件打开成可滚动的电子表格，用键盘完成选择、排序、过滤、分组、编辑列、正则/Python 表达式派生新列等操作，最后另存为需要的格式。官方一句话描述是「explore, clean, edit, and restructure data」。

本仓库里它的定位是「交互式数据整理」那一环：

- 想快速看一眼一个几万行的 CSV 长什么样、每列什么类型 → `vd file.csv`
- 想边看边筛、边排序、边算个频率表 → VisiData
- 想写成脚本反复跑 → 用 [qsv](qsv.html)
- 想用 SQL 查本地表格文件 → 用 [tabiew](tabiew.html)

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | `saulpw/visidata`（Python，GPLv3） |
| 安装器 | `scripts/install/install_pipx_tool.sh`（通用 pipx 安装器） |
| 命令 | `visidata`、`vd` 两个入口 |
| 版本 | v3.4（`vd --version` 实测） |

```bash
# 本仓库的安装方式
bash scripts/install/install_pipx_tool.sh visidata visidata vd

# 等价于手动：
pipx install visidata
```

某些格式需要额外的 Python 模块（如 Excel 需要 openpyxl），上游建议：

```bash
pipx inject visidata openpyxl lxml
```

## 基本用法

```bash
vd data.csv            # 打开 CSV
vd data.json           # 打开 JSON（数组会展开成表格）
visidata *.csv         # 多文件，每个文件一个 sheet

# 常用选项（来自 vd(1) 手册）
vd --play cmdlog.vdj          # 回放保存的操作日志
vd --play cmdlog.vdj --batch  # 无界面批处理回放
vd data.csv -o out.tsv        # 配合回放，把最终 sheet 另存
```

## 常用键位

完整清单按 `Ctrl+H`（或 `gCtrl+H` 打开 man 页）。以下来自官方 Quick Reference：

### 全局

| 键 | 作用 |
|---|---|
| `Ctrl+Q` | 立即退出整个程序 |
| `q` | 退出当前 sheet |
| `U` / `R` | 撤销 / 重做 |
| `Space` | 打开命令面板（按 longname 执行） |
| `Ctrl+H` | 查看内置手册 |
| `^^`（Ctrl+^） | 跳到上一个 sheet |

### 移动与搜索

| 键 | 作用 |
|---|---|
| `h j k l` 或方向键 | 左/下/上/右移动 |
| `gg` / `G` | 跳到首行 / 末行 |
| `/` | 在当前列正则向前搜索（`?` 向后） |
| `g/` | 在所有可见列里搜索 |
| `n` / `N` | 下一个 / 上一个匹配 |

### 列操作

| 键 | 作用 |
|---|---|
| `_` | 当前列宽度在「全宽/默认宽」之间切换 |
| `g_` | 所有列自动宽度 |
| `-` | 隐藏当前列（`gv` 全部取消隐藏） |
| `!` | 把当前列设为 key 列 |
| `~ # % $ @` | 当前列类型设为 str/int/float/currency/date |
| `^` | 重命名当前列 |

### 行选择、排序与过滤

| 键 | 作用 |
|---|---|
| `s` / `u` / `t` | 选中 / 取消选中 / 反选当前行 |
| `gs` / `gu` / `gt` | 同上，作用于所有行 |
| `\|` | 按当前列正则选中匹配行（`\` 取消） |
| `[` / `]` | 按当前列升序 / 降序排序 |
| `"` | 打开一个只含选中行的新 sheet |
| `d` | 删除当前行（`gd` 删除选中行） |
| `e` | 编辑当前单元格 |

## 本仓库的配置

- 通过 `install_pipx_tool.sh` 走 pipx，装入 `~/.local/pipx/` 的独立 venv，命令链接到 `~/.local/bin`。
- `init.sh` 在工具段检查 `visidata` 命令，缺失时自动调用安装器。
- 没有放置额外的 VisiData 配置文件；偏好用 `~/.visidatarc` 自定义（上游支持，本仓库未管理）。

## 排错

**打开 Excel 文件报缺模块**：对应格式的 Python 依赖没装。`pipx inject visidata openpyxl` 补上。

**中文/多字节列显示错位**：终端字体与宽度计算问题，尝试 `z_` 手动调窄列或换个支持 East Asian Width 的终端字体。

**大文件打开慢或卡**：某些格式（如 JSON）需要整体加载。纯批量统计换 qsv 的 `stats`，只看不改换 `head -n 1000 file.csv | vd` 先抽样。

**`vd` 命令不存在**：pipx 的 bin 目录不在 PATH。检查 `~/.local/bin` 是否在 PATH 里，或重跑 `install_pipx_tool.sh visidata visidata vd --force`。

**想撤销刚才的编辑**：`U` 撤销。注意撤销依赖 options.undo，正常默认开启。

<!-- lang:en -->

> Summary: VisiData is a terminal spreadsheet multitool; in this repository it is used to explore, clean and reshape CSV/TSV/JSON tabular data interactively, complementing qsv (batch) and tabiew (SQL).

# VisiData

## Purpose

`VisiData` is a terminal spreadsheet browser/editor: it opens CSV, TSV, JSON, Excel and other files as scrollable spreadsheets, and lets the keyboard drive row selection, sorting, filtering, grouping, column editing and regex/Python-expression column derivation, before saving to whatever format you need. The upstream one-liner is "explore, clean, edit, and restructure data".

In this repository it fills the "interactive data-wrangling" slot:

- Want a quick look at what a 50k-row CSV looks like and what types each column has → `vd file.csv`
- Want to filter, sort and compute a frequency table while looking → VisiData
- Want a repeatable script → [qsv](qsv.html)
- Want SQL over local tabular files → [tabiew](tabiew.html)

## Source and install

| Item | Notes |
|---|---|
| Repository | `saulpw/visidata` (Python, GPLv3) |
| Installer | `scripts/install/install_pipx_tool.sh` (generic pipx installer) |
| Commands | both `visidata` and `vd` |
| Version | v3.4 (verified via `vd --version`) |

```bash
# How this repository installs it
bash scripts/install/install_pipx_tool.sh visidata visidata vd

# Equivalent to:
pipx install visidata
```

Some formats need extra Python modules (openpyxl for Excel, for example). Upstream suggests:

```bash
pipx inject visidata openpyxl lxml
```

## Basic usage

```bash
vd data.csv            # open a CSV
vd data.json           # open JSON (arrays expand into a table)
visidata *.csv         # several files, one sheet each

# Common options (from the vd(1) man page)
vd --play cmdlog.vdj          # replay a saved command log in the UI
vd --play cmdlog.vdj --batch  # replay headlessly in batch mode
vd data.csv -o out.tsv        # with replay, save the final sheet
```

## Common keys

The full list is at `Ctrl+H` (`gCtrl+H` opens the man page). The table below comes from the official Quick Reference:

### Global

| Key | Effect |
|---|---|
| `Ctrl+Q` | abort the program immediately |
| `q` | quit the current sheet |
| `U` / `R` | undo / redo |
| `Space` | open the command palette (execute by longname) |
| `Ctrl+H` | open the built-in man page |
| `^^` (Ctrl+^) | jump to the previous sheet |

### Movement and search

| Key | Effect |
|---|---|
| `h j k l` or arrows | left/down/up/right |
| `gg` / `G` | jump to first / last row |
| `/` | regex search forward in the current column (`?` backward) |
| `g/` | search across all visible columns |
| `n` / `N` | next / previous match |

### Columns

| Key | Effect |
|---|---|
| `_` | toggle the current column between full and default width |
| `g_` | auto-fit widths of all visible columns |
| `-` | hide the current column (`gv` unhide all) |
| `!` | toggle the current column as a key column |
| `~ # % $ @` | set the column type to str/int/float/currency/date |
| `^` | rename the current column |

### Row selection, sorting and filtering

| Key | Effect |
|---|---|
| `s` / `u` / `t` | select / unselect / toggle the current row |
| `gs` / `gu` / `gt` | same, over all rows |
| `\|` | select rows matching a regex in the current column (`\` unselects) |
| `[` / `]` | sort ascending / descending by the current column |
| `"` | open a duplicate sheet with only the selected rows |
| `d` | delete the current row (`gd` deletes selected rows) |
| `e` | edit the current cell |

## In this repository

- Installed via pipx through `install_pipx_tool.sh`, into a dedicated venv under `~/.local/pipx/` with commands linked into `~/.local/bin`.
- `init.sh` checks for the `visidata` command in its tools section and calls the installer when missing.
- No extra VisiData configuration is managed here; personal preferences go into `~/.visidatarc` (supported upstream, not managed by this repo).

## Troubleshooting

**Missing-module error when opening Excel**: the Python dependency for that format is absent. Add it with `pipx inject visidata openpyxl`.

**CJK/wide characters misalign**: terminal font and width calculation; try narrowing the column with `z_` or switch to a font with East Asian Width support.

**Large files open slowly or stall**: some formats (JSON, for instance) load fully. For pure batch statistics use qsv's `stats`; for a peek only, sample first: `head -n 1000 file.csv | vd`.

**`vd` not found**: pipx's bin directory is not on PATH. Check that `~/.local/bin` is on PATH, or rerun `install_pipx_tool.sh visidata visidata vd --force`.

**Want to undo an edit**: press `U`. Undo requires options.undo, which is on by default.

<!-- lang:ja -->

> 要約：VisiData はターミナル上で動くスプレッドシート万能ツールです。このリポジトリでは CSV/TSV/JSON などの表データを対話的に探索・整形するために使い、バッチ処理の qsv、SQL の tabiew と補完関係にあります。

# VisiData

## 役割

`VisiData` はターミナル上の表データブラウザ／エディタです。CSV、TSV、JSON、Excel などのファイルをスクロール可能なスプレッドシートとして開き、キーボードで行の選択、ソート、フィルタ、グループ化、列の編集、正規表現や Python 式による派生列の作成などを行い、最後に好きな形式で保存できます。公式の説明は「explore, clean, edit, and restructure data」です。

このリポジトリでは「対話的なデータ整理」の担当です：

- 数万行の CSV の中身や各列の型をさっと確認したい → `vd file.csv`
- 見ながら絞り込み・ソート・度数分布を作りたい → VisiData
- スクリプトとして繰り返し実行したい → [qsv](qsv.html)
- ローカルの表ファイルに SQL を投げたい → [tabiew](tabiew.html)

## 入手とインストール

| 項目 | 説明 |
|---|---|
| リポジトリ | `saulpw/visidata`（Python，GPLv3） |
| インストーラ | `scripts/install/install_pipx_tool.sh`（汎用 pipx インストーラ） |
| コマンド | `visidata` と `vd` の 2 つの入口 |
| バージョン | v3.4（`vd --version` で確認済み） |

```bash
# このリポジトリのインストール方法
bash scripts/install/install_pipx_tool.sh visidata visidata vd

# 手動では以下と同等：
pipx install visidata
```

一部の形式には追加の Python モジュールが必要です（Excel には openpyxl など）。上游の推奨は：

```bash
pipx inject visidata openpyxl lxml
```

## 基本的な使い方

```bash
vd data.csv            # CSV を開く
vd data.json           # JSON を開く（配列は表に展開）
visidata *.csv         # 複数ファイル、各ファイルが 1 シート

# よく使うオプション（vd(1) マニュアルより）
vd --play cmdlog.vdj          # 保存した操作ログを UI 内で再生
vd --play cmdlog.vdj --batch  # UI なしのバッチ再生
vd data.csv -o out.tsv        # 再生と併用で最終シートを保存
```

## 主なキー

完全な一覧は `Ctrl+H`（`gCtrl+H` でマニュアル）で見られます。以下は公式 Quick Reference からの抜粋です：

### グローバル

| キー | 効果 |
|---|---|
| `Ctrl+Q` | プログラムを即終了 |
| `q` | 現在のシートを終了 |
| `U` / `R` | 元に戻す／やり直す |
| `Space` | コマンドパレットを開く（longname で実行） |
| `Ctrl+H` | 内蔵マニュアルを表示 |
| `^^`（Ctrl+^） | 前のシートへジャンプ |

### 移動と検索

| キー | 効果 |
|---|---|
| `h j k l` または矢印 | 左／下／上／右へ移動 |
| `gg` / `G` | 先頭行／最終行へ |
| `/` | 現在列を正規表現で前方検索（`?` は後方） |
| `g/` | 表示中の全列を検索 |
| `n` / `N` | 次／前のマッチへ |

### 列操作

| キー | 効果 |
|---|---|
| `_` | 現在列の幅を全幅／既定幅で切替 |
| `g_` | 表示中の全列を自動幅 |
| `-` | 現在列を非表示（`gv` で全解除） |
| `!` | 現在列をキー列に設定／解除 |
| `~ # % $ @` | 現在列の型を str/int/float/currency/date に設定 |
| `^` | 現在列をリネーム |

### 行の選択・ソート・フィルタ

| キー | 効果 |
|---|---|
| `s` / `u` / `t` | 現在行を選択／解除／トグル |
| `gs` / `gu` / `gt` | 同じ操作を全行に適用 |
| `\|` | 現在列の正規表現に一致する行を選択（`\` は解除） |
| `[` / `]` | 現在列で昇順／降順ソート |
| `"` | 選択行だけの複製シートを開く |
| `d` | 現在行を削除（`gd` は選択行） |
| `e` | 現在のセルを編集 |

## このリポジトリでの扱い

- `install_pipx_tool.sh` 経由で pipx により導入。`~/.local/pipx/` 配下の独立 venv に入り、コマンドは `~/.local/bin` にリンクされます。
- `init.sh` はツール導入部で `visidata` コマンドを確認し、無ければインストーラを呼びます。
- VisiData 固有の追加設定ファイルは管理していません。好みに応じて `~/.visidatarc` を使えます（上游でサポート、本リポジトリでは未管理）。

## トラブルシュート

**Excel を開くとモジュール不足のエラー**：その形式用の Python 依存が無い。`pipx inject visidata openpyxl` で追加。

**日本語など全角文字の表示がずれる**：ターミナルのフォントと幅計算の問題。`z_` で列を狭めるか、East Asian Width 対応フォントに切り替える。

**大きなファイルのオープンが遅い／固まる**：JSON などは全体を読み込む形式がある。純粋なバッチ統計は qsv の `stats` へ、見るだけなら `head -n 1000 file.csv | vd` で先にサンプル。

**`vd` コマンドが無い**：pipx の bin ディレクトリが PATH に無い。`~/.local/bin` が PATH にあるか確認し、無ければ `install_pipx_tool.sh visidata visidata vd --force` を再実行。

**編集を取り消したい**：`U` で undo。undo は options.undo に依存しますが、既定で有効です。
