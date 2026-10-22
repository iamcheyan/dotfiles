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

## 与 yq 的分工

| | jq | yq |
|---|---|---|
| 格式 | 只处理 JSON | YAML、JSON、XML |
| 语法 | 自己的表达式 | 兼容 jq 语法 |
| 典型用途 | API 响应 | 配置文件 |

处理 `.json` 用 jq，处理 `.yaml`/`.yml` 用 yq。yq 能读 jq 的表达式，所以两者概念相通。

## 排错

**`jq: error: Cannot index array with string`**：对数组用了 `.key`。先 `.[]` 展开。

**输出带引号**：忘了 `-r`。

**空结果但退出码是 0**：加了 `-e` 才会在 null/false 时返回非零。

**中文被转义成 `\uXXXX`**：jq 默认不转义非 ASCII，但如果输入本身是转义的，需要 `--raw-output` 或 `-j`。

**`--arg` 传的值类型不对**：`--arg` 总是字符串，数字用 `--argjson`。
