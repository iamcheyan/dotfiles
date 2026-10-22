> 摘要：yq 处理 YAML/JSON/XML，语法兼容 jq，本仓库用它读写配置文件。

# yq

## 用途

`yq` 是 YAML 的 jq。它读取 YAML、JSON、XML、Properties 等格式，用 jq 风格的表达式查询和修改。

本仓库用它处理 Kubernetes 清单、CI 配置、以及任何 YAML 配置的批量修改。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |

```zsh
zi_cmd mikefarah/yq yq
```

注意有两个同名项目：`mikefarah/yq`（Go，本仓库用这个）和 `kislyuk/yq`（Python，包装 jq）。两者语法有差异，本站指前者。

## 基本用法

```bash
yq '.' file.yaml                 # 格式化
yq '.key' file.yaml              # 取字段
yq '.items[]' file.yaml          # 展开数组
yq -i '.key = "value"' file.yaml # 原地修改
```

`-i` 是 yq 最有用的参数：直接改文件，不需要重定向。

## 表达式

与 jq 基本一致：

| 表达式 | 含义 |
|---|---|
| `.key` | 取字段 |
| `.a.b.c` | 嵌套 |
| `.[0]` | 数组元素 |
| `.[]` | 展开 |
| `.a \| .b` | 管道 |
| `map(.x)` | 映射 |
| `select(.x > 1)` | 过滤 |
| `keys` | 键列表 |
| `length` | 长度 |
| `del(.key)` | 删除字段 |

## 常用参数

| 参数 | 作用 |
|---|---|
| `-i` / `--inplace` | 原地修改文件 |
| `-r` / `--unwrapScalar` | 字符串不带引号 |
| `-e` / `--exit-status` | 结果为 null/false 时非零退出 |
| `-n` / `--null-input` | 不读输入 |
| `-P` / `--prettyPrint` | 美化输出（默认） |
| `-I` / `--indent` | 缩进空格数 |
| `-o` / `--output-format` | `yaml`、`json`、`props`、`xml` |
| `-p` / `--input-format` | 指定输入格式 |
| `--arg` / `--argjson` | 传入变量 |

## 实用例子

### 读取

```bash
yq '.spec.replicas' deployment.yaml
yq '.items[].metadata.name' list.yaml
yq '.jobs.build.steps[].name' .github/workflows/ci.yml
```

### 修改

```bash
# 改单个值
yq -i '.spec.replicas = 3' deployment.yaml

# 改镜像
yq -i '.spec.template.spec.containers[0].image = "nginx:1.25"' deployment.yaml

# 加字段
yq -i '.metadata.labels.env = "prod"' deployment.yaml

# 删字段
yq -i 'del(.metadata.annotations)' deployment.yaml
```

### 格式转换

```bash
yq -o json '.' config.yaml > config.json    # YAML → JSON
yq -p json -o yaml '.' config.json > out.yaml  # JSON → YAML
```

### 批量处理

```bash
# 给所有 deployment 加标签
for f in k8s/*.yaml; do
  yq -i '.metadata.labels.managed-by = "me"' "$f"
done

# 提取所有镜像
yq '.spec.template.spec.containers[].image' k8s/*.yaml
```

## 与 jq 的差异

| | jq | yq |
|---|---|---|
| 输入格式 | JSON | YAML/JSON/XML/props |
| 原地修改 | 不支持 | `-i` |
| 注释保留 | 不适用 | 支持（YAML 注释） |
| 多文档 | 不支持 | `---` 分隔的多文档 |
| 表达式 | 原生 | 兼容并扩展 |

**关键差异**：yq 的 `-i` 会保留 YAML 注释和格式（大部分情况），jq 只能输出新文件。

## 多文档 YAML

Kubernetes 清单常用 `---` 分隔：

```bash
yq '.kind' multi.yaml              # 每个文档的 kind
yq 'select(.kind == "Deployment")' multi.yaml   # 只输出 Deployment
yq -i 'select(.kind == "Deployment") | .spec.replicas = 2' multi.yaml
```

## 排错

**`yq: command not found`**：Zinit 未下载，或装的是 Python 版 yq。

**`-i` 后注释丢失**：yq 会尽量保留，但复杂结构的注释可能移位。改前先 `git diff` 确认。

**语法和 jq 不一致**：确认用的是 mikefarah/yq（Go 版）。Python 版行为不同。

**输出格式不对**：默认输出 YAML。要 JSON 加 `-o json`。

**`--arg` 的值类型错**：`--arg` 是字符串，数字和布尔用 `--argjson`。

**中文乱码**：确认文件编码是 UTF-8。yq 不做编码转换。
