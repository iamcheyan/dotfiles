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
