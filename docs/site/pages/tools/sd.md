> 摘要：sd 用直观的字面/正则替换，比 sed 的转义规则简单。

# sd

## 用途

`sd`（search and displace）是 `sed 's/old/new/'` 的替代。它的核心改进是：**正则和替换文本都按你写的字面意思处理**，不需要记住 sed 的反斜杠转义规则。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |

```zsh
zi_cmd chmln/sd sd
```

## 基本用法

```bash
sd 'old' 'new' file.txt          # 替换并输出到 stdout
sd -i 'old' 'new' file.txt       # 原地修改
sd 'old' 'new' file1 file2       # 多文件
```

## 与 sed 的对照

| 需求 | sed | sd |
|---|---|---|
| 简单替换 | `sed 's/old/new/'` | `sd 'old' 'new'` |
| 原地修改 | `sed -i 's/a/b/'` | `sd -i 'a' 'b'` |
| 捕获组 | `sed -E 's/(a)(b)/\2\1/'` | `sd '(a)(b)' '$2$1'` |
| 字面括号 | `sed 's/(//'` | `sd -F '(' ''` |
| 多文件 | `sed -i ... file*` | `sd -i ... file*` |

关键差异：**sd 默认就用正则**，不需要 `-E`；捕获组用 `$1` 而不是 `\1`；想匹配字面字符串用 `-F`。

## 常用参数

| 参数 | 作用 |
|---|---|
| `-i` / `--in-place` | 原地修改文件 |
| `-F` / `--fixed-strings` | 按字面字符串匹配，不当正则 |
| `-f` / `--flags` | 正则标志，如 `-f i` 忽略大小写 |
| `-n` / `--max-replacements` | 每个文件最多替换几次 |
| `-p` / `--preview` | 预览变更（不写入） |
| `-s` / `--string-mode` | 同 `-F`（旧名） |
| `--dry-run` | 显示将要做的替换 |

## 实用例子

```bash
# 简单替换
sd 'foo' 'bar' file.txt

# 捕获组重排
sd '(\w+)@(\w+)' '$2 at $1' emails.txt

# 字面匹配特殊字符
sd -F 'a.b' 'x' file.txt

# 忽略大小写
sd -f i 'error' 'warning' log.txt

# 只替换第一次
sd -n 1 'old' 'new' file.txt

# 预览
sd -p 'old' 'new' file.txt

# 批量改文件
sd -i 'console\.log' 'logger.info' src/*.js

# 用管道
cat file | sd 'a' 'b'
```

## 捕获组语法

sd 用 `$1`、`$2` 引用捕获组，不像 sed 的 `\1`：

```bash
# 把 "key: value" 改成 "value = key"
sd '(\w+): (\w+)' '$2 = $1' file.txt

# 命名捕获组
sd '(?P<name>\w+)@(?P<domain>\w+)' '$name at $domain' file.txt
```

`$` 本身要转义成 `$$`。

## 在脚本里用

```bash
# 批量替换版本号
sd -i 'version = "[0-9.]+"' 'version = "2.0.0"' pyproject.toml

# 去掉行尾空格
sd '[ \t]+$' '' file.txt

# 统一引号
sd -F "'" '"' config.js
```

## 排错

**`sd: command not found`**：Zinit 未下载。

**替换了不该替换的**：默认全局替换。用 `-n 1` 限制次数，或先 `-p` 预览。

**特殊字符匹配不到**：用 `-F` 切字面模式。

**`$` 被当成捕获组引用**：想输出字面 `$` 要写 `$$`。

**`-i` 后文件权限变了**：sd 通过写临时文件再替换实现原地修改，可能不保留权限位。对可执行脚本慎用，或用 `-p` 先看再手动改。

**多行替换**：sd 默认按行处理。跨行替换需要 `(?s)` 标志或改用 perl。

<!-- lang:en -->
> Summary: sd provides intuitive literal and regex replacement with simpler escaping rules than sed.

# sd

## Purpose

`sd` (search and displace) is an alternative to `sed 's/old/new/'`. Its key improvement is that **both the regex and replacement text are handled as written**, so you do not need to memorize sed's backslash escaping rules.

## Source and installation

| Item | Description |
|---|---|
| Source | Zinit, downloaded from GitHub Release |

## Basic usage

```bash
sd 'old' 'new' file.txt          # 替换并输出到 stdout
sd -i 'old' 'new' file.txt       # 原地修改
sd 'old' 'new' file1 file2       # 多文件
```

## Comparison with sed

| Need | sed | sd |
|---|---|---|
| Simple replacement | `sed 's/old/new/'` | `sd 'old' 'new'` |
| In-place edit | `sed -i 's/a/b/'` | `sd -i 'a' 'b'` |
| Capture groups | `sed -E 's/(a)(b)/\2\1/'` | `sd '(a)(b)' '$2$1'` |
| Literal parentheses | `sed 's/(//'` | `sd -F '(' ''` |
| Multiple files | `sed -i ... file*` | `sd -i ... file*` |

Key differences: **sd uses regex by default**, so `-E` is unnecessary; capture groups use `$1` instead of `\1`; use `-F` to match literal strings.

## Common options

| Option | Effect |
|---|---|
| `-i` / `--in-place` | Modify files in place |
| `-F` / `--fixed-strings` | Match literal strings instead of regex |
| `-f` / `--flags` | Regex flags, such as `-f i` to ignore case |
| `-n` / `--max-replacements` | Maximum replacements per file |
| `-p` / `--preview` | Preview changes without writing |
| `-s` / `--string-mode` | Same as `-F` (older name) |
| `--dry-run` | Show the replacements that would be made |

## Practical examples

```bash
# 简单替换
sd 'foo' 'bar' file.txt

# 捕获组重排
sd '(\\w+)@(\\w+)' '$2 at $1' emails.txt

# 字面匹配特殊字符
sd -F 'a.b' 'x' file.txt

# 忽略大小写
sd -f i 'error' 'warning' log.txt

# 只替换第一次
sd -n 1 'old' 'new' file.txt

# 预览
sd -p 'old' 'new' file.txt

# 批量改文件
sd -i 'console\\.log' 'logger.info' src/*.js

# 用管道
cat file | sd 'a' 'b'
```

## Capture group syntax

sd refers to capture groups with `$1`, `$2`, unlike sed's `\1`:

`$` itself must be escaped as `$$`.

```bash
# 把 "key: value" 改成 "value = key"
sd '(\\w+): (\\w+)' '$2 = $1' file.txt

# 命名捕获组
sd '(?P<name>\\w+)@(?P<domain>\\w+)' '$name at $domain' file.txt
```

## Use in scripts

```bash
# 批量替换版本号
sd -i 'version = "[0-9.]+"' 'version = "2.0.0"' pyproject.toml

# 去掉行尾空格
sd '[ \\t]+$' '' file.txt

# 统一引号
sd -F "'" '"' config.js
```

## Troubleshooting

**`sd: command not found`**: Zinit has not downloaded it.

**Replaced more than intended**: Replacement is global by default. Limit the count with `-n 1`, or preview first with `-p`.

**Special characters do not match**: Use `-F` to switch to literal mode.

**`$` is treated as a capture reference**: Write `$$` to output a literal `$`.

**File permissions changed after `-i`**: sd performs in-place edits by writing a temporary file and replacing the original, which may not preserve permission bits. Use caution with executable scripts, or preview with `-p` and edit manually.

**Multiline replacement**: sd processes one line at a time by default. Multiline replacement requires the `(?s)` flag or using perl instead.

```zsh
zi_cmd chmln/sd sd
```

```bash
# 简单替换
sd 'foo' 'bar' file.txt

# 捕获组重排
sd '(\w+)@(\w+)' '$2 at $1' emails.txt

# 字面匹配特殊字符
sd -F 'a.b' 'x' file.txt

# 忽略大小写
sd -f i 'error' 'warning' log.txt

# 只替换第一次
sd -n 1 'old' 'new' file.txt

# 预览
sd -p 'old' 'new' file.txt

# 批量改文件
sd -i 'console\.log' 'logger.info' src/*.js

# 用管道
cat file | sd 'a' 'b'
```

```bash
# 把 "key: value" 改成 "value = key"
sd '(\w+): (\w+)' '$2 = $1' file.txt

# 命名捕获组
sd '(?P<name>\w+)@(?P<domain>\w+)' '$name at $domain' file.txt
```

```bash
# 批量替换版本号
sd -i 'version = "[0-9.]+"' 'version = "2.0.0"' pyproject.toml

# 去掉行尾空格
sd '[ \t]+$' '' file.txt

# 统一引号
sd -F "'" '"' config.js
```

<!-- lang:ja -->
> 要約：sd は直感的なリテラル置換と正規表現置換を行い、sed より単純なエスケープ規則を使います。

# sd

## 用途

`sd`（search and displace）は `sed 's/old/new/'` の代替です。主な利点は、**正規表現と置換テキストの両方を記述どおりに扱う**ことです。sed のバックスラッシュによるエスケープ規則を覚える必要がありません。

## 入手元とインストール

| 項目 | 説明 |
|---|---|
| 入手元 | Zinit が GitHub Release からダウンロードします |

## 基本的な使い方

## sed との比較

| 要件 | sed | sd |
|---|---|---|
| 単純な置換 | `sed 's/old/new/'` | `sd 'old' 'new'` |
| ファイル内での変更 | `sed -i 's/a/b/'` | `sd -i 'a' 'b'` |
| キャプチャグループ | `sed -E 's/(a)(b)/\2\1/'` | `sd '(a)(b)' '$2$1'` |
| 括弧を文字として照合 | `sed 's/(//'` | `sd -F '(' ''` |
| 複数ファイル | `sed -i ... file*` | `sd -i ... file*` |

主な違い：**sd は既定で正規表現を使う**ため `-E` は不要です。キャプチャグループには `\1` ではなく `$1` を使い、文字列をそのまま照合するには `-F` を使います。

## よく使うオプション

| オプション | 効果 |
|---|---|
| `-i` / `--in-place` | ファイルを直接変更します |
| `-F` / `--fixed-strings` | 正規表現ではなく文字列そのものを照合します |
| `-f` / `--flags` | `-f i` で大文字小文字を無視するなど、正規表現フラグを指定します |
| `-n` / `--max-replacements` | ファイルごとの置換回数の上限です |
| `-p` / `--preview` | 書き込まずに変更をプレビューします |
| `-s` / `--string-mode` | `-F` と同じです（旧名） |
| `--dry-run` | 実行される置換を表示します |

## 実用例

## キャプチャグループの構文

sd は sed の `\1` と異なり、キャプチャグループを `$1`、`$2` で参照します。

`$` 自体は `$$` としてエスケープします。

## スクリプトでの使用

## トラブルシューティング

**`sd: command not found`**：Zinit がまだダウンロードしていません。

**意図より多く置換されました**：既定ではすべて置換します。`-n 1` で回数を制限するか、先に `-p` でプレビューします。

**特殊文字に一致しません**：`-F` でリテラルモードに切り替えます。

**`$` がキャプチャ参照として扱われます**：文字としての `$` を出力するには `$$` と書きます。

**`-i` の後にファイル権限が変わりました**：sd は一時ファイルを書いて置き換える方法で直接編集するため、権限ビットが保たれない場合があります。実行可能スクリプトでは注意するか、`-p` で確認して手動で編集します。

**複数行の置換**：sd は既定で行ごとに処理します。複数行の置換には `(?s)` フラグを使うか、perl を使います。

```zsh
zi_cmd chmln/sd sd
```

```bash
sd 'old' 'new' file.txt          # 替换并输出到 stdout
sd -i 'old' 'new' file.txt       # 原地修改
sd 'old' 'new' file1 file2       # 多文件
```

```bash
# 简单替换
sd 'foo' 'bar' file.txt

# 捕获组重排
sd '(\w+)@(\w+)' '$2 at $1' emails.txt

# 字面匹配特殊字符
sd -F 'a.b' 'x' file.txt

# 忽略大小写
sd -f i 'error' 'warning' log.txt

# 只替换第一次
sd -n 1 'old' 'new' file.txt

# 预览
sd -p 'old' 'new' file.txt

# 批量改文件
sd -i 'console\.log' 'logger.info' src/*.js

# 用管道
cat file | sd 'a' 'b'
```

```bash
# 把 "key: value" 改成 "value = key"
sd '(\w+): (\w+)' '$2 = $1' file.txt

# 命名捕获组
sd '(?P<name>\w+)@(?P<domain>\w+)' '$name at $domain' file.txt
```

```bash
# 批量替换版本号
sd -i 'version = "[0-9.]+"' 'version = "2.0.0"' pyproject.toml

# 去掉行尾空格
sd '[ \t]+$' '' file.txt

# 统一引号
sd -F "'" '"' config.js
```
