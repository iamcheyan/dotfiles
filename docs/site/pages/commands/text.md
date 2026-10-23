> 摘要：cat、less、grep、sed、awk、sort、wc 等文本查看与处理命令，含 bat/ripgrep/sd/jq 替代品的用法。

# 文本处理

## 查看内容

```bash
cat file            # 全部输出（短文件）
less file           # 分页查看：/搜索、n下一个、q退出
head -20 file       # 前 20 行
tail -20 file       # 后 20 行
tail -f log.txt     # 实时跟踪新增内容（看日志必用，Ctrl+C 退出）
tail -F log.txt     # 同上，但文件被轮转重建后继续跟踪
head -c 500 file    # 前 500 字节
```

`cat` 的几个实用组合：

```bash
cat a b > merged    # 拼接文件
cat -n file         # 带行号输出
tac file            # 倒序输出（cat 反过来）
```

本机装了 **bat**（`batcat` 或 `bat`），带语法高亮和行号的分页器：

```bash
bat script.py      # 高亮 + 行号 + Git 修改标记
bat -p file        # 纯文本模式，不加装饰（管道给其它命令时用）
bat --style=plain  # 只留行号
```

`bat` 默认接管 `less` 的分页行为，`q` 退出。输出到管道时自动关闭分页，可以直接 `bat file | rg pattern`。

## grep 与 ripgrep

`grep` 按模式搜文本：

```bash
grep 'pattern' file        # 搜文件
grep -i 'pattern' file     # 忽略大小写
grep -v 'pattern' file     # 反选：输出不匹配的行
grep -n 'pattern' file     # 带行号
grep -r 'pattern' dir/     # 递归搜目录
grep -c 'pattern' file     # 只数匹配行数
grep -l 'pattern' dir/     # 只列文件名
grep -A3 -B3 'p' file      # 匹配行前后各 3 行
grep -E 'a|b' file         # 扩展正则（ERE）
```

本机默认用 **ripgrep**（`rg`），更快且默认遵守 `.gitignore`：

```bash
rg pattern                # 递归搜当前目录
rg -i pattern             # 忽略大小写
rg -uu pattern            # 搜被 .gitignore 忽略的文件（-uuu 连二进制都搜）
rg -t py pattern          # 只搜 Python 文件
rg -g '!*.min.js' p       # 排除通配
rg -l pattern             # 只列文件名
rg -n pattern             # 行号（默认就有）
rg -C3 pattern            # 前后各 3 行
rg --count pattern        # 每文件匹配数
rg -o 'v\d+\.\d+'         # 只输出匹配部分（-o），提取版本号之类
rg -F 'a.b'               # 固定字符串，不当正则（搜含点号的内容时用）
rg --json pattern | jq    # 结构化输出喂给 jq
```

`rg` 默认不搜隐藏文件和 `.gitignore` 忽略的内容，这正是大多数时候想要的；要找全就要 `-uu`。

## sed 流式编辑

```bash
sed 's/old/new/' file         # 每行第一个匹配替换（只输出，不改文件）
sed 's/old/new/g' file        # 全局替换
sed -i 's/old/new/g' file     # 原地修改（-i，GNU sed 直接写；macOS 要 -i ''）
sed -n '10,20p' file          # 只打印第 10-20 行
sed '10,20d' file             # 删除第 10-20 行
sed '/^#/d' file              # 删注释行
sed -n '/begin/,/end/p' file  # 打印两个标记之间的内容
```

本机也装了 **sd**，用直观的字符串替换代替 sed 的正则地狱：

```bash
sd 'old' 'new' file           # 字面替换，默认全局
sd -s 'a.b' 'x' file          # -s 字符串模式（. 不当通配）
sd '(\w+)=\w+' '$1=?' file    # 需要正则时也支持，语法更现代
```

日常替换优先 `sd`；写脚本要考虑可移植性时用 `sed`（每台机器都有）。

## awk 列处理

`awk` 按列切分文本，是日志和表格数据的主力：

```bash
awk '{print $1}' file             # 打印每行第 1 列
awk '{print $1, $3}' file         # 第 1 和第 3 列
awk -F: '{print $1}' /etc/group   # 以冒号作分隔符，取第 1 段（组名）
awk '$3 > 100' file               # 条件：第 3 列大于 100 才输出
awk '{sum += $2} END {print sum}' # 求和（END 块最后执行）
awk 'NR>=10 && NR<=20' file       # 第 10-20 行
awk '{count[$1]++} END {for (k in count) print k, count[k]}'  # 分组计数
```

本机实战例子：

```bash
# 统计日志里各 IP 出现次数
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head

# 看本机每个目录的一级条目数
ls ~/development | wc -l
```

## sort 与 uniq

```bash
sort file               # 字典序排序
sort -n file            # 按数值（不用 -n 时 10 排在 2 前面）
sort -rn file           # 数值倒序
sort -k2 file           # 按第 2 列排
sort -u file            # 排序 + 去重（等价 sort | uniq）
sort -R file            # 随机打乱
sort -h -k5 file        # 人类可读大小排序（2K < 1M）

uniq file               # 去掉相邻重复行（先 sort 才能全局去重）
uniq -c file            # 每行前加出现次数
uniq -d file            # 只输出重复的行
```

`sort | uniq -c | sort -rn | head` 是统计频率的黄金组合，本机查日志、数文件都靠它。

## wc 与 cut 与 tr

```bash
wc -l file          # 行数
wc -w file          # 单词数
wc -c file          # 字节数
wc -L file          # 最长行的长度

cut -d: -f1 /etc/group    # 按冒号切分，取第 1 段
cut -c1-80 file           # 截取每行前 80 字符

tr 'a-z' 'A-Z' < file     # 转大写
tr -d '\r' < win.txt      # 删掉 Windows 换行符（处理 CRLF 文件）
tr -s '\n' < file         # 压缩连续空行
```

`tr -d '\r'` 是处理 Windows 传来脚本的必备一步，否则 `bad interpreter: No such file or directory`。

## diff 与 jq

```bash
diff a b             # 比较两个文本文件
diff -u a b          # 统一格式（打补丁、看 PR 都用这个）
diff -r dir1 dir2    # 递归比较目录
colordiff a b        # 带颜色（本机可装）
```

**jq** 处理 JSON，本机与 `gh`、`curl` 配合最频繁：

```bash
echo '{"a":1}' | jq .              # 格式化
jq '.a' file.json                  # 取字段
jq '.items[] | select(.ok)' f.json # 过滤数组
jq -r '.name' f.json               # -r 输出原始字符串（不加引号）
gh pr list --json number,title | jq -r '.[] | "\(.number) \(.title)"'
```

`gh ... --json ... | jq` 是操作 GitHub 的利器，比读默认表格输出可控得多。

## 排错

**`sed -i` 在 macOS 上报错**：BSD sed 要求 `-i` 带备份参数，写 `-i ''`。本手册默认 GNU sed（Linux）。

**`rg` 搜不到刚建的文件**：文件被 `.gitignore` 忽略，加 `-uu`。

**`jq: error: Cannot index array with string`**：数据结构不是你想的那样，先 `jq 'type'` 或 `jq 'keys'` 探一下。

**`sort -n` 排序混乱**：漏了 `-n`，`10` 会排在 `2` 前面。

**管道中间结果看不到**：分段执行，先跑前半段确认输出再加下一段。

<!-- lang:en -->

> Summary: Text viewing and processing commands such as cat, less, grep, sed, awk, sort, and wc, including the bat/ripgrep/sd/jq replacements.

# Text Processing

## Viewing content

```bash
cat file            # 全部输出（短文件）
less file           # 分页查看：/搜索、n下一个、q退出
head -20 file       # 前 20 行
tail -20 file       # 后 20 行
tail -f log.txt     # 实时跟踪新增内容（看日志必用，Ctrl+C 退出）
tail -F log.txt     # 同上，但文件被轮转重建后继续跟踪
head -c 500 file    # 前 500 字节
```

A few practical `cat` combinations:

```bash
cat a b > merged    # 拼接文件
cat -n file         # 带行号输出
tac file            # 倒序输出（cat 反过来）
```

This machine has **bat** (as `batcat` or `bat`), a pager with syntax highlighting and line numbers:

```bash
bat script.py      # 高亮 + 行号 + Git 修改标记
bat -p file        # 纯文本模式，不加装饰（管道给其它命令时用）
bat --style=plain  # 只留行号
```

`bat` takes over `less`'s paging behavior by default; `q` quits. When output goes to a pipe, paging turns off automatically, so `bat file | rg pattern` works directly.

## grep and ripgrep

`grep` searches text by pattern:

```bash
grep 'pattern' file        # 搜文件
grep -i 'pattern' file     # 忽略大小写
grep -v 'pattern' file     # 反选：输出不匹配的行
grep -n 'pattern' file     # 带行号
grep -r 'pattern' dir/     # 递归搜目录
grep -c 'pattern' file     # 只数匹配行数
grep -l 'pattern' dir/     # 只列文件名
grep -A3 -B3 'p' file      # 匹配行前后各 3 行
grep -E 'a|b' file         # 扩展正则（ERE）
```

This machine defaults to **ripgrep** (`rg`), which is faster and respects `.gitignore` by default:

```bash
rg pattern                # 递归搜当前目录
rg -i pattern             # 忽略大小写
rg -uu pattern            # 搜被 .gitignore 忽略的文件（-uuu 连二进制都搜）
rg -t py pattern          # 只搜 Python 文件
rg -g '!*.min.js' p       # 排除通配
rg -l pattern             # 只列文件名
rg -n pattern             # 行号（默认就有）
rg -C3 pattern            # 前后各 3 行
rg --count pattern        # 每文件匹配数
rg -o 'v\d+\.\d+'         # 只输出匹配部分（-o），提取版本号之类
rg -F 'a.b'               # 固定字符串，不当正则（搜含点号的内容时用）
rg --json pattern | jq    # 结构化输出喂给 jq
```

`rg` by default doesn't search hidden files or anything ignored by `.gitignore` — which is what you want most of the time; use `-uu` when you need everything.

## sed stream editing

```bash
sed 's/old/new/' file         # 每行第一个匹配替换（只输出，不改文件）
sed 's/old/new/g' file        # 全局替换
sed -i 's/old/new/g' file     # 原地修改（-i，GNU sed 直接写；macOS 要 -i ''）
sed -n '10,20p' file          # 只打印第 10-20 行
sed '10,20d' file             # 删除第 10-20 行
sed '/^#/d' file              # 删注释行
sed -n '/begin/,/end/p' file  # 打印两个标记之间的内容
```

This machine also has **sd**, which replaces sed's regex hell with intuitive string substitution:

```bash
sd 'old' 'new' file           # 字面替换，默认全局
sd -s 'a.b' 'x' file          # -s 字符串模式（. 不当通配）
sd '(\w+)=\w+' '$1=?' file    # 需要正则时也支持，语法更现代
```

Prefer `sd` for everyday substitutions; use `sed` when writing scripts that need portability (it exists on every machine).

## awk column processing

`awk` splits text by columns and is the mainstay for logs and tabular data:

```bash
awk '{print $1}' file             # 打印每行第 1 列
awk '{print $1, $3}' file         # 第 1 和第 3 列
awk -F: '{print $1}' /etc/group   # 以冒号作分隔符，取第 1 段（组名）
awk '$3 > 100' file               # 条件：第 3 列大于 100 才输出
awk '{sum += $2} END {print sum}' # 求和（END 块最后执行）
awk 'NR>=10 && NR<=20' file       # 第 10-20 行
awk '{count[$1]++} END {for (k in count) print k, count[k]}'  # 分组计数
```

Practical examples on this machine:

```bash
# 统计日志里各 IP 出现次数
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head

# 看本机每个目录的一级条目数
ls ~/development | wc -l
```

## sort and uniq

```bash
sort file               # 字典序排序
sort -n file            # 按数值（不用 -n 时 10 排在 2 前面）
sort -rn file           # 数值倒序
sort -k2 file           # 按第 2 列排
sort -u file            # 排序 + 去重（等价 sort | uniq）
sort -R file            # 随机打乱
sort -h -k5 file        # 人类可读大小排序（2K < 1M）

uniq file               # 去掉相邻重复行（先 sort 才能全局去重）
uniq -c file            # 每行前加出现次数
uniq -d file            # 只输出重复的行
```

`sort | uniq -c | sort -rn | head` is the golden combination for counting frequencies; log analysis and file counting on this machine both rely on it.

## wc, cut, and tr

```bash
wc -l file          # 行数
wc -w file          # 单词数
wc -c file          # 字节数
wc -L file          # 最长行的长度

cut -d: -f1 /etc/group    # 按冒号切分，取第 1 段
cut -c1-80 file           # 截取每行前 80 字符

tr 'a-z' 'A-Z' < file     # 转大写
tr -d '\r' < win.txt      # 删掉 Windows 换行符（处理 CRLF 文件）
tr -s '\n' < file         # 压缩连续空行
```

`tr -d '\r'` is a mandatory step for scripts arriving from Windows; otherwise you get `bad interpreter: No such file or directory`.

## diff and jq

```bash
diff a b             # 比较两个文本文件
diff -u a b          # 统一格式（打补丁、看 PR 都用这个）
diff -r dir1 dir2    # 递归比较目录
colordiff a b        # 带颜色（本机可装）
```

**jq** processes JSON and pairs with `gh` and `curl` most often on this machine:

```bash
echo '{"a":1}' | jq .              # 格式化
jq '.a' file.json                  # 取字段
jq '.items[] | select(.ok)' f.json # 过滤数组
jq -r '.name' f.json               # -r 输出原始字符串（不加引号）
gh pr list --json number,title | jq -r '.[] | "\(.number) \(.title)"'
```

`gh ... --json ... | jq` is the power tool for GitHub operations — far more controllable than parsing the default table output.

## Troubleshooting

**`sed -i` errors on macOS**: BSD sed requires `-i` to take a backup argument; write `-i ''`. This manual assumes GNU sed (Linux).

**`rg` can't find a just-created file**: the file is ignored by `.gitignore`; add `-uu`.

**`jq: error: Cannot index array with string`**: the data structure isn't what you assumed; probe it first with `jq 'type'` or `jq 'keys'`.

**`sort -n` sorts chaotically**: you forgot `-n`; `10` will sort before `2`.

**Can't see intermediate pipeline results**: run it in stages; run the first half, confirm its output, then append the next stage.

<!-- lang:ja -->

> 要約：cat、less、grep、sed、awk、sort、wc などのテキスト表示・処理コマンド。bat/ripgrep/sd/jq といった代替ツールの使い方も含みます。

# テキスト処理

## 内容を見る

```bash
cat file            # 全部输出（短文件）
less file           # 分页查看：/搜索、n下一个、q退出
head -20 file       # 前 20 行
tail -20 file       # 后 20 行
tail -f log.txt     # 実時跟踪新增内容（看日志必用，Ctrl+C 退出）
tail -F log.txt     # 同上，但文件被轮转重建后继续跟踪
head -c 500 file    # 前 500 字节
```

`cat` の実用的な組み合わせ：

```bash
cat a b > merged    # 拼接文件
cat -n file         # 带行号输出
tac file            # 倒序输出（cat 反过来）
```

本機には **bat**（`batcat` または `bat`）が入っています。シンタックスハイライトと行番号付きのページャーです：

```bash
bat script.py      # 高亮 + 行号 + Git 修改标记
bat -p file        # 纯文本模式，不加装饰（管道给其它命令时用）
bat --style=plain  # 只留行号
```

`bat` はデフォルトで `less` のページング動作を引き継ぎ、`q` で終了します。パイプへの出力時はページングが自動でオフになるので、`bat file | rg pattern` がそのまま使えます。

## grep と ripgrep

`grep` はパターンでテキストを検索します：

```bash
grep 'pattern' file        # 搜文件
grep -i 'pattern' file     # 忽略大小写
grep -v 'pattern' file     # 反选：输出不匹配的行
grep -n 'pattern' file     # 带行号
grep -r 'pattern' dir/     # 递归搜目录
grep -c 'pattern' file     # 只数匹配行数
grep -l 'pattern' dir/     # 只列文件名
grep -A3 -B3 'p' file      # 匹配行前后各 3 行
grep -E 'a|b' file         # 扩展正则（ERE）
```

本機のデフォルトは **ripgrep**（`rg`）で、より速くデフォルトで `.gitignore` を尊重します：

```bash
rg pattern                # 递归搜当前目录
rg -i pattern             # 忽略大小写
rg -uu pattern            # 搜被 .gitignore 忽略的文件（-uuu 连二进制都搜）
rg -t py pattern          # 只搜 Python 文件
rg -g '!*.min.js' p       # 排除通配
rg -l pattern             # 只列文件名
rg -n pattern             # 行号（默认就有）
rg -C3 pattern            # 前后各 3 行
rg --count pattern        # 每文件匹配数
rg -o 'v\d+\.\d+'         # 只输出匹配部分（-o），提取版本号之类
rg -F 'a.b'               # 固定字符串，不当正则（搜含点号的内容时用）
rg --json pattern | jq    # 结构化输出喂给 jq
```

`rg` はデフォルトで隠しファイルと `.gitignore` の無視対象を検索しません。これはたいていの場合望ましい挙動で、全部探したいときだけ `-uu` を付けます。

## sed のストリーム編集

```bash
sed 's/old/new/' file         # 每行第一个匹配替换（只输出，不改文件）
sed 's/old/new/g' file        # 全局替换
sed -i 's/old/new/g' file     # 原地修改（-i，GNU sed 直接写；macOS 要 -i ''）
sed -n '10,20p' file          # 只打印第 10-20 行
sed '10,20d' file             # 删除第 10-20 行
sed '/^#/d' file              # 删注释行
sed -n '/begin/,/end/p' file  # 打印两个标记之间的内容
```

本機には **sd** も入っています。sed の正規表現地獄の代わりに、直感的な文字列置換を提供します：

```bash
sd 'old' 'new' file           # 字面替换，默认全局
sd -s 'a.b' 'x' file          # -s 字符串模式（. 不当通配）
sd '(\w+)=\w+' '$1=?' file    # 需要正则时也支持，语法更现代
```

日常の置換は `sd` を優先し、移植性を考慮するスクリプトでは `sed`（どのマシンにもある）を使います。

## awk の列処理

`awk` はテキストを列で切り分ける、ログや表形式データの主力ツールです：

```bash
awk '{print $1}' file             # 打印每行第 1 列
awk '{print $1, $3}' file         # 第 1 和第 3 列
awk -F: '{print $1}' /etc/group   # 以冒号作分隔符，取第 1 段（组名）
awk '$3 > 100' file               # 条件：第 3 列大于 100 才输出
awk '{sum += $2} END {print sum}' # 求和（END 块最后执行）
awk 'NR>=10 && NR<=20' file       # 第 10-20 行
awk '{count[$1]++} END {for (k in count) print k, count[k]}'  # 分组计数
```

本機での実戦例：

```bash
# 统计日志里各 IP 出现次数
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head

# 看本机每个目录的一级条目数
ls ~/development | wc -l
```

## sort と uniq

```bash
sort file               # 字典序排序
sort -n file            # 按数值（不用 -n 时 10 排在 2 前面）
sort -rn file           # 数值倒序
sort -k2 file           # 按第 2 列排
sort -u file            # 排序 + 去重（等价 sort | uniq）
sort -R file            # 随机打乱
sort -h -k5 file        # 人类可读大小排序（2K < 1M）

uniq file               # 去掉相邻重复行（先 sort 才能全局去重）
uniq -c file            # 每行前加出现次数
uniq -d file            # 只输出重复的行
```

`sort | uniq -c | sort -rn | head` は頻度集計の黄金の組み合わせで、本機のログ調査やファイル集計はすべてこれに頼っています。

## wc、cut、tr

```bash
wc -l file          # 行数
wc -w file          # 单词数
wc -c file          # 字节数
wc -L file          # 最长行的长度

cut -d: -f1 /etc/group    # 按冒号切分，取第 1 段
cut -c1-80 file           # 截取每行前 80 字符

tr 'a-z' 'A-Z' < file     # 转大写
tr -d '\r' < win.txt      # 删掉 Windows 换行符（处理 CRLF 文件）
tr -s '\n' < file         # 压缩连续空行
```

`tr -d '\r'` は Windows から来たスクリプトを処理する必須の手順です。さもないと `bad interpreter: No such file or directory` になります。

## diff と jq

```bash
diff a b             # 比较两个文本文件
diff -u a b          # 统一格式（打补丁、看 PR 都用这个）
diff -r dir1 dir2    # 递归比较目录
colordiff a b        # 带颜色（本机可装）
```

**jq** は JSON を処理し、本機では `gh` や `curl` と組み合わせる頻度が最も高いツールです：

```bash
echo '{"a":1}' | jq .              # 格式化
jq '.a' file.json                  # 取字段
jq '.items[] | select(.ok)' f.json # 过滤数组
jq -r '.name' f.json               # -r 输出原始字符串（不加引号）
gh pr list --json number,title | jq -r '.[] | "\(.number) \(.title)"'
```

`gh ... --json ... | jq` は GitHub 操作の強力な道具で、デフォルトの表出力を読むよりはるかに制御しやすいです。

## トラブルシューティング

**macOS で `sed -i` がエラーになる**：BSD sed は `-i` にバックアップ引数を要求するので `-i ''` と書きます。このマニュアルは GNU sed（Linux）を前提としています。

**`rg` で作ったばかりのファイルが見つからない**：`.gitignore` に無視されています。`-uu` を付けます。

**`jq: error: Cannot index array with string`**：データ構造が想定と違います。先に `jq 'type'` や `jq 'keys'` で探ってみます。

**`sort -n` の並びがおかしい**：`-n` を忘れています。`10` が `2` の前に並びます。

**パイプの中間結果が見えない**：段階的に実行します。前半だけ走らせて出力を確認してから、次の段を付け足します。
