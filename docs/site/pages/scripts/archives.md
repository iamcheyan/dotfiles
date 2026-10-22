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
