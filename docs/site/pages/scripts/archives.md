> 摘要：packtar 按 gitignore 打包当前目录，三个解压脚本处理 zip 的方式各不相同。

# 归档工具

## packtar

### 用途

把当前目录打成 `tar.gz` 放到**父目录**，自动应用 `.gitignore` 和 `.tar-exclude` 规则。

### 用法

```bash
packtar myarchive                 # 输出 ../myarchive.tar.gz
packtar --day 7 myarchive         # 只打包最近 7 天变更的文件
packtar --day 30 backup           # 最近 30 天
```

### 默认行为

**只打包最近一天有变化的文件**（`DAY_RANGE=1`）。这不是完整备份。

```bash
DAY_RANGE=1
...
if date -d "now - ${DAY_RANGE} days" >/dev/null 2>&1; then
    touch -d "now - ${DAY_RANGE} days" "${TODAY_MARKER_FILE}"
```

然后只包含比这个时间戳新的文件。

### 排除规则

优先级从高到低：

1. `--exclude=".git"` 和 `--exclude=".git/*"` — 硬编码
2. `.tar-exclude` 文件 — `--exclude-from`
3. `.gitignore` — 通过 `git ls-files` 生成文件列表

```bash
if [ -f "$GITIGNORE_FILE" ]; then
    GITIGNORE_MATCHES="$(git -C "${CURRENT_DIR}" ls-files -i -o --exclude-standard --directory)"
    ...
    git -C "${CURRENT_DIR}" ls-files -z --cached --others --exclude-standard | ...
fi
```

用 `git ls-files --cached --others --exclude-standard` 列出「已跟踪 + 未跟踪但未被忽略」的文件，天然应用了 `.gitignore`。

### 输出

```text
Creating archive: /home/user/project -> /home/user/myarchive.tar.gz
Found: /home/user/project/.gitignore (applying gitignore exclusions)
Excluded files (from gitignore):
  node_modules/
  dist/
Exclusion rule: generate the file list with git ls-files
Exclusion rule: generate the file list with git ls-files (last 1 days)
Archive created: /home/user/myarchive.tar.gz (2.3M)
```

### 不是备份工具

它只打包**最近变更**的文件，且排除 gitignore 的内容。想完整备份：

```bash
tar czf ../full-backup.tar.gz --exclude=.git .
```

### 空格处理

```bash
if tar --help 2>/dev/null | "${TAR_HELP_MATCHER[@]}" "--null"; then
    TAR_SUPPORTS_NULL=1
fi
```

支持 `--null` 时用 NUL 分隔传文件名，正确处理带空格和换行的路径。不支持时打印警告。

## 三个解压脚本

### unzip_here.sh

```bash
find "$BASE_DIR" -type f -name '*.zip' -print0 | while IFS= read -r -d '' zip_file; do
  dir=$(dirname "$zip_file")
  echo "Extracting: $zip_file -> $dir"
  unzip -n -d "$dir" "$zip_file"
done
```

| 特性 | 说明 |
|---|---|
| 递归 | 是 |
| 解压到 | zip 所在目录 |
| 覆盖 | 否（`-n`） |
| 入口 | `unzip:here` 别名 |

### unzip_all.sh

```bash
target_dir="$parent_dir/$zip_name"
mkdir -p "$target_dir"
unzip -n -d "$target_dir" "$zip_file"
```

| 特性 | 说明 |
|---|---|
| 递归 | 是 |
| 解压到 | 每个 zip 的同名子目录 |
| 覆盖 | 否 |

与 `unzip_here.sh` 的区别：这个会建子目录，避免多个 zip 的内容混在一起。

### 旧版内联脚本

`tools/unzip_all.sh` 里还有一段只处理当前目录的版本：

```bash
for f in *.zip; do
  dir="${f%.zip}"
  mkdir -p "$dir"
  unzip -n "$f" -d "$dir"
done
```

不递归，只在当前目录工作。

### 对照表

| 脚本 | 递归 | 目标目录 | 适合 |
|---|---|---|---|
| `unzip_here.sh` | 是 | zip 所在目录 | 内容不冲突 |
| `unzip_all.sh` | 是 | 同名子目录 | 多个 zip 并存 |
| 内联版本 | 否 | 同名子目录 | 单目录快速处理 |

## open_windows_folder.sh

```bash
if [[ $# -eq 0 ]]; then
  folder_path=$(wslpath -w "$PWD")
else
  IFS=' '
  folder_path="$*"
fi
explorer.exe "${folder_path}"
```

WSL 专用：把路径转成 Windows 格式，用资源管理器打开。

`IFS=' '` + `"$*"` 是为了处理「未加引号导致路径被拆成多个参数」的情况。

## 排错

**packtar 打的包很小**：默认只含最近一天的文件。用 `--day 30` 放宽。

**packtar 提示「no files were updated」**：时间窗内没有变更。调大 `--day`。

**解压后文件散落**：用了 `unzip_here.sh`。改用 `unzip_all.sh` 建子目录。

**带空格的文件名出错**：tar 不支持 `--null` 时会警告。升级 tar 或避免空格。

**`unzip: command not found`**：`sudo apt install unzip`。

**open_windows_folder 在非 WSL 上失败**：需要 `explorer.exe`，只有 WSL 有。

<!-- lang:en -->

> Summary: packtar packs the current directory honoring gitignore, and the three extraction scripts each handle zip files differently.

# Archive Tools

## packtar

### Purpose

Packs the current directory into a `tar.gz` placed in the **parent directory**, automatically applying `.gitignore` and `.tar-exclude` rules.

### Usage

```bash
packtar myarchive                 # 输出 ../myarchive.tar.gz
packtar --day 7 myarchive         # 只打包最近 7 天变更的文件
packtar --day 30 backup           # 最近 30 天
```

### Default Behavior

**Only files changed within the last day are packed** (`DAY_RANGE=1`). This is not a full backup.

```bash
DAY_RANGE=1
...
if date -d "now - ${DAY_RANGE} days" >/dev/null 2>&1; then
    touch -d "now - ${DAY_RANGE} days" "${TODAY_MARKER_FILE}"
```

Then only files newer than that timestamp are included.

### Exclusion Rules

In priority order from high to low:

1. `--exclude=".git"` and `--exclude=".git/*"` — hardcoded
2. The `.tar-exclude` file — `--exclude-from`
3. `.gitignore` — the file list is generated via `git ls-files`

```bash
if [ -f "$GITIGNORE_FILE" ]; then
    GITIGNORE_MATCHES="$(git -C "${CURRENT_DIR}" ls-files -i -o --exclude-standard --directory)"
    ...
    git -C "${CURRENT_DIR}" ls-files -z --cached --others --exclude-standard | ...
fi
```

`git ls-files --cached --others --exclude-standard` lists "tracked + untracked but not ignored" files, so `.gitignore` is applied naturally.

### Output

```text
Creating archive: /home/user/project -> /home/user/myarchive.tar.gz
Found: /home/user/project/.gitignore (applying gitignore exclusions)
Excluded files (from gitignore):
  node_modules/
  dist/
Exclusion rule: generate the file list with git ls-files
Exclusion rule: generate the file list with git ls-files (last 1 days)
Archive created: /home/user/myarchive.tar.gz (2.3M)
```

### Not a Backup Tool

It only packs **recently changed** files and excludes anything matching gitignore. For a full backup:

```bash
tar czf ../full-backup.tar.gz --exclude=.git .
```

### Handling Spaces

```bash
if tar --help 2>/dev/null | "${TAR_HELP_MATCHER[@]}" "--null"; then
    TAR_SUPPORTS_NULL=1
fi
```

When `--null` is supported, filenames are passed NUL-separated, so paths containing spaces and newlines are handled correctly. When it is not supported, a warning is printed.

## The Three Extraction Scripts

### unzip_here.sh

```bash
find "$BASE_DIR" -type f -name '*.zip' -print0 | while IFS= read -r -d '' zip_file; do
  dir=$(dirname "$zip_file")
  echo "Extracting: $zip_file -> $dir"
  unzip -n -d "$dir" "$zip_file"
done
```

| Feature | Description |
|---|---|
| Recursive | Yes |
| Extracts to | The directory containing the zip |
| Overwrites | No (`-n`) |
| Entry point | `unzip:here` alias |

### unzip_all.sh

```bash
target_dir="$parent_dir/$zip_name"
mkdir -p "$target_dir"
unzip -n -d "$target_dir" "$zip_file"
```

| Feature | Description |
|---|---|
| Recursive | Yes |
| Extracts to | A subdirectory named after each zip |
| Overwrites | No |

Difference from `unzip_here.sh`: this one creates a subdirectory, keeping the contents of multiple zips from mixing together.

### Legacy Inline Script

`tools/unzip_all.sh` also contains a version that only handles the current directory:

```bash
for f in *.zip; do
  dir="${f%.zip}"
  mkdir -p "$dir"
  unzip -n "$f" -d "$dir"
done
```

Not recursive; it only works in the current directory.

### Comparison Table

| Script | Recursive | Target directory | Best for |
|---|---|---|---|
| `unzip_here.sh` | Yes | The zip's own directory | Contents that don't collide |
| `unzip_all.sh` | Yes | Same-named subdirectory | Multiple zips side by side |
| Inline version | No | Same-named subdirectory | Quick one-directory jobs |

## open_windows_folder.sh

```bash
if [[ $# -eq 0 ]]; then
  folder_path=$(wslpath -w "$PWD")
else
  IFS=' '
  folder_path="$*"
fi
explorer.exe "${folder_path}"
```

WSL-only: converts the path to Windows format and opens it in Explorer.

`IFS=' '` + `"$*"` handles the case where "an unquoted path got split into multiple arguments".

## Troubleshooting

**packtar archives are tiny**: by default only files from the last day are included. Loosen it with `--day 30`.

**packtar says "no files were updated"**: nothing changed within the time window. Increase `--day`.

**Files scattered after extraction**: you used `unzip_here.sh`. Switch to `unzip_all.sh` to get subdirectories.

**Errors with filenames containing spaces**: tar warns when it doesn't support `--null`. Upgrade tar or avoid spaces.

**`unzip: command not found`**: `sudo apt install unzip`.

**open_windows_folder fails off WSL**: it needs `explorer.exe`, which only exists in WSL.

<!-- lang:ja -->

> 要約：packtar は gitignore を守ってカレントディレクトリを固め、3 つの解凍スクリプトはそれぞれ zip の扱い方が違います。

# アーカイブツール

## packtar

### 役割

カレントディレクトリを**親ディレクトリ**に `tar.gz` として固めます。`.gitignore` と `.tar-exclude` のルールを自動的に適用します。

### 使い方

```bash
packtar myarchive                 # 输出 ../myarchive.tar.gz
packtar --day 7 myarchive         # 只打包最近 7 天变更的文件
packtar --day 30 backup           # 最近 30 天
```

### デフォルトの動作

**直近 1 日以内に変更のあったファイルだけを梱包します**（`DAY_RANGE=1`）。完全バックアップではありません。

```bash
DAY_RANGE=1
...
if date -d "now - ${DAY_RANGE} days" >/dev/null 2>&1; then
    touch -d "now - ${DAY_RANGE} days" "${TODAY_MARKER_FILE}"
```

その後、このタイムスタンプより新しいファイルだけを含めます。

### 除外ルール

優先度の高い順：

1. `--exclude=".git"` と `--exclude=".git/*"` — ハードコード
2. `.tar-exclude` ファイル — `--exclude-from`
3. `.gitignore` — `git ls-files` でファイルリストを生成

```bash
if [ -f "$GITIGNORE_FILE" ]; then
    GITIGNORE_MATCHES="$(git -C "${CURRENT_DIR}" ls-files -i -o --exclude-standard --directory)"
    ...
    git -C "${CURRENT_DIR}" ls-files -z --cached --others --exclude-standard | ...
fi
```

`git ls-files --cached --others --exclude-standard` は「追跡済み + 未追跡だが無視されていない」ファイルを列挙するので、`.gitignore` が自然に適用されます。

### 出力

```text
Creating archive: /home/user/project -> /home/user/myarchive.tar.gz
Found: /home/user/project/.gitignore (applying gitignore exclusions)
Excluded files (from gitignore):
  node_modules/
  dist/
Exclusion rule: generate the file list with git ls-files
Exclusion rule: generate the file list with git ls-files (last 1 days)
Archive created: /home/user/myarchive.tar.gz (2.3M)
```

### バックアップツールではない

**最近の変更**があったファイルだけを梱包し、gitignore の内容は除外します。完全バックアップを取りたい場合は：

```bash
tar czf ../full-backup.tar.gz --exclude=.git .
```

### 空白の処理

```bash
if tar --help 2>/dev/null | "${TAR_HELP_MATCHER[@]}" "--null"; then
    TAR_SUPPORTS_NULL=1
fi
```

`--null` に対応している場合は NUL 区切りでファイル名を渡すので、空白や改行を含むパスも正しく扱えます。非対応の場合は警告を表示します。

## 3 つの解凍スクリプト

### unzip_here.sh

```bash
find "$BASE_DIR" -type f -name '*.zip' -print0 | while IFS= read -r -d '' zip_file; do
  dir=$(dirname "$zip_file")
  echo "Extracting: $zip_file -> $dir"
  unzip -n -d "$dir" "$zip_file"
done
```

| 特徴 | 説明 |
|---|---|
| 再帰 | あり |
| 解凍先 | zip があるディレクトリ |
| 上書き | なし（`-n`） |
| 入口 | `unzip:here` エイリアス |

### unzip_all.sh

```bash
target_dir="$parent_dir/$zip_name"
mkdir -p "$target_dir"
unzip -n -d "$target_dir" "$zip_file"
```

| 特徴 | 説明 |
|---|---|
| 再帰 | あり |
| 解凍先 | zip ごとに同名のサブディレクトリ |
| 上書き | なし |

`unzip_here.sh` との違い：こちらはサブディレクトリを作るので、複数の zip の中身が混ざりません。

### 旧インラインスクリプト

`tools/unzip_all.sh` にはカレントディレクトリだけを扱うバージョンも残っています：

```bash
for f in *.zip; do
  dir="${f%.zip}"
  mkdir -p "$dir"
  unzip -n "$f" -d "$dir"
done
```

再帰せず、カレントディレクトリだけで動きます。

### 比較表

| スクリプト | 再帰 | 展開先 | 向いている場面 |
|---|---|---|---|
| `unzip_here.sh` | あり | zip があるディレクトリ | 中身が衝突しないとき |
| `unzip_all.sh` | あり | 同名サブディレクトリ | 複数 zip が並ぶとき |
| インライン版 | なし | 同名サブディレクトリ | 単一ディレクトリのさっとした処理 |

## open_windows_folder.sh

```bash
if [[ $# -eq 0 ]]; then
  folder_path=$(wslpath -w "$PWD")
else
  IFS=' '
  folder_path="$*"
fi
explorer.exe "${folder_path}"
```

WSL 専用：パスを Windows 形式に変換してエクスプローラーで開きます。

`IFS=' '` + `"$*"` は「引用符がなくてパスが複数の引数に分割された」ケースを処理するためのものです。

## トラブルシューティング

**packtar のアーカイブが小さい**：デフォルトでは直近 1 日のファイルしか入りません。`--day 30` で緩めます。

**packtar が「no files were updated」と言う**：時間窓内に変更がなかったということです。`--day` を大きくします。

**解凍後にファイルが散らばる**：`unzip_here.sh` を使ったときです。サブディレクトリを作る `unzip_all.sh` に切り替えます。

**空白を含むファイル名でエラー**：tar が `--null` 非対応のときは警告が出ます。tar を更新するか空白を避けてください。

**`unzip: command not found`**：`sudo apt install unzip`。

**open_windows_folder が WSL 以外で失敗する**：`explorer.exe` が必要で、WSL にしかありません。
