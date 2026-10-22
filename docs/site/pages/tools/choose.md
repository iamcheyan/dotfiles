> 摘要：choose 按列或字段抽取文本，替代 awk 和 cut 的常见用法。

# choose

## 用途

`choose` 按列/字段抽取文本。相比 `awk '{print $2}'` 和 `cut -d: -f1`，它更易读、支持负数索引、支持正则分隔符、可以重排和去重。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |

```zsh
zi_cmd theryangeary/choose choose
```

## 基本用法

```bash
choose 1                        # 第一列
choose 1 3                      # 第 1 和第 3 列
choose -1                       # 最后一列
printf 'a b c\n' | choose 1     # 从管道
```

默认分隔符是任意空白（空格和 Tab），和 awk 一致。

## 索引规则

| 写法 | 含义 |
|---|---|
| `1` | 第一列（从 1 开始，不是 0） |
| `-1` | 最后一列 |
| `2:4` | 第 2 到第 4 列 |
| `1,3` | 第 1 和第 3 列（等价 `1 3`） |
| `-3:-1` | 倒数第三到最后一列 |
| `1:` | 从第 1 列到末尾 |

## 常用参数

| 参数 | 作用 |
|---|---|
| `-f` / `--field-separator` | 指定分隔符 |
| `-d` / `--delimiter` | 同上（旧名） |
| `-r` / `--regex` | 用正则做分隔符 |
| `-n` / `--non-greedy` | 正则非贪婪匹配 |
| `-o` / `--output-separator` | 输出分隔符，默认空格 |
| `-c` / `--character-wise` | 按字符而非字段 |
| `-t` / `--tsv` | 按 Tab 分隔（TSV） |
| `-x` / `--exclusive` | 排除指定列，输出其余 |
| `-s` / `--sequential` | 顺序输出而非按索引顺序 |
| `-u` / `--unique` | 去重 |

## 实用例子

```bash
# 进程名
ps aux | choose 11

# CSV 第二列
choose -f, 2 data.csv

# 冒号分隔的最后一列
choose -f: -1 /etc/passwd

# 重排：先输出第三列再输出第一列
choose 3 1

# 排除第一列
choose -x 1

# TSV
choose -t 2 data.tsv

# 按字符
echo 'abcdef' | choose -c 1:3     # abc

# 去重
choose -u 1
```

## 与 awk / cut 的对照

| 需求 | awk | cut | choose |
|---|---|---|---|
| 第 2 列 | `awk '{print $2}'` | `cut -f2` | `choose 2` |
| 最后一列 | `awk '{print $NF}'` | 难 | `choose -1` |
| 重排 | `awk '{print $3,$1}'` | 不支持 | `choose 3 1` |
| 正则分隔 | `awk -F'regex'` | 不支持 | `choose -r -f'regex'` |
| 排除列 | 手写 | `--complement` | `choose -x 1` |

choose 的优势是「不需要写代码」：直接列出要哪几列。

## 默认分隔符的细节

默认分隔符是「一段连续的空白」，不是单个空格。所以：

```bash
printf 'a    b\tc\n' | choose 2      # 输出 b，不是空字符串
```

这和 awk 的默认行为一致，和 `cut -d' '` 不同。

## 实用组合

```bash
# 找出占用内存最多的 5 个进程名
ps aux --sort=-%mem | tail -n +2 | head -5 | choose 11

# 提取 git 分支名
git branch -vv | choose 1

# 列出所有 shell
cat /etc/passwd | choose -f: -1 | sort -u

# 从日志里抽时间戳和消息
tail -f app.log | choose 1:
```

## 排错

**`choose: command not found`**：Zinit 未下载。

**输出列不对**：默认分隔符是连续空白。CSV 要显式 `-f,`。

**负索引不生效**：`-1` 表示最后一列，但需要该行有足够字段。空行会报错或跳过。

**输出分隔符是空格**：默认输出用空格连接。要保留原分隔符，用 `-o` 指定。

**想按 Tab 分隔但被当成空白**：用 `-t` 或 `-f '\t'` 显式指定。
