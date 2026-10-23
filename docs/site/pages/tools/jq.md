> 摘要：jq 是 JSON 查询与改写工具，本仓库用它处理 GitHub API 响应和脚本里的结构化数据。

# jq

## 用途

`jq` 是 JSON 的命令行处理器：从 JSON 里抽取字段、过滤数组、重组结构、格式化输出。它有自己的小型表达式语言。

本仓库在两处依赖它：`nvim-update` 解析 GitHub Release API，以及 `scripts/tests/nvim_update_test.sh` 生成测试 fixture。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 特殊说明 | `--minimal` 模式会跳过 jq 的安装 |

```zsh
zi_cmd jqlang/jq jq
```

## 基本用法

```bash
jq '.' file.json                   # 格式化
jq '.name' file.json               # 取字段
jq '.items[]' file.json            # 展开数组
jq -r '.name' file.json            # 原始字符串（去引号）
curl -s api | jq '.data[0].id'     # 管道
```

## 表达式基础

| 表达式 | 含义 |
|---|---|
| `.` | 整个输入 |
| `.key` | 取字段 |
| `.key.nested` | 嵌套字段 |
| `.[0]` | 数组第一个元素 |
| `.[]` | 展开所有元素 |
| `.[1:3]` | 切片 |
| `.a, .b` | 同时输出两个 |
| `.a \| .b` | 管道 |
| `map(.x)` | 对数组每个元素取 `.x` |
| `select(.x > 1)` | 过滤 |
| `length` | 长度 |
| `keys` | 键列表 |
| `to_entries` | 转成 key/value 数组 |

## 常用参数

| 参数 | 作用 |
|---|---|
| `-r` / `--raw-output` | 字符串不带引号 |
| `-c` / `--compact-output` | 单行输出 |
| `-e` / `--exit-status` | 根据结果设置退出码（false/null → 1） |
| `-n` / `--null-input` | 不读输入，从 null 开始 |
| `-s` / `--slurp` | 把所有输入读成一个数组 |
| `-R` / `--raw-input` | 输入当纯文本而非 JSON |
| `--arg k v` | 传入字符串变量 `$k` |
| `--argjson k v` | 传入 JSON 变量 |
| `--tab` | 用 Tab 缩进 |
| `--sort-keys` | 输出时键排序 |
| `-j` / `--join-output` | 不加换行 |

## 本仓库里的用法

### nvim-update 解析 release

```bash
tag="$(jq -er '.tag_name | strings | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))' "$release_json")"

asset_url="$(jq -er --arg name "$asset_name" \
  '.assets[] | select(.name == $name) | .browser_download_url | strings | select(length > 0)' \
  "$release_json")"

expected_digest="$(jq -er --arg name "$asset_name" \
  '.assets[] | select(.name == $name) | .digest | strings
   | select(test("^sha256:[0-9a-fA-F]{64}$")) | sub("^sha256:"; "")' \
  "$release_json")"
```

三个技巧值得注意：

1. **`-e`** — 结果为空或 null 时返回非零退出码，配合 `|| fail` 让脚本在数据缺失时立即失败。
2. **`-r`** — 输出去掉引号，方便直接赋给变量。
3. **`| strings | select(...)`** — 先确认类型是字符串，再校验格式。防止上游 API 返回 null 或对象时静默通过。

### 测试 fixture

```bash
jq -n --arg tag 'v0.12.5' --arg name 'nvim-linux-x86_64.tar.gz' \
  --arg url "$asset_url" --arg digest "sha256:$digest" \
  '{tag_name: $tag, assets: [{name: $name, browser_download_url: $url, digest: $digest}]}'
```

`-n` 不需要输入文件，`--arg` 注入变量，直接用表达式构造 JSON。测试靠它生成假的 GitHub 响应，避免真实下载。

## 实用模式

```bash
# 提取所有 id
jq -r '.[].id' data.json

# 过滤
jq '.[] | select(.status == "active")' data.json

# 重组
jq '{name: .login, repos: .public_repos}' user.json

# 数组转对象
jq 'map({(.id|tostring): .name}) | add' data.json

# 多文件合并
jq -s 'add' a.json b.json

# 检查字段存在
jq -e 'has("error")' response.json

# 美化并排序
jq -S '.' data.json
```


## 排错

**`jq: error: Cannot index array with string`**：对数组用了 `.key`。先 `.[]` 展开。

**输出带引号**：忘了 `-r`。

**空结果但退出码是 0**：加了 `-e` 才会在 null/false 时返回非零。

**中文被转义成 `\uXXXX`**：jq 默认不转义非 ASCII，但如果输入本身是转义的，需要 `--raw-output` 或 `-j`。

**`--arg` 传的值类型不对**：`--arg` 总是字符串，数字用 `--argjson`。


<!-- lang:en -->

> Summary: jq is a JSON query and rewrite tool; this repository uses it to process GitHub API responses and structured data in scripts.

# jq

## Purpose

`jq` is a command-line JSON processor: extract fields from JSON, filter arrays, restructure data, and format output. It has its own small expression language.

This repository depends on it in two places: `nvim-update` parses the GitHub Release API, and `scripts/tests/nvim_update_test.sh` generates test fixtures.

## Source and install

| Item | Notes |
|---|---|
| Source | Zinit, downloaded from GitHub Release |
| Special note | `--minimal` mode skips the jq install |

```zsh
zi_cmd jqlang/jq jq
```

## Basic usage

```bash
jq '.' file.json                   # 格式化
jq '.name' file.json               # 取字段
jq '.items[]' file.json            # 展开数组
jq -r '.name' file.json            # 原始字符串（去引号）
curl -s api | jq '.data[0].id'     # 管道
```

## Expression basics

| Expression | Meaning |
|---|---|
| `.` | the entire input |
| `.key` | access a field |
| `.key.nested` | nested field |
| `.[0]` | first element of an array |
| `.[]` | expand all elements |
| `.[1:3]` | slice |
| `.a, .b` | output both at once |
| `.a \| .b` | pipe |
| `map(.x)` | take `.x` from each element of an array |
| `select(.x > 1)` | filter |
| `length` | length |
| `keys` | list of keys |
| `to_entries` | convert into a key/value array |

## Common flags

| Flag | Effect |
|---|---|
| `-r` / `--raw-output` | strings without quotes |
| `-c` / `--compact-output` | single-line output |
| `-e` / `--exit-status` | set the exit code based on the result (false/null → 1) |
| `-n` / `--null-input` | don't read input, start from null |
| `-s` / `--slurp` | read all input into a single array |
| `-R` / `--raw-input` | treat input as plain text instead of JSON |
| `--arg k v` | pass a string variable `$k` |
| `--argjson k v` | pass a JSON variable |
| `--tab` | indent with tabs |
| `--sort-keys` | sort keys in the output |
| `-j` / `--join-output` | no trailing newline |

## Usage in this repository

### nvim-update parsing a release

```bash
tag="$(jq -er '.tag_name | strings | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))' "$release_json")"

asset_url="$(jq -er --arg name "$asset_name" \
  '.assets[] | select(.name == $name) | .browser_download_url | strings | select(length > 0)' \
  "$release_json")"

expected_digest="$(jq -er --arg name "$asset_name" \
  '.assets[] | select(.name == $name) | .digest | strings
   | select(test("^sha256:[0-9a-fA-F]{64}$")) | sub("^sha256:"; "")' \
  "$release_json")"
```

Three techniques are worth noting:

1. **`-e`** — returns a non-zero exit code when the result is empty or null; combined with `|| fail`, the script fails immediately when data is missing.
2. **`-r`** — strips the quotes from the output so it can be assigned straight into a variable.
3. **`| strings | select(...)`** — confirms the type is a string before validating the format. This prevents things from silently passing when the upstream API returns null or an object.

### Test fixture

```bash
jq -n --arg tag 'v0.12.5' --arg name 'nvim-linux-x86_64.tar.gz' \
  --arg url "$asset_url" --arg digest "sha256:$digest" \
  '{tag_name: $tag, assets: [{name: $name, browser_download_url: $url, digest: $digest}]}'
```

`-n` needs no input file, `--arg` injects variables, and the expression builds the JSON directly. The tests use it to fabricate GitHub responses, avoiding real downloads.

## Useful patterns

```bash
# 提取所有 id
jq -r '.[].id' data.json

# 过滤
jq '.[] | select(.status == "active")' data.json

# 重组
jq '{name: .login, repos: .public_repos}' user.json

# 数组转对象
jq 'map({(.id|tostring): .name}) | add' data.json

# 多文件合并
jq -s 'add' a.json b.json

# 检查字段存在
jq -e 'has("error")' response.json

# 美化并排序
jq -S '.' data.json
```


## Troubleshooting

**`jq: error: Cannot index array with string`** — you used `.key` on an array. Expand with `.[]` first.

**Output has quotes** — you forgot `-r`.

**Empty result but exit code 0** — only `-e` returns a non-zero code on null/false.

**Chinese escaped as `\uXXXX`** — jq does not escape non-ASCII by default, but if the input itself is escaped you need `--raw-output` or `-j`.

**Wrong type from `--arg`** — `--arg` always produces strings; use `--argjson` for numbers.

<!-- lang:ja -->

> 要約：jq は JSON の照会・書き換えツールで、本リポジトリでは GitHub API レスポンスやスクリプト内の構造化データの処理に使っています。

# jq

## 用途

`jq` は JSON のコマンドラインプロセッサです。JSON からフィールドを抽出し、配列をフィルタリングし、構造を組み替え、出力を整形します。独自の小型の式言語を持っています。

本リポジトリでは 2 箇所でこれに依存しています。`nvim-update` が GitHub Release API を解析することと、`scripts/tests/nvim_update_test.sh` がテストフィクスチャを生成することです。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit、GitHub Release からダウンロード |
| 特記事項 | `--minimal` モードでは jq のインストールをスキップします |

```zsh
zi_cmd jqlang/jq jq
```

## 基本的な使い方

```bash
jq '.' file.json                   # 格式化
jq '.name' file.json               # 取字段
jq '.items[]' file.json            # 展开数组
jq -r '.name' file.json            # 原始字符串（去引号）
curl -s api | jq '.data[0].id'     # 管道
```

## 式の基礎

| 式 | 意味 |
|---|---|
| `.` | 入力全体 |
| `.key` | フィールドへのアクセス |
| `.key.nested` | ネストしたフィールド |
| `.[0]` | 配列の最初の要素 |
| `.[]` | すべての要素を展開 |
| `.[1:3]` | スライス |
| `.a, .b` | 両方を同時に出力 |
| `.a \| .b` | パイプ |
| `map(.x)` | 配列の各要素から `.x` を取り出す |
| `select(.x > 1)` | フィルタ |
| `length` | 長さ |
| `keys` | キーの一覧 |
| `to_entries` | key/value 配列に変換 |

## よく使うオプション

| オプション | 効果 |
|---|---|
| `-r` / `--raw-output` | 文字列を引用符なしで出力 |
| `-c` / `--compact-output` | 1 行で出力 |
| `-e` / `--exit-status` | 結果に応じて終了コードを設定（false/null → 1） |
| `-n` / `--null-input` | 入力を読まず null から開始 |
| `-s` / `--slurp` | すべての入力を 1 つの配列に読み込む |
| `-R` / `--raw-input` | 入力を JSON ではなくプレーンテキストとして扱う |
| `--arg k v` | 文字列変数 `$k` を渡す |
| `--argjson k v` | JSON 変数を渡す |
| `--tab` | Tab でインデント |
| `--sort-keys` | 出力時にキーをソート |
| `-j` / `--join-output` | 改行なし |

## 本リポジトリでの使い方

### nvim-update による release の解析

```bash
tag="$(jq -er '.tag_name | strings | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))' "$release_json")"

asset_url="$(jq -er --arg name "$asset_name" \
  '.assets[] | select(.name == $name) | .browser_download_url | strings | select(length > 0)' \
  "$release_json")"

expected_digest="$(jq -er --arg name "$asset_name" \
  '.assets[] | select(.name == $name) | .digest | strings
   | select(test("^sha256:[0-9a-fA-F]{64}$")) | sub("^sha256:"; "")' \
  "$release_json")"
```

注目すべきテクニックが 3 つあります：

1. **`-e`** — 結果が空または null のときに非ゼロの終了コードを返します。`|| fail` と組み合わせると、データが欠けているときにスクリプトが即座に失敗します。
2. **`-r`** — 出力から引用符を取り除き、そのまま変数へ代入できるようにします。
3. **`| strings | select(...)`** — フォーマットを検証する前に型が文字列であることを確認します。上流 API が null やオブジェクトを返しても黙って通過してしまうことを防ぎます。

### テストフィクスチャ

```bash
jq -n --arg tag 'v0.12.5' --arg name 'nvim-linux-x86_64.tar.gz' \
  --arg url "$asset_url" --arg digest "sha256:$digest" \
  '{tag_name: $tag, assets: [{name: $name, browser_download_url: $url, digest: $digest}]}'
```

`-n` は入力ファイルを必要とせず、`--arg` が変数を注入し、式で直接 JSON を組み立てます。テストはこれを使って偽の GitHub レスポンスを生成し、実際のダウンロードを避けます。

## 実用パターン

```bash
# 提取所有 id
jq -r '.[].id' data.json

# 过滤
jq '.[] | select(.status == "active")' data.json

# 重组
jq '{name: .login, repos: .public_repos}' user.json

# 数组转对象
jq 'map({(.id|tostring): .name}) | add' data.json

# 多文件合并
jq -s 'add' a.json b.json

# 检查字段存在
jq -e 'has("error")' response.json

# 美化并排序
jq -S '.' data.json
```


## トラブルシュート

**`jq: error: Cannot index array with string`**：配列に `.key` を使っています。先に `.[]` で展開してください。

**出力に引用符が付く**：`-r` を忘れています。

**結果が空なのに終了コードが 0**：`-e` を付けたときだけ null/false で非ゼロになります。

**中国語が `\uXXXX` にエスケープされる**：jq はデフォルトで非 ASCII をエスケープしませんが、入力自体がエスケープ済みの場合は `--raw-output` か `-j` が必要です。

**`--arg` で渡した値の型が違う**：`--arg` は常に文字列になります。数値は `--argjson` を使います。
