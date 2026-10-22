> 摘要：HTTPie 提供 http 命令，本仓库有 install:httpie 安装器做三级回退。

# HTTPie

## 用途

HTTPie 是人性化的 HTTP 客户端。相比 `curl -X POST -H ... -d ...`，它的语法更接近自然语言：`http POST url key=value`。

本仓库同时提供 `xh`（Rust）和 `http`（HTTPie），语法相近。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | `scripts/install/install_httpie.sh`，通过 `install:httpie` 函数调用 |
| 安装策略 | 包管理器 → pipx → pip 三级回退 |

```zsh
install:httpie
install:httpie --method package
install:httpie --method pipx
install:httpie --method pip
install:httpie --force
```

## 安装器行为

```bash
if command_exists http && [[ "$FORCE" -ne 1 ]]; then
  print_success "HTTPie is already installed: $(http --version)"
  exit 0
fi
```

已经装了 `http` 就跳过，除非 `--force`。

三级回退：

| 方法 | 命令 | 适用 |
|---|---|---|
| `package` | apt/dnf/pacman/brew | 有 root 权限 |
| `pipx` | `pipx install --force httpie` | 无 root，但装了 pipx |
| `pip` | `python3 -m pip install --user` | 无 root、无 pipx |

`auto` 模式按上面顺序依次尝试，任一成功即停止。

## 基本用法

```bash
http example.org                     # GET
http example.org hello=world         # POST（有数据时自动 POST）
http GET example.org                 # 显式 GET
http POST api.example.com name=alice # JSON body
```

## 语法要点

| 写法 | 含义 |
|---|---|
| `key=value` | JSON 字符串字段 |
| `key:=value` | JSON 原始值（数字、布尔、数组） |
| `key==value` | URL 查询参数 |
| `Header:value` | 请求头 |
| `Header:` | 移除请求头 |
| `field@file` | 上传文件 |
| `field=@file` | 字段值来自文件 |

例子：

```bash
# JSON body
http POST api.example.com/users name=alice age:=30

# 查询参数
http GET api.example.com/search q==term page==2

# 认证
http -a user:pass api.example.com/private
http GET api.example.com Authorization:"Bearer TOKEN"

# 表单
http --form POST example.com name=alice
```

## 常用参数

| 参数 | 作用 |
|---|---|
| `-v` / `--verbose` | 显示请求和响应头 |
| `-h` / `--headers` | 只显示响应头 |
| `-b` / `--body` | 只显示响应体 |
| `-d` / `--download` | 下载 |
| `-o` / `--output` | 输出到文件 |
| `-f` / `--form` | 表单编码 |
| `--json` | 强制 JSON |
| `--follow` | 跟随重定向 |
| `--timeout` | 超时 |
| `--verify=no` | 跳过 TLS 校验 |
| `--session` | 会话文件 |
| `--offline` | 只打印请求不发送 |
| `--print=HBhb` | 精确控制打印哪些部分 |

`--print` 的字母含义：`H` 请求头、`B` 请求体、`h` 响应头、`b` 响应体。

## 会话

```bash
http --session=work POST example.com/login user=me pass=secret
http --session=work GET example.com/profile
```

会话保存在 `~/.config/httpie/sessions/`，包含 cookie 和 headers。**可能含 token，不要提交。**

## 本地服务简写

```bash
http :3000              # http://localhost:3000
http :/api/users        # http://localhost/api/users
```

冒号开头自动补 `localhost`，省去写完整地址。

## 与 xh 的选择

| | http（HTTPie） | xh |
|---|---|---|
| 语言 | Python | Rust |
| 启动 | 较慢（Python 启动） | 快 |
| 语法 | 原版 | 兼容 |
| 依赖 | Python | 单二进制 |

脚本里频繁调用选 xh，交互式随手用选 http 都行。

## 排错

**`http: command not found`**：安装器失败，或 pip 的 user bin 不在 PATH。`python3 -m site --user-base` 查看路径。

**JSON 被解析成字符串**：用了 `key=value` 而不是 `key:=value`。前者总是字符串。

**中文乱码**：服务端编码不是 UTF-8。加 `Accept-Charset:utf-8`。

**TLS 错误**：企业代理或自签证书。`--verify=no` 仅用于调试。

**`--session` 后认证丢失**：会话文件权限或路径问题。`ls -l ~/.config/httpie/sessions/`。

**pip 安装后仍找不到**：`~/.local/bin` 不在 PATH。在 `local/` 里补上。
