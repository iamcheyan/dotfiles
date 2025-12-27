# Scripts Utils 工具文档

通用工具脚本目录，包含轻量级、跨平台的实用工具。

## 目录说明

这些工具都是单功能、轻量级的脚本（通常 < 100 行），具有以下特点：
- 通用性强，不依赖特定环境
- 可独立使用，无复杂依赖
- 跨平台兼容性好
- 低维护成本

---

## 工具列表

### 1. `extract.sh` - 通用解压脚本

**功能**：根据文件扩展名自动选择解压方法，支持多种压缩格式。

**支持的格式**：
- `.tar` - tar 归档
- `.tar.gz` / `.gz` - gzip 压缩
- `.tar.bz2` / `.bz2` - bzip2 压缩
- `.tar.xz` / `.xz` - xz 压缩
- `.zip` - ZIP 压缩（需要 `unzip`）
- `.rar` - RAR 压缩（需要 `unrar`）
- `.7z` - 7z 压缩（需要 `7z`）

**用法**：
```bash
extract archive.tar.gz
extract file.zip
extract archive.7z
```

**别名**：`extract`

**依赖**：
- 基础格式：`tar`, `gunzip`, `bunzip2`, `unxz`
- 可选：`unzip`（用于 .zip）、`unrar`（用于 .rar）、`7z`（用于 .7z）

---

### 2. `url_encode.sh` - URL 编码工具

**功能**：将文本进行 URL 编码，用于处理 URL 中的特殊字符。

**用法**：
```bash
# 从参数读取
url:encode "你好世界"
url:encode "hello world"

# 从管道读取
echo "你好世界" | url:encode
cat file.txt | url:encode
```

**别名**：`url:encode`

**示例**：
```bash
$ url:encode "hello world"
hello%20world

$ url:encode "你好"
%E4%BD%A0%E5%A5%BD
```

**依赖**：Python 3 或 Python 2（使用 `urllib.parse` 或 `urllib`）

---

### 3. `url_decode.sh` - URL 解码工具

**功能**：将 URL 编码的文本解码为原始文本。

**用法**：
```bash
# 从参数读取
url:decode "hello%20world"
url:decode "%E4%BD%A0%E5%A5%BD"

# 从管道读取
echo "hello%20world" | url:decode
```

**别名**：`url:decode`

**示例**：
```bash
$ url:decode "hello%20world"
hello world

$ url:decode "%E4%BD%A0%E5%A5%BD"
你好
```

**依赖**：Python 3 或 Python 2（使用 `urllib.parse` 或 `urllib`）

---

### 4. `random_string.sh` - 随机字符串生成器

**功能**：生成指定长度的随机字符串，可用于密码、令牌等场景。

**用法**：
```bash
# 生成默认长度（32 字符）的随机字符串
random:string

# 生成指定长度的随机字符串
random:string 64
random:string 16
```

**别名**：`random:string`

**示例**：
```bash
$ random:string
aB3dEf9GhIjKlMnOpQrStUvWxYz12

$ random:string 16
XyZ9AbCdEfGhIjK
```

**依赖**：
- 优先使用：`openssl`
- 备用：`/dev/urandom`（Linux 系统）

**字符集**：字母和数字（a-zA-Z0-9）

---

## 使用建议

### 何时使用这些工具

- **extract.sh**：需要解压各种格式的压缩文件时
- **url_encode/decode.sh**：处理 URL 参数、API 请求、Web 开发时
- **random_string.sh**：生成临时密码、令牌、测试数据时

### 与其他工具的区别

这些工具与 `tools/` 目录中的工具区别在于：

| 特性 | `scripts/utils/` | `tools/` |
|------|-----------------|----------|
| 复杂度 | 简单（< 100 行） | 复杂（> 100 行） |
| 功能 | 单功能 | 多功能/工作流 |
| 依赖 | 最小依赖 | 可能有特定环境依赖 |
| 平台 | 跨平台 | 可能平台特定 |

---

## 添加新工具

添加新工具到 `scripts/utils/` 时，请遵循以下原则：

1. **单功能**：每个脚本只做一件事
2. **轻量级**：代码行数尽量 < 100 行
3. **通用性**：不依赖特定环境或配置
4. **文档化**：在脚本头部添加清晰的注释
5. **别名**：在 `aliases.conf` 中添加对应的别名

---

## 相关文档

- [主 README](../README.md) - 整体目录结构说明
- [Scripts README](../README.md) - Scripts 目录详细说明
- [Tools README](../../tools/README.md) - Tools 目录工具文档

