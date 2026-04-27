# HTTPie

`HTTPie` 是一个适合终端里调试 API 的 HTTP 客户端，可以把它理解成比 `curl` 更顺手、比图形化 Postman 更轻量的 CLI 方案。

官方文档：

- CLI Docs: https://httpie.io/docs/cli

## 安装

当前仓库提供：

```bash
install:httpie
```

支持参数：

```bash
install:httpie --force
install:httpie --method auto
install:httpie --method package
install:httpie --method pipx
install:httpie --method pip
```

## 基本用法

### 发 GET 请求

```bash
http GET https://httpbin.org/get
```

也可以省略 `GET`：

```bash
http https://httpbin.org/get
```

### 带 Query 参数

```bash
http GET https://httpbin.org/get page==1 keyword==download
```

说明：

- `foo==bar` 表示 URL query 参数
- `foo=bar` 表示请求体字段

### 发 JSON POST

```bash
http POST https://httpbin.org/post name=hkaku env=prod enabled:=true
```

说明：

- `name=hkaku` 会作为 JSON 字符串
- `enabled:=true` 会作为 JSON 布尔值

### 自定义 Header

```bash
http GET https://httpbin.org/headers Authorization:"Bearer TOKEN" X-Env:prod
```

### Basic Auth

```bash
http -a username:password GET https://httpbin.org/basic-auth/username/password
```

### Bearer Token

```bash
http GET https://api.example.com/tasks Authorization:"Bearer $TOKEN"
```

### 表单和文件上传

```bash
http --form POST https://httpbin.org/post file@./payload.json
```

```bash
http --form POST https://httpbin.org/post env=prod note='manual upload'
```

### 下载响应

```bash
http --download GET https://httpbin.org/image/png
```

或者：

```bash
http GET https://httpbin.org/json > response.json
```

## 调试 API 最常用的技巧

### 看完整请求和响应

```bash
http --verbose POST https://httpbin.org/post name=demo
```

### 只看 header

```bash
http --headers GET https://httpbin.org/get
```

### 只看响应体

```bash
http --body GET https://httpbin.org/get
```

### 离线查看即将发送的请求

```bash
http --offline POST https://api.example.com/tasks name=demo
```

### 临时跳过 TLS 校验

```bash
http --verify=no GET https://example.internal/api/health
```

## Session

如果你要反复调同一个 API，`session` 很有用：

```bash
http --session=dev-session POST https://httpbin.org/cookies foo=bar
http --session=dev-session GET https://httpbin.org/cookies
```

它会帮你保留 cookie 和部分登录状态。

## 适合你的几个场景

### 调 JSON API

```bash
http POST https://api.example.com/download \
  Authorization:"Bearer $TOKEN" \
  env=prod \
  fileId=12345 \
  force:=true
```

### 调试 API Gateway / Cloud 接口

```bash
http --verbose GET "https://api.example.com/files?id==123"
```

### 配合环境变量

```bash
TOKEN=xxx
BASE_URL=https://api.example.com

http GET "$BASE_URL/tasks" Authorization:"Bearer $TOKEN"
```

## 和 curl 的差别

- 更适合临时手写 JSON
- header、query、body 语法更直观
- 默认输出更适合人读
- 做 API 调试时通常比 `curl` 更省脑子
