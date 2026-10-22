> 摘要：xh 是友好的 HTTP 客户端，语法接近 HTTPie，用 Rust 实现。

# xh

## 用途

`xh` 用简洁的语法发 HTTP 请求，输出彩色、格式化。它兼容 HTTPie 的大部分语法，但更快、单二进制、无 Python 依赖。

本仓库同时提供 `xh` 和 `http`（HTTPie），两者语法相近，任选其一。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |

```zsh
zi_cmd ducaale/xh xh
```

## 基本用法

```bash
xh https://example.com                 # GET
xh GET https://example.com             # 显式方法
xh POST https://api.example.com name=value   # JSON 字段
xh PUT https://api.example.com/x id:=42      # 数字字段
```

## 语法要点

| 写法 | 含义 |
|---|---|
| `key=value` | 字符串字段（JSON） |
| `key:=value` | 原始 JSON（数字、布尔、嵌套） |
| `key==value` | URL 查询参数 |
| `Header:value` | 请求头 |
| `Header:` | 空请求头（移除） |

例子：

```bash
# JSON body
xh POST https://api.example.com/users name=alice age:=30 active:=true

# 查询参数
xh GET https://api.example.com/search q==term page==2

# 自定义头
xh GET https://api.example.com Authorization:"Bearer TOKEN"

# 表单而非 JSON
xh --form POST https://example.com field=value
```

## 常用参数

| 参数 | 作用 |
|---|---|
| `-v` / `--verbose` | 显示请求和响应头 |
| `-h` / `--headers` | 只显示响应头 |
| `-b` / `--body` | 只显示响应体 |
| `-d` / `--download` | 下载到文件 |
| `-o` / `--output` | 指定输出文件 |
| `-f` / `--form` | 表单编码而非 JSON |
| `--json` | 强制 JSON（默认） |
| `--follow` | 跟随重定向 |
| `--timeout` | 超时秒数 |
| `--verify=no` | 跳过 TLS 校验（仅调试） |
| `-a` / `--auth` | Basic 认证 `user:pass` |
| `--bearer` | Bearer token |
| `--session` | 使用会话文件保存 cookie |
| `--offline` | 只打印将要发送的请求，不实际发送 |

`--offline` 在调试请求构造时很有用：

```bash
xh --offline POST https://api.example.com name=alice
```

## 会话

```bash
xh --session=mysession POST https://example.com/login user=me pass=secret
xh --session=mysession GET https://example.com/profile
```

会话文件保存在 `~/.config/xh/sessions/`（或 XDG 数据目录），保存 cookie 和 headers。

**注意**：会话文件里可能有 token，不要提交到仓库。

## 与 HTTPie 的对照

| | http（HTTPie） | xh |
|---|---|---|
| 语言 | Python | Rust |
| 启动速度 | 较慢 | 快 |
| 语法 | `key=value` | 相同 |
| 表单 | `--form` | `--form` |
| 会话 | `--session` | `--session` |
| 依赖 | Python 运行时 | 单二进制 |

本仓库两个都装，`http` 由 `install:httpie` 安装，`xh` 由 Zinit 提供。

## 实用模式

```bash
# 测试 API 健康检查
xh GET https://api.example.com/health

# 带认证
xh GET https://api.example.com/me Authorization:"Bearer $TOKEN"

# 上传文件
xh --form POST https://example.com/upload file@./photo.jpg

# 只关心状态码
xh -h GET https://example.com | head -1

# 下载
xh -d https://example.com/file.tar.gz
```

## 排错

**`xh: command not found`**：Zinit 未下载。

**JSON 解析失败**：服务端返回的不是 JSON，或请求没带 `Content-Type: application/json`。用 `-v` 看实际请求头。

**TLS 错误**：企业代理或自签证书。调试时可 `--verify=no`，但生产环境不要这样做。

**认证失败**：token 里有特殊字符需要引号。`Authorization:"Bearer $TOKEN"` 注意双引号位置。

**输出被截断**：大响应会自动分页。加 `-b` 只看 body，或 `| less`。
